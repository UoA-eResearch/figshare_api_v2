module Figshare
  require 'digest'

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

    def upload(article_id:, file_name:)
      @file_name = file_name
      @article_id = article_id
      
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

    def status()
      result = nil
      WIKK::WebBrowser.https_session( host: @figshare.hostname, verify_cert: false ) do |ws|
        result = ws.get_page( query: "#{@figshare.api_url}account/articles/#{@article_id}/files/#{@file_id}",
                              authorization: "token #{@figshare.auth_token}"
                            )
      end
      return if result.nil? # got no results
      @file_info = JSON.parse(result)
    end
   
    #Creates a file record, in the figshare article, and we get the file_id from the upload URL
    private def initiate_new_upload()
        md5, size = Figshare_upload.get_file_check_data(@file_name)
        data = {'name' => File.basename(@file_name),
                'md5' => md5,
                'size'=> size}

        #Sets up the file record, and return
        # s the upload URL
        result = nil
        WIKK::WebBrowser.https_session( host: @figshare.hostname, verify_cert: false ) do |ws|
          result = ws.post_page( query: "#{@figshare.api_url}account/articles/#{@article_id}/files",
                                authorization: "token #{@figshare.auth_token}",
                                content_type: 'application/json; charset=UTF-8',
                                data: data.to_json
                              )
        end
        return if result.nil? # got no results
        result = JSON.parse(result)
        #puts 'Initiated file upload:'
        #p result
      
        @file_id = result['location'].gsub(/^.*\/([0-9]+)$/, '\1')
        #puts "File ID #{@file_id}"
     end
   
     private def get_file_info()
        #Gets the part size
        result = nil
        WIKK::WebBrowser.https_session( host: @figshare.hostname, verify_cert: false ) do |ws|
          result = ws.get_page( query: "#{@figshare.api_url}account/articles/#{@article_id}/files/#{@file_id}",
                                authorization: "token #{@figshare.auth_token}"
                              )
        end
        return if result.nil? # got no results
        @file_info = JSON.parse(result)
        @upload_host = @file_info['upload_url'].gsub(/^http.*\/\/(.*)\/upload.*$/, '\1')
        @upload_query = @file_info['upload_url'].gsub(/^http.*\/\/(.*)\/(upload.*)$/, '\2')
        #p "File Info: #{@file_info}"
    end

    private def complete_upload()
      WIKK::WebBrowser.https_session( host: @figshare.hostname, verify_cert: false ) do |ws|
          result = ws.post_page( query: "#{@figshare.api_url}account/articles/#{@article_id}/files/#{@file_id}",
                      authorization: "token #{@figshare.auth_token}"
                    )
      end
    end

    private def get_upload_parts_details ()  
      result = nil
      WIKK::WebBrowser.https_session( host: @upload_host, verify_cert: false ) do |ws|
        result = ws.get_page( query: @upload_query,
                              authorization: "token #{@figshare.auth_token}",
                            )
      end
      @upload_parts_detail  = JSON.parse(result)
      #p @upload_parts_detail 
    end

    private def upload_the_parts()
      #puts "Uploading parts: to #{@upload_url}"
      parts = @upload_parts_detail ['parts']
      File.open(@file_name, 'rb') do |fin|
        parts.each_with_index do |part, i|
          data = fin.read(part['endOffset'] - part['startOffset'] + 1)
          upload_part(buffer: data, part: i + 1)
        end
      end
    end

    private def upload_part(buffer:, part:)
      #puts "In upload part #{part}"
  
      WIKK::WebBrowser.https_session( host: @upload_host, verify_cert: false ) do |ws|
        ws.put_req( query: "#{@upload_query}/#{part}",
                    authorization: "token #{@figshare.auth_token}",
                    data: buffer
                  )
      end
    end

  end
end