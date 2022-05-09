module Figshare
  # Figshare Private Collections API
  #
  class PrivateCollections < Base
    # Requests a list of own (or institute's) collections
    #
    # @param order [String] "published_date" Default, "modified_date", "views", "cites", "shares"
    # @param order_direction [String] "desc" Default, "asc"
    # @param page [Numeric] Pages start at 1. Page and Page size go together
    # @param page_size [Numeric]
    # @param offset [Numeric] offset is 0 based.  Offset and Limit go together
    # @param limit [Numeric]
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] {id, title, doi, handle, url, timeline: {...}, published_date} see docs.figshare.com
    def list( order: 'published_date',
              order_direction: 'desc',
              page: nil,
              page_size: nil,
              offset: nil,
              limit: nil,
              impersonate: nil,
              &block
            )
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      args['order'] = order unless order.nil?
      args['order_direction'] = order_direction unless order_direction.nil?
      args['page'] = page unless page.nil?
      args['page_size'] = page_size unless page_size.nil?
      args['offset'] = offset unless offset.nil?
      args['limit'] = limit unless limit.nil?
      get_paginate(api_query: 'account/collections', args: args, &block)
    end

    # Search within the own (or institute's) collections
    #
    # @param institution [Boolean] Just our institution
    # @param group_id [Integer] Only return this group's collections
    # @param published_since [Time] Return results if published after this time
    # @param modified_since [Time] Return results if modified after this time
    # @param resource_id [String] Matches this resource id
    # @param resource_doi [String] Matches this resource doi
    # @param doi [String] Matches this doi
    # @param handle [String] Matches this handle
    # @param order [String] "published_date" Default, "modified_date", "views", "cites", "shares"
    # @param order_direction [String] "desc" Default, "asc"
    # @param page [Numeric] Pages start at 1. Page and Page size go together
    # @param page_size [Numeric]
    # @param offset [Numeric] offset is 0 based.  Offset and Limit go together
    # @param limit [Numeric]
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] {id, title, doi, handle, url, published_date}
    def search( search_for:,
                institute: false,
                group_id: nil,
                impersonate: nil,
                published_since: nil,
                modified_since: nil,
                resource_id: nil,
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
      args = { 'search_for' => search_for }
      args['impersonate'] = impersonate unless impersonate.nil?
      args['institution'] = @institute_id unless institute.nil?
      args['group'] = group_id unless group_id.nil?
      args['resource_id'] = resource_id unless resource_id.nil?
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
      post(api_query: 'account/collections/search', args: args, &block)
    end

    # Create a new private Collection by sending collection information
    #
    # @param body [Hash] See Figshare API docs
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def create(body:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      post(api_query: 'account/collections', args: args, data: body, &block)
    end

    # Delete a private collection
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def collection_delete(collection_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      delete( api_query: "account/collections/#{collection_id}", args: args, &block )
    end

    # Return details of specific collection (default version)
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] See figshare api docs
    def detail(collection_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      get(api_query: "account/collections/#{collection_id}", args: args, &block)
    end

    # Create a new private Collection by sending collection information
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param body [Hash] See Figshare API docs
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def update(collection_id:, body:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      put(api_query: "account/collections/#{collection_id}", args: args, data: body, &block)
    end

    # Reserve DOI for collection
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] { doi }
    def reserve_doi(collection_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      post(api_query: "account/collections/#{collection_id}/reserve_doi", args: args, &block)
    end

    # Reserve Handle for collection
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] { handle }
    def reserve_handle(collection_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      post(api_query: "account/collections/#{collection_id}/reserve_handle", args: args, &block)
    end

    # Collection Resource
    #
    # @param collection_id [Integer]
    # @param id [Integer]
    # @param title [String]
    # @param doi [String]
    # @param link [String]
    # @param status [String] 'frozen', ...
    # @param version [Integer]
    # @yield [Hash] { location: "string" }
    def collection_resource(collection_id:, title:, id: nil, doi: nil, link: nil, status: nil, version: nil, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      resource = {}
      resource['title'] = title
      resource['id'] = id unless id.nil?
      resource['doi'] = doi unless doi.nil?
      resource['link'] = link unless link.nil?
      resource['status'] = status unless status.nil?
      resource['version'] = version unless version.nil?
      post(api_query: "account/collections/#{collection_id}/resource", args: args, data: resource, &block)
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
      args['impersonate'] = impersonate unless impersonate.nil?
      post(api_query: "account/collections/#{collection_id}/publish", args: args, &block)
    end

    # Yield collections authors
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] {id, full_name, is_active, url_name, orcid_id}
    def authors(collection_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      get(api_query: "account/collections/#{collection_id}/authors", args: args, &block)
    end

    # Associate new authors with the collection. This will add new authors to the list of already associated authors
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param authors [Array] Can be a mix of { id } and/or { name }
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] { location }
    def authors_add(collection_id:, authors:, impersonate: nil)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      post(api_query: "account/collections/#{collection_id}/authors", args: args, data: { 'authors' => authors }, &block)
    end

    # Replace existing authors list with a new list
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param authors [Array] Can be a mix of { id } and/or { name }
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def authors_replace(collection_id:, authors:, impersonate: nil)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      put(api_query: "account/collections/#{collection_id}/authors", args: args, data: { 'authors' => authors }, &block)
    end

    # Remove author from the collection
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param author_id [Integer] Figshare id for the author
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def author_delete(collection_id:, author_id:, impersonate: nil)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      delete(api_query: "account/collections/#{collection_id}/authors/#{author_id}", args: args, &block)
    end

    # Yield collection categories
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] {parent_id, id, title, path, source_id, taxonomy_id}
    def categories(collection_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      get(api_query: "account/collections/#{collection_id}/categories", args: args, &block)
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
      args['impersonate'] = impersonate unless impersonate.nil?
      post(api_query: "account/collections/#{collection_id}/categories", args: args, data: { 'categories' => categories }, &block)
    end

    # Associate new categories with the collection. This will remove all already associated categories and add these new ones
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param categories [Array] [ categorie_id, ... ]
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def categories_replace(collection_id:, categories:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      put(api_query: "account/collections/#{collection_id}/categories", args: args, data: { 'categories' => categories }, &block)
    end

    #  Delete category from collection's categories
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param category_id [Integer] Figshare id of the category
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def categories_delete(collection_id:, category_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      delete(api_query: "account/collections/#{collection_id}/categories/#{category_id}", args: args, &block)
    end

    # Yield collection articles
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] See Figshare API docs
    def articles(collection_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      get(api_query: "account/collections/#{collection_id}/articles", args: args, &block)
    end

    # Get a private article's details (Not a figshare API call. Duplicates PrivateArticles:article_detail)
    #
    # @param article_id [Integer] Figshare id of the article
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def article_detail(article_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      get(api_query: "account/articles/#{article_id}", args: args, &block)
    end

    # Associate new articles with the collection. This will add new articles to the list of already associated articles
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param articles [Array] array of Figshare article ids
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] { location }
    def articles_add(collection_id:, articles:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      post( api_query: "account/collections/#{collection_id}/articles", args: args, data: { articles: articles }, &block)
    end

    # Get a private article's details (Not a figshare API call. Duplicates PrivateArticles:article_detail)
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param articles [Array] array of Figshare article ids
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def articles_replace(collection_id:, articles:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      put( api_query: "account/collections/#{collection_id}/articles", args: args, data: { articles: articles }, &block)
    end

    # Get a private article's details (Not a figshare API call. Duplicates PrivateArticles:article_detail)
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param article_id [Integer] Figshare id of the article
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def article_delete(collection_id:, article_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      delete( api_query: "account/collections/#{collection_id}/articles/#{article_id}", args: args, &block)
    end

    # List private links
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] {id:, is_active:, expires_date:, html_location: }
    def links(collection_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      get(api_query: "account/collections/#{collection_id}/private_links", args: args, &block)
    end

    # Create new private link for this collection
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param expires_date [Time]
    # @param read_only [Boolean]
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] { location:, html_location:, token: }
    def link_create(collection_id:, expires_date: nil, read_only: true, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      link_properties = {}
      link_properties['expires_date'] = expires_date.iso8601 unless expires_date.nil?
      link_properties['read_only'] = read_only unless read_only.nil?
      post(api_query: "account/collections/#{collection_id}/private_links", args: args, data: link_properties, &block)
    end

    # Disable/delete private link for this collection
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param link_id [Integer]
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def link_delete(collection_id:, link_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      delete(api_query: "account/collections/#{collection_id}/private_links/#{link_id}", args: args, &block)
    end

    # Update private link for this collection
    #
    # @param collection_id [Integer] Figshare id of the collection
    # @param expires_date [Time]
    # @param read_only [Boolean]
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def link_update(collection_id:, link_id:, expires_date: nil, read_only: true, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      link_properties = {}
      link_properties['expires_date'] = expires_date.iso8601 unless expires_date.nil?
      link_properties['read_only'] = read_only unless read_only.nil?
      put(api_query: "account/collections/#{collection_id}/private_links/#{link_id}", args: args, data: link_properties, &block)
    end
  end
end
