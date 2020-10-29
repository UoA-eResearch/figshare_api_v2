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
    # @yield [Hash] {id, title, doi, handle, url, published_date}
    def list(institution: false, group_id: nil,
                    published_since: nil, modified_since: nil, 
                    resource_doi: nil, doi: nil, handle: nil,  
                    order: 'published_date', order_direction: 'desc',
                    &block
                  )
      args = {}
      args['institution'] = @institute_id  if ! institution.nil?
      args['group'] = group_id if ! group_id.nil?
      args['resource_doi'] = resource_doi if ! resource_doi.nil?
      args['doi'] = doi if ! doi.nil?
      args['handle'] = handle if ! handle.nil?
      args['published_since'] = published_since if ! published_since.nil?
      args['modified_since'] = modified_since if ! modified_since.nil?
      args['order'] = order if ! order.nil?
      args['order_direction'] = order_direction if ! order_direction.nil?
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
    def search( institute: false, group_id: nil,
                            published_since: nil, modified_since: nil, 
                            item_type: nil, resource_doi: nil, doi: nil, handle: nil,  
                            order: 'published_date', order_direction: 'desc',
                            search_for:,
                            &block
                          )
      args = { 'search_for' => search_for }
      args['institution'] = @institute_id if ! institute.nil?
      args['group_id'] = group_id if ! group_id.nil?
      args['item_type'] = item_type if ! item_type.nil?
      args['resource_doi'] = resource_doi if ! resource_doi.nil?
      args['doi'] = doi if ! doi.nil?
      args['handle'] = handle if ! handle.nil?
      args['published_since'] = published_since if ! published_since.nil?
      args['modified_since'] = modified_since if ! modified_since.nil?
      args['order'] = order if ! order.nil?
      args['order_direction'] = order_direction if ! order_direction.nil?
      post(api_query: 'account/articles/search', args: args, &block)
    end

    # Get details of specific collection (default version)
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @yield [Hash] See figshare api docs
    def detail(collection_id:, &block)
      get(api_query: "collections/#{collection_id}",  &block)
    end

    # Return details of a list of public collection Versions
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @yield [Hash] See figshare api docs
    def versions(collection_id:, &block)
      get(api_query: "collections/#{collection_id}/versions",  &block)
    end

    # Get details of specific collection version
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param version_id [Integer] Figshare id of the collection's version
    # @yield [Hash] See figshare api docs
    def version_detail(collection_id:, version_id:, &block)
      get(api_query: "collections/#{collection_id}/versions/#{version_id}",  &block)
    end
    
    # Get details of list of articles for a specific collection
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @yield [Hash] {id, title, doi, handle, url, published_date}
    def articles(collection_id:, &block)
      get_paginate(api_query: "collections/#{collection_id}/articles", &block)
    end
  end #of class
  
end #of module
