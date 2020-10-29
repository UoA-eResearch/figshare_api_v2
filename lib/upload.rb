module Figshare
  require 'digest'

  # Upload files to figshare
  # Nb. This can sometimes fail, so you need to check the md5 to ensure the file got there
  #     It can take a short while for the md5 to be calculated, so upload, wait, then check.
  #
  class Upload < Base
    CHUNK_SIZE = 1048576
    attr_accessor :file_info, :upload_query, :upload_host, :upload_parts_detail , :file_id, :article_id, :file_name
  
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
    def upload(article_id:, file_name:)
      @article_id = article_id
      @file_name = file_name
      
      @file_id = nil
      @file_info = nil
      @upload_query = nil
      @upload_host = nil
      @upload_parts_detail  = nil
      
      initiate_new_upload() 
      get_file_info()
      get_upload_parts_details ()
      upload_the_parts()
      complete_upload()
    end
    
    # Get status of the current upload. 
    # Just fetches the file record from figshare.
    # Of interest is the status field, and the computed_md5 field
    #
    # @return [Hash] Figshare file record, or nil, if the call fails
    def status()
      @file_info = nil
      get(api_query: "account/articles/#{@article_id}/files/#{@file_id}") do |f|
        @file_info = f
      end
      raise "Upload::status(): Failed to get figshare file record" if @file_info.nil?
    end
   
    #Creates a new Figshare file record, in the figshare article, and we get the file_id from the upload URL
    #
    private def initiate_new_upload()
      md5, size = Figshare_upload.get_file_check_data(@file_name)
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
    private def get_file_info()
      status
      @upload_host = @file_info['upload_url'].gsub(/^http.*\/\/(.*)\/upload.*$/, '\1')
      @upload_query = @file_info['upload_url'].gsub(/^http.*\/\/(.*)\/(upload.*)$/, '\2')
    end

    # Completes the upload.
    # Figshare then calculates the md5 in the background, which may take a while to complete
    # And sometimes the checksum never gets calculated, and is left blank.
    #
    private def complete_upload()
      post( api_query: "account/articles/#{@article_id}/files/#{@file_id}")
    end

    # Get the upload settings
    #
    private def get_upload_parts_details ()  
      result = nil
      WIKK::WebBrowser.https_session( host: @upload_host, verify_cert: false ) do |ws|
        result = ws.get_page( query: @upload_query,
                              authorization: "token #{@auth_token}",
                            )
      end
      @upload_parts_detail  = JSON.parse(result)
    end

    # Upload the file in parts
    #
    private def upload_the_parts()
      parts = @upload_parts_detail ['parts']
      File.open(@file_name, 'rb') do |fin|
        parts.each_with_index do |part, i|
          data = fin.read(part['endOffset'] - part['startOffset'] + 1)
          upload_part(buffer: data, part: i + 1)
        end
      end
    end

    # Upload just one part
    #
    private def upload_part(buffer:, part:)  
      WIKK::WebBrowser.https_session( host: @upload_host, verify_cert: false ) do |ws|
        ws.put_req( query: "#{@upload_query}/#{part}",
                    authorization: "token #{@auth_token}",
                    data: buffer
                  )
      end
    end

  end
end