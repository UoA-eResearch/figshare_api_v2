module Figshare
  # Misc Figshare API calls that they have classified as Other.
  #
  class Other < Base
    # Fetch item types
    #
    # @param group_id [Integer]
    # @yield [Array] [{id: 0, name:, string_id:, icon:, public_description:, is_selectable: , url_name: } ]
    def item_types(group_id:, &block)
      get(api_query: 'item_types', args: { 'group_id' => group_id }, &block)
    end

    # Search from funding records
    #
    # @param search_for [String] string to search for
    # @yield [Array] [{id, title, grant_code, funder_name, is_user_defined, url}]
    def search_funding(search_for:, &block)
      post(api_query: 'account/funding/search', args: { 'search_for' => search_for }, &block)
    end

    # Get Account information for current user
    #
    # @yield [Hash] {id, first_name, ...} see figshare API docs
    def private_account_info(impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      get(api_query: 'account', args: args, &block)
    end

    # Get public categories
    #
    # @yield [Array] [{parent_id:, id:, title:, path:, source_id:, taxonomy_id:}]
    def public_categories
      get(api_query: 'categories', &block)
    end

    # Get public licenses
    #
    # @yield [Array] [{value:, name:, url:}]
    def public_licenses
      get(api_query: 'licenses', &block)
    end

    # Get private licenses
    #
    # @yield [Array] [{value:, name:, url:}]
    def private_account_licenses
      get(api_query: 'account/licenses', &block)
    end

    # Download a file
    #
    # @param file_id [Integer] Figshare file id
    # @yield [Data] Binary data
    def public_file_download(file_id:, &block)
      get(api_query: "file/download/#{file_id}", &block)
    end
  end
end
