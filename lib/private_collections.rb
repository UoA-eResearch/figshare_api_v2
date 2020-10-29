module Figshare

  # Figshare Private Collections API
  #
  class PrivateCollections < Base
  
    # Requests a list of own (or institute's) collections
    #
    # @param order [String] "published_date" Default, "modified_date", "views", "cites", "shares"
    # @param order_direction [String] "desc" Default, "asc"
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] {id, title, doi, handle, url, published_date}
    def list(order: 'published_date', order_direction: 'desc', impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      args['order'] = order if ! order.nil?
      args['order_direction'] = order_direction if ! order_direction.nil?
      get_paginate(api_query: 'account/collections', args: args, &block)
    end

    # Search within the own (or institute's) collections
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
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] {id, title, doi, handle, url, published_date}
    def search(institute: false, group_id: nil, impersonate: nil, 
                              published_since: nil, modified_since: nil, 
                              resource_doi: nil, doi: nil, handle: nil,  
                              order: 'published_date', order_direction: 'desc',
                              search_for:,
                              &block
                             )
      args = { 'search_for' => search_for }
      args["impersonate"] = impersonate  if ! impersonate.nil?
      args['institution'] = @institute_id if ! institute.nil?
      args['group_id'] = group_id if ! group_id.nil?
      args['resource_doi'] = resource_doi if ! resource_doi.nil?
      args['doi'] = doi if ! doi.nil?
      args['handle'] = handle if ! handle.nil?
      args['published_since'] = published_since if ! published_since.nil?
      args['modified_since'] = modified_since if ! modified_since.nil?
      args['order'] = order if ! order.nil?
      args['order_direction'] = order_direction if ! order_direction.nil?
      post(api_query: 'account/collections/search', args: args, &block)
    end
  
    # Create a new private Collection by sending collection information
    #
    # @param body [Hash] See Figshare API docs
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def create(body:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      post(api_query: "account/collections", args: args, data: body, &block)
    end

    # Delete a private collection
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def collection_delete(collection_id:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      delete( api_query: "account/collections/#{collection_id}/files/#{file_id}", args: args, &block )
    end

    # Return details of specific collection (default version)
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] See figshare api docs
    def detail(collection_id:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      get(api_query: "account/collections/#{collection_id}", args: args, &block)
    end
  
    # Create a new private Collection by sending collection information
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param body [Hash] See Figshare API docs
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def update(collection_id:, body:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      put(api_query: "account/collections", args: args, data: body, &block)
    end  
    
    # Reserve DOI for collection
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] { doi }
    def reserve_doi(collection_id:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      post(api_query: 'account/collections/#{collection_id}/reserve_doi', args: args, &block)
    end

    # Reserve Handle for collection
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] { handle }
    def reserve_handle(collection_id:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      post(api_query: 'account/collections/#{collection_id}/reserve_handle', args: args, &block)
    end

    # When a collection is published, a new public version will be generated. 
    # Any further updates to the collection will affect the private collection data. 
    # In order to make these changes publicly visible, an explicit publish operation is needed.
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] { location }
    def publish(collection_id:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      post(api_query: 'account/collections/#{collection_id}/publish', args: args, &block)
    end

    # Yield collections authors
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] {id, full_name, is_active, url_name, orcid_id}
    def authors(article_id, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      get(api_query: "account/collections/#{collection_id}/authors", args: args, &block)
    end

    # Associate new authors with the collection. This will add new authors to the list of already associated authors
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param authors [Array] Can be a mix of { id } and/or { name }
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] { location }
    def authors_add(article_id, impersonate: nil, authors:)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      post(api_query: "account/collections/#{collection_id}/authors", args: args, data: {"authors" => authors}, &block)
    end
    
    # Replace existing authors list with a new list
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param authors [Array] Can be a mix of { id } and/or { name }
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def authors_replace(article_id, impersonate: nil, authors:)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      put(api_query: "account/collections/#{collection_id}/authors", args: args, data: {"authors" => authors}, &block)
    end
    
    # Remove author from the collection
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param author_id [Integer] Figshare id for the author
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def author_delete(collection_id:, impersonate: nil, author_id:)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      delete(api_query: "account/collections/#{collection_id}/authors/#{author_id}", args: args, &block)
    end
  
    # Yield collection categories
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] {parent_id, id, title}
    def categories(collection_id:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      get(api_query: 'account/collections/#{collection_id}/categories', args: args, &block)
    end
    
    # Associate new categories with the collection. 
    # This will add new categories to the list of already associated categories
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param categories [Array] [ categorie_id, ... ]
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] { location }
    def categories_add(collection_id:, categories:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      post(api_query: "account/collections/#{collection_id}/categories", args: args, data: { 'categories' => categories }, &block)
    end

    # Associate new categories with the collection. This will remove all already associated categories and add these new ones
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param categories [Array] [ categorie_id, ... ]
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def categories_replace(collection_id:, categories:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      put(api_query: "account/collections/#{collection_id}/categories", args: args, data: { 'categories' => categories }, &block)
    end

    #  Delete category from collection's categories
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param category_id [Integer] Figshare id of the category
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def categories_delete(collection_id:, category_id:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      delete(api_query: "account/collections/#{collection_id}/categories/#{category_id}", args: args, &block)
    end

    # Yield collection articles
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] See Figshare API docs
    def articles(collection_id:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      get(api_query: "account/collections/#{collection_id}/articles", args: args, &block)
    end
  
    # Get a private article's details (Not a figshare API call. Duplicates PrivateArticles:article_detail)
    #
    # @param article_id [Integer] Figshare id of the article
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def article_detail(article_id:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      get(api_query: "account/articles/#{article_id}", args: args, &block)
    end

    # Associate new articles with the collection. This will add new articles to the list of already associated articles
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param articles [Array] array of Figshare article ids
 # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] { location }
    def articles_add(collection_id:, articles: , impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      post( api_query: "account/collections/#{collection_id}/articles/#{article_id}", args: args, data: { "articles": articles}, &block)
    end
    
    # Get a private article's details (Not a figshare API call. Duplicates PrivateArticles:article_detail)
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param articles [Array] array of Figshare article ids
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def articles_replace(collection_id:, articles:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      put( api_query: "account/collections/#{collection_id}/articles/#{article_id}", args: args, data: { "articles": articles}, &block)
    end
    
    # Get a private article's details (Not a figshare API call. Duplicates PrivateArticles:article_detail)
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param article_id [Integer] Figshare id of the article
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def article_delete(collection_id:, article_id: , impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      delete( api_query: "account/collections/#{collection_id}/articles/#{article_id}", args: args, &block)
    end
    
    # List private links
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] {id, is_active, expires_date}
    def links(collection_id:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      get(api_query: "account/collections/#{collection_id}/private_links", args: args, &block)
    end
  
    # Create new private link for this collection
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param private_link [Hash] { expires_date, read_only }
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] { location }
    def link_create(collection_id:, private_link:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      post(api_query: "account/collections/#{collection_id}/private_links", args: args, data: private_link, &block)
    end

    # Disable/delete private link for this collection
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param link_id [Integer] 
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def link_delete(collection_id:, link:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      delete(api_query: "account/collections/#{collection_id}/private_links/#{link_id}", args: args, &block)
    end
  
    # Update private link for this collection
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param private_link [Hash] { expires_date, read_only }
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def link_update(collection_id:, link_id:, private_link:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      put(api_query: "account/collections/#{collection_id}/private_links/#{link_id}", args: args, data: private_link, &block)
    end
    
  end
end