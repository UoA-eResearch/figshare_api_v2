module Figshare
  require 'digest'
  require 'dir_r'

  # Upload files to figshare
  # Nb. This can sometimes fail, so you need to check the md5 to ensure the file got there
  #     It can take a short while for the md5 to be calculated, so upload, wait, then check for a computed_md5.
  #     The status will show as "ic_checking",  "moving_to_final" then to "available", 
  #     I have seen it stuck at "moving_to_final", but with the right computed_md5.
  #
  class Upload < PrivateArticles
    CHUNK_SIZE = 1048576
    attr_accessor :file_info, :upload_query, :upload_host, :upload_parts_detail , :file_id, :article_id, :file_name
    attr_accessor :new_count, :bad_count
  
    # Calculate a local files MD5.
    #
    # @param filename [String] Path/name of local file to MD5
    # @return [String,Integer] MD5 as a Hex String, Size of the file in bytes.
    def self.get_file_check_data(filename)
      stat_record =  File.stat(filename)
      md5 = Digest::MD5.new
      File.open(filename, 'rb') do |fd|
        while(buffer = fd.read(CHUNK_SIZE)) 
          md5.update(buffer)
        end
      end
      return md5.hexdigest, stat_record.size
    end

    # Upload the file, to the Figshare article
    #
    # @param article_id [Integer] Figshare article id
    # @param file_name [String] path/file_name to upload
    # @param trace [Integer] 0: no output, 1: per file upload message, 2: fuller trace
    def upload(article_id:, file_name:, trace: 0)
      @article_id = article_id
      @file_name = file_name
      @trace = trace
      
      @file_id = nil
      @file_info = nil
      @upload_query = nil
      @upload_host = nil
      @upload_parts_detail  = nil
      
      initiate_new_upload() 
      puts "New File_id: #{@file_id}\n\n" if @trace > 1
      
      get_file_info()
      puts "@file_info: #{@file_info.to_j}\n\n" if @trace > 1
      
      get_upload_parts_details()
      puts "@upload_parts_detail: #{@upload_parts_detail.to_j}\n\n" if @trace > 1
      
      upload_the_parts()
      
      complete_upload()
      if @trace > 1
        status
        puts "Final Status: #{@file_info.to_j}\n\n"
      end
    end
    
    # Upload all files in a directory, into one article.
    # Check checksums, and only upload changed or new files
    # Does not recurse through sub-directories, as figshare has a flat file structure.
    #
    # @param article_id [Integer] Figshare article id
    # @param directory [String] path
    # @param delete_extras [Boolean] delete any files in the figshare end, that aren't in the local directory.
    # @param trace [Integer] 0: no output, 1: per file upload message, 2: fuller trace
    def upload_dir(article_id:, directory:, delete_extras: false, exclude_dot_files: true, trace: 0)
      @new_count = 0
      @bad_count = 0
      
      files = {}
      cache_article_file_md5(article_id: article_id)
      
      DirR.walk_dir(directory: directory, walk_sub_directories: false) do |d,f|
        next if exclude_dot_files && f =~ /^\..*/
        files[f] = true  #note that we have seen this filename
        if @md5_cache[f] #check to see if it has already been uploaded
          md5, size = Upload.get_file_check_data("#{d}/#{f}")
          if @md5_cache[f][:md5] != md5 #file is there, but has changed, or previously failed to upload.
            puts "Deleting: #{article_id} << #{d}/#{f} #{@md5_cache[f][:id]} MISMATCH '#{@md5_cache[f]}' != '#{md5}'" if trace > 0
            file_delete(article_id: article_id, file_id: @md5_cache[f][:id])
            @bad_count += 1
            puts "Re-ADDING: #{article_id} << #{d}/#{f}" if trace > 0
            upload(article_id: article_id, file_name: "#{d}/#{f}", trace: trace)
            @new_count += 1
          elsif trace > 1
            puts "EXISTS: #{article_id} #{d}/#{f}"
          end
        else
          puts "ADDING: #{article_id} << #{d}/#{f}" if trace > 0
          upload(article_id: article_id, file_name: "#{d}/#{f}", trace: trace)
          @new_count += 1
        end
      end
      
      # Print out filename of files in the Figshare article, that weren't in the directory.
      @md5_cache.each do |fn,v|
        if ! files[fn]  
          #File exists on Figshare, but not on the local disk
          if delete_extras
            puts "Deleteing EXTRA: #{article_id} << #{fn} #{v[:id]}" if trace > 0
            file_delete(article_id: article_id, file_id: @md5_cache[f][:id]) 
          elsif trace > 0
            puts "EXTRA: #{article_id} << #{fn} #{v[:id]}" 
          end
        end
      end
    end

    # Retrieve md5 sums of the existing files in the figshare article
    # Sets @md5_cache[filename] => figshare.computed_md5
    # 
    # @param article_id [Integer] Figshare article ID
    private def cache_article_file_md5(article_id:)
      @md5_cache = {}
      files(article_id: article_id) do |f|
        @md5_cache[f['name']] = {:article_id => article_id, :id => f['id'], :md5 => f[ 'computed_md5']}
      end
    end
    
    # Get status of the current upload. 
    # Just fetches the file record from figshare.
    # Of interest is the status field, and the computed_md5 field
    #
    # @return [Hash] Figshare file record, or nil, if the call fails
    def status
      @file_info = nil
      file_detail(article_id: @article_id, file_id: @file_id) do |f|
        @file_info = f
      end
      raise "Upload::status(): Failed to get figshare file record" if @file_info.nil?
    end
   
    # Creates a new Figshare file record, in the figshare article, and we get the file_id from the upload URL
    # file status == 'created'
    #
    private def initiate_new_upload
      md5, size = Upload.get_file_check_data(@file_name)
      args = {'name' => File.basename(@file_name),
              'md5' => md5,
              'size'=> size
             }
      post( api_query: "account/articles/#{@article_id}/files", args: args ) do |f|
        @file_id = f['location'].gsub(/^.*\/([0-9]+)$/, '\1')
      end
      raise "Upload::initiate_new_upload(): failed to create Figshare file record" if @file_id.nil?
    end
   
    # Gets the Figshare file info
    # We need the upload URLs to continue
    #
    private def get_file_info
      status
      @upload_host = @file_info['upload_url'].gsub(/^http.*\/\/(.*)\/upload.*$/, '\1')
      @upload_query = @file_info['upload_url'].gsub(/^http.*\/\/(.*)\/(upload.*)$/, '\2')
      puts "Upload_host: #{@upload_host} URL: #{@upload_query}" if @trace > 1
    end

    # Completes the upload.
    # Figshare then calculates the md5 in the background, which may take a while to complete
    # And sometimes the checksum never gets calculated, and is left blank.
    #
    private def complete_upload
      post( api_query: "account/articles/#{@article_id}/files/#{@file_id}" )
      puts "complete_upload" if trace > 1
    end

    # Get the upload settings
    #
    private def get_upload_parts_details
      @upload_parts_detail = nil
      result = nil
      WIKK::WebBrowser.https_session( host: @upload_host, verify_cert: false ) do |ws|
        result = ws.get_page( query: @upload_query,
                              authorization: "token #{@auth_token}",
                            )
      end
      raise "get_upload_parts_detail(#{@article_id}) failed to get upload URL" if result.nil?
      @upload_parts_detail = JSON.parse(result)
      
      puts "Part URL #{@upload_parts_detail['parts']}" if @trace > 1
    end

    # Upload the file in parts
    #
    private def upload_the_parts
      parts = @upload_parts_detail['parts']
      File.open(@file_name, 'rb') do |fin|
        parts.each do |part|
          data = fin.read(part['endOffset'] - part['startOffset'] + 1)
          upload_part(buffer: data, part: part['partNo'])
        end
      end
    end

    # Upload just one part
    #
    private def upload_part(buffer:, part:)
      puts "upload_part(#{part})" if @trace > 1
      WIKK::WebBrowser.https_session( host: @upload_host, verify_cert: false ) do |ws|
        ws.put_req( query: "#{@upload_query}/#{part}",
                    authorization: "token #{@auth_token}",
                    data: buffer
                  )
      end
    end

  end
end