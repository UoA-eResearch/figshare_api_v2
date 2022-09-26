module Figshare
  # Figshare public colections api calls
  #
  class PublicCollections < Base
    # Requests a list of public collections
    #
    # @param institution [Boolean] Just our institution
    # @param group_id [Integer] Only return this group's collections
    # @param published_since [Time] Return results if published after this time
    # @param modified_since [Time] Return results if modified after this time
    # @param resource_doi [String] Matches this resource doi
    # @param doi [String] Matches this doi
    # @param handle [String] Matches this handle
    # @param order [String] "published_date" Default, "modified_date", "views", "cites", "shares"
    # @param order_direction [String] "desc" Default, "asc"
    # @param page [Numeric] Pages start at 1. Page and Page size go together
    # @param page_size [Numeric]
    # @param offset [Numeric] offset is 0 based.  Offset and Limit go together
    # @param limit [Numeric]
    # @yield [Hash] {id, title, doi, handle, url, published_date}
    def list( institution: false,
              group_id: nil,
              published_since: nil,
              modified_since: nil,
              resource_doi: nil,
              doi: nil,
              handle: nil,
              order: 'published_date',
              order_direction: 'desc',
              page: nil,
              page_size: nil,
              offset: nil,
              limit: nil,
              &block
            )
      args = {}
      args['institution'] = @institute_id.to_i if institute
      args['group'] = group_id unless group_id.nil?
      args['resource_doi'] = resource_doi unless resource_doi.nil?
      args['doi'] = doi unless doi.nil?
      args['handle'] = handle unless handle.nil?
      args['published_since'] = published_since unless published_since.nil?
      args['modified_since'] = modified_since unless modified_since.nil?
      args['order'] = order unless order.nil?
      args['order_direction'] = order_direction unless order_direction.nil?
      args['page'] = page unless page.nil?
      args['page_size'] = page_size unless page_size.nil?
      args['offset'] = offset unless offset.nil?
      args['limit'] = limit unless limit.nil?
      get_paginate(api_query: 'collections', args: args, &block)
    end

    # Search within the public collections
    #
    # @param institution [Boolean] Just our institution
    # @param group_id [Integer] Only return this group's collections
    # @param published_since [Time] Return results if published after this time
    # @param modified_since [Time] Return results if modified after this time
    # @param resource_doi [String] Matches this resource doi
    # @param doi [String] Matches this doi
    # @param handle [String] Matches this handle
    # @param order [String] "published_date" Default, "modified_date", "views", "cites", "shares"
    # @param order_direction [String] "desc" Default, "asc"
    # @yield [Hash] {id, title, doi, handle, url, published_date}
    def search( search_for:,
                institute: false,
                group_id: nil,
                published_since: nil,
                modified_since: nil,
                item_type: nil,
                resource_doi: nil,
                doi: nil,
                handle: nil,
                order: 'published_date',
                order_direction: 'desc',
                &block
              )
      args = { 'search_for' => search_for }
      args['institution'] = @institute_id.to_i if institute
      args['group_id'] = group_id unless group_id.nil?
      args['item_type'] = item_type unless item_type.nil?
      args['resource_doi'] = resource_doi unless resource_doi.nil?
      args['doi'] = doi unless doi.nil?
      args['handle'] = handle unless handle.nil?
      args['published_since'] = published_since unless published_since.nil?
      args['modified_since'] = modified_since unless modified_since.nil?
      args['order'] = order unless order.nil?
      args['order_direction'] = order_direction unless order_direction.nil?
      post(api_query: 'account/articles/search', args: args, &block)
    end

    # Get details of specific collection (default version)
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @yield [Hash] See figshare api docs
    def detail(collection_id:, &block)
      get(api_query: "collections/#{collection_id}", &block)
    end

    # Return details of a list of public collection Versions
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @yield [Hash] See figshare api docs
    def versions(collection_id:, &block)
      get(api_query: "collections/#{collection_id}/versions", &block)
    end

    # Get details of specific collection version
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param version_id [Integer] Figshare id of the collection's version
    # @param page [Numeric] Pages start at 1. Page and Page size go together
    # @param page_size [Numeric]
    # @param offset [Numeric] offset is 0 based.  Offset and Limit go together
    # @param limit [Numeric]
    # @yield [Hash] See figshare api docs
    def version_detail(collection_id:, version_id:, &block)
      get(api_query: "collections/#{collection_id}/versions/#{version_id}", &block)
    end

    # Get details of list of articles for a specific collection
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @yield [Hash] {id, title, doi, handle, url, published_date}
    def articles( collection_id:,
                  page: nil,
                  page_size: nil,
                  offset: nil,
                  limit: nil,
                  &block
                )
      args = {}
      args['page'] = page unless page.nil?
      args['page_size'] = page_size unless page_size.nil?
      args['offset'] = offset unless offset.nil?
      args['limit'] = limit unless limit.nil?
      get_paginate(api_query: "collections/#{collection_id}/articles", args: args, &block)
    end
  end
end
