module Figshare
  # Supporting web calls to the API
  #
  class Base
    attr_accessor :auth_token
    attr_accessor :base_dir
    attr_accessor :article_index_file
    attr_accessor :hostname
    attr_accessor :api_url
    attr_accessor :institute_id

    # Init reads the Json configuration files, setting @course_codes_to_faculty and @academic_department_code_to_faculty
    # Opens a connection to the LDAP server, setting @ldap for other methods to use.
    #
    # @param figshare_user [String] figshare user, in the figshare_keys.json
    # @param conf_dir [String|nil] directory for figshare_keys.json and figshare_site_params.json
    # @param key_file [String|nil] conf_dir/figshare_keys.json if nil
    # @param conf_file [String|nil] conf_dir/figshare_site_params.json if nil
    def initialize(figshare_user:, conf_dir: nil, key_file: nil, conf_file: nil)
      raise 'Figshare_api_v2.initialize: Need to specify the conf_dir if key_file or conf_file are nil' if conf_dir.nil? && (key_file.nil? || conf_file.nil?)

      conf_file ||= "#{conf_dir}/figshare_site_params.json"
      key_file ||= "#{conf_dir}/figshare_keys.json"

      figshare_token = load_json_file(key_file)
      @auth_token = figshare_token[figshare_user]

      figshare_site_params = load_json_file(conf_file)

      @hostname = figshare_site_params['host']
      @api_url = figshare_site_params['api_url']
      @institute_id = figshare_site_params['institute_id']
    end

    # Parse the config file
    #
    # @param filename [String] config file name to parse
    # @return [Hash|Array] parsed json configuration file.
    private def load_json_file(filename)
      JSON.parse(File.read(filename))
    end

    # get iterates through the API response, yielding each value to the passed block
    # When Figshare API usually has no paging option.
    # If there is no block, then the results are printed (useful for debugging)
    #
    # @param api_query [String] base figshare api call, to which we add parameters defined in args
    # @param args [Hash] Key, value pairs which get converted to ?key=arg&key=arg...
    # @param debug [Boolean] print result to stdout
    # @yield [String] if given a block, iterates through the result from figshare
    # @return [Integer] number of results.
    private def get(api_query:, args: {}, debug: false, &block)
      content_type = response = nil
      WIKK::WebBrowser.https_session( host: @hostname, verify_cert: false ) do |ws|
        response = ws.get_page( query: "#{@api_url}#{api_query}",
                                authorization: "token #{@auth_token}",
                                form_values: args
                              )
        content_type = ws.header_value(key: 'Content-Type')
      end
      return iterate_json_response(response: response, content_type: content_type, debug: debug, &block)
    end

    # get_paginate iterates through the API response, yielding each value to the passed block, fetching new pages ,as needed.
    # Figshare API usually has the option of page and page_size parameters, to help with large downloads.
    # If there is no block, then the results are printed (useful for debugging)
    #
    # @param api_query [String] base figshare api call, to which we add parameters defined in args
    # @param args [Hash] Key, value pairs which get converted to ?key=arg&key=arg...
    # @param debug [Boolean] print result to stdout
    # @param by_offset [Boolean] use offset/limit rather than page/page_size in API calls
    # @yield [String] if given a block, iterates through the result from figshare
    # @return [Integer] number of results.
    private def get_paginate(api_query:, args: {}, debug: false, by_offset: false, &block)
      args = {} if args.nil?
      if ! args.is_a?(Hash)
        raise 'get_paginate(): Expecting args to be a Hash'
      end

      offset = 0
      page = 1
      limit = page_size = 100
      result_count = 0
      loop do
        content_type = response = nil
        form_args = by_offset ? { 'limit' => limit, 'offset' => offset } : { 'page_size' => page_size, 'page' => page }
        WIKK::WebBrowser.https_session( host: @hostname, verify_cert: false ) do |ws|
          response = ws.get_page( query: "#{@api_url}#{api_query}",
                                  authorization: "token #{@auth_token}",
                                  form_values: form_args.merge(args)
                                )
          content_type = ws.header_value(key: 'Content-Type')
        end
        page_count = iterate_json_response(response: response, content_type: content_type, debug: debug, &block)
        result_count += page_count
        break if page_count < page_size # Got less results than we asked for, so it was the last page

        page += 1 # Ready to fetch next page
        offset += limit # if we use offset, then mor
      end

      return result_count
    end

    # post iterates through the API response, yielding each value to the passed block
    # When Figshare API usually has no paging option.
    # If there is no block, then the results are printed (useful for debugging)
    #
    # @param api_query [String] base figshare api call, to which we add parameters defined in args
    # @param args [Hash] Key, value pairs which get converted to ?key=arg&key=arg...
    # @param debug [Boolean] print result to stdout
    # @param content_type [String] Assuming Json, but might need binary ('application/octet-stream')
    # @yield [String] if given a block, iterates through the result from figshare
    # @return [Integer] number of results.
    private def post(api_query:, args: {}, data: nil, debug: false, content_type: 'application/json; charset=UTF-8', &block)
      body = nil
      body = if data.is_a?(Hash)
               # Convert hash to json, and merge in additional args
               data.merge(args).to_j
             elsif data.nil? && ! args.empty?
               # No data, but args, so just use the args
               args.to_j
             else
               # Data isn't a Hash, so just pass it through (might be nil)
               data
             end

      response = nil
      WIKK::WebBrowser.https_session( host: @hostname, verify_cert: false ) do |ws|
        response = ws.post_page(  query: "#{@api_url}#{api_query}",
                                  content_type: content_type,
                                  authorization: "token #{@auth_token}",
                                  data: body
                               )
        content_type = ws.header_value(key: 'Content-Type')
      end
      return iterate_json_response(response: response, content_type: content_type, debug: debug, &block)
    end

    # post_paginate iterates through the API response, yielding each value to the passed block, fetching new pages ,as needed.
    # Figshare API usually has the option of page and page_size parameters, to help with large downloads.
    # If there is no block, then the results are printed (useful for debugging)
    #
    # @param api_query [String] base figshare api call, to which we add parameters defined in args
    # @param args [Hash] Key, value pairs which get converted to ?key=arg&key=arg...
    # @param debug [Boolean] print result to stdout
    # @param by_offset [Boolean] use offset/limit rather than page/page_size in API calls
    # @yield [String] if given a block, iterates through the result from figshare
    # @return [Integer] number of results.
    private def post_paginate(api_query:, args: {}, debug: false, by_offset: false, &block)
      page = 1
      offset = 0
      limit = page_size = 100
      result_count = 0

      args = {} if args.nil?
      if ! args.is_a?(Hash)
        raise 'post_paginate(): Expecting args to be a Hash'
      end

      loop do
        content_type = response = nil
        form_args = by_offset ? { 'limit' => limit, 'offset' => offset } : { 'page_size' => page_size, 'page' => page }
        WIKK::WebBrowser.https_session( host: @hostname, verify_cert: false ) do |ws|
          response = ws.post_page(  query: "#{@api_url}#{api_query}",
                                    content_type: 'application/json; charset=UTF-8',
                                    authorization: "token #{@auth_token}",
                                    data: args.merge(form_args).to_j
                                 )
          content_type = ws.header_value(key: 'Content-Type')
        end
        page_count = iterate_json_response(response: response, content_type: content_type, debug: debug, &block)
        result_count += page_count
        break if page_count < page_size # Got less results than we asked for, so it was the last page

        page += 1 # Ready to fetch next page
        offset += limit # if we use offset
      end
      return result_count
    end

    # put iterates through the API response, yielding each value to the passed block
    # When Figshare API usually has no paging option.
    # If there is no block, then the results are printed (useful for debugging)
    #
    # @param api_query [String] base figshare api call, to which we add parameters defined in args
    # @param args [Hash] Key, value pairs which get converted to ?key=arg&key=arg...
    # @param debug [Boolean] print result to stdout
    # @param content_type [String] Assuming Json, but might need binary ('application/octet-stream')
    # @yield [String] if given a block, iterates through the result from figshare
    # @return [Integer] number of results
    private def put(api_query:, args: {}, data: nil, debug: false, content_type: 'application/json; charset=UTF-8', &block)
      body = nil
      body = if data.is_a?(Hash)
               # Convert hash to json, and merge in additional args
               data.merge(args).to_j
             elsif data.nil? && ! args.empty?
               # No data, but args, so just use the args
               args.to_j
             else
               # Data isn't a Hash, so just pass it through (might be nil)
               data
             end

      response = nil
      WIKK::WebBrowser.https_session( host: @hostname, verify_cert: false ) do |ws|
        response = ws.put_req( query: "#{@api_url}#{api_query}",
                               content_type: content_type,
                               authorization: "token #{@auth_token}",
                               data: body
                             )
        content_type = ws.header_value(key: 'Content-Type')
      end
      return iterate_json_response(response: response, content_type: content_type, debug: debug, &block)
    end

    # delete sends an HTML DELETE request.
    # We don't expect to get a response to this call.
    #
    # @param api_query [String] base figshare api call
    # @param debug [Boolean] print result to stdout
    # @yield [Hash] Unlikely to have a result from delete calls, but if we do, we see it here
    # @return [Integer] number of results (usually 0)
    private def delete(api_query:, args: {}, debug: false, content_type: 'application/json; charset=UTF-8', &block)
      response = nil
      WIKK::WebBrowser.https_session( host: @hostname, verify_cert: false ) do |ws|
        response = ws.delete_req( query: "#{@api_url}#{api_query}",
                                  authorization: "token #{@auth_token}",
                                  form_values: args
                                )
        content_type = ws.header_value(key: 'Content-Type')
      end
      return iterate_json_response(response: response, content_type: content_type, debug: debug, &block)
    end

    # For iterate through the api response
    #
    # @param response [String] response from the API call
    # @param content_type [String] From html response header
    # @param debug [Boolean] print result to stdout
    # @yield [Hash] each array member in the response (or the entire response, if not iteratable)
    private def iterate_json_response(response:, content_type:, debug: false )
      return 0 if response.nil? # got no responses

      if content_type =~ /application\/json/
        response_array = JSON.parse(response)
        # If we don't have an Array, turn the response into an Array so we can iterate over this one response.
        response_array = [ response_array ] unless response_array.instance_of?(Array)
        return 0 if response_array.empty? # got empty array of responses

        count = 0
        response_array.each do |r|
          yield r if block_given?
          p r if debug
          count += 1
        end

        return count
      else # just dump the entire response on the caller :)
        yield response if block_given?
        return response.length
      end
    end
  end
end
