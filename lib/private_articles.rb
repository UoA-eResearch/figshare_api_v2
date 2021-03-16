module Figshare

  # Figshare private articles API
  #
  class PrivateArticles < Base
  
    # Get Own Articles (or private articles of others if institute is true)
    #
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] {id, title, doi, handle, url, published_date}
    def list(impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      get_paginate(api_query: 'account/articles', args: args, &block)
    end

    # Search within the private articles (our own, or the institutes)
    #
    # @param institution [Boolean] Just our institution
    # @param group_id [Integer] Only return this group's collections
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @param published_since [Time] Return results if published after this time
    # @param modified_since [Time] Return results if modified after this time
    # @param resource_doi [String] Matches this resource doi
    # @param item_type [String] Matches this item_type. See Figshare API docs for list (https://docs.figshare.com/#articles_list)
    # @param doi [String] Matches this doi
    # @param handle [String] Matches this handle
    # @param order [String] "published_date" Default, "modified_date", "views", "cites", "shares"
    # @param order_direction [String] "desc" Default, "asc"
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] {id, title, doi, handle, url, published_date}
    def search(institute: false, group_id: nil, impersonate: nil,
                              published_since: nil, modified_since: nil, 
                              item_type: nil, resource_doi: nil, doi: nil, handle: nil,  
                              order: 'published_date', order_direction: 'desc',
                              search_for:,
                              &block
                             )
      args = { 'search_for' => search_for }
      args["impersonate"] = impersonate  if ! impersonate.nil?
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
  
    # Create a body for use with create and update methods
    #
    # @param title [String] Required
    # @param description [String] The article description. In a publisher case, usually this is the remote article description
    # @param keywords [Array] List of tags (strings) to be associated with the article. Tags can be used instead
    # @param references [Array] List of links to be associated with the article (e.g ["http://link1", "http://link2", "http://link3"])
    # @param categories [Array] List of category ids to be associated with the article(e.g [1, 23, 33, 66])
    # @param authors [Array] List of authors to be associated with the article. The list can contain the following fields: id, name, first_name, last_name, email, orcid_id. If an id is supplied, it will take priority and everything else will be ignored. No more than 10 authors. For adding more authors use the specific authors endpoint. e.g. { "name" => "Joe X"} and or { "id" => 123 }
    # @param custom_fields [Hash] List of key, values pairs to be associated with the article. eg. { "key" => "value"}
    # @param defined_type [String] one of "figshare","media","dataset","poster","journal contribution", "presentation", "thesis", "software", "online resource", "preprint", "book", "conference contribution", "chapter", "peer review", "educational resource", "report", "standard", "composition", "funding", "physical object", "data management plan", "workflow", "monograph", "performance", "event", "service", "model", "registration"
    # @param funding [String] Grant number or funding authority
    # @param funding_list [Array] Funding creation / update items. eg {"id" => 0, "title" => "string"}
    # @param license [Integer] License id for this article.
    # @param doi [String] Not applicable for regular users. In an institutional case, make sure your group supports setting DOIs. This setting is applied by figshare via opening a ticket through our support/helpdesk system.
    # @param handle [String] Not applicable for regular users. In an institutional case, make sure your group supports setting Handles. This setting is applied by figshare via opening a ticket through our support/helpdesk system.
    # @param resource_doi [String] Not applicable to regular users. In a publisher case, this is the publisher article DOI.
    # @param resource_title [String] Not applicable to regular users. In a publisher case, this is the publisher article title.
    # @param timeline [Hash] Various timeline dates ie. { "firstOnline" => "date_string", "publisherPublication" => "date_string", "publisherAcceptance" => "date_string"},
    # @param group_id [Integer] Not applicable to regular users. This field is reserved to institutions/publishers with access to assign to specific groups
    def body(title:, description: nil, keywords: nil, references: nil, categories: nil, authors: nil, custom_fields: nil, defined_type: nil, funding: nil, funding_list: nil, license: nil, doi: nil, handle: nil, resource_doi: nil, resource_title: nil, timeline: nil, group_id: nil, contact: nil)
      _body = {
        'title' => title
      }
      _body['description'] = description unless description.nil? 
      _body['keywords'] = keywords unless keywords.nil? 
      _body['references'] = references unless references.nil? 
      _body['categories'] = categories unless categories.nil? 
      _body['authors'] = authors unless authors.nil? 
      _body['custom_fields'] = custom_fields unless custom_fields.nil? 
      _body['defined_type'] = defined_type unless defined_type.nil? 
      _body['funding'] = funding unless funding.nil? 
      _body['funding_list'] = funding_list unless funding_list.nil? 
      _body['license'] = license unless license.nil? 
      _body['doi'] = doi unless doi.nil? 
      _body['handle'] = handle unless handle.nil? 
      _body['resource_doi'] = resource_doi unless resource_doi.nil? 
      _body['resource_title'] = resource_title unless resource_title.nil? 
      _body['timeline'] = timeline unless timeline.nil? 
      _body['group_id'] = group_id unless group_id.nil?
      
      return _body
    end
  
    # Create a new Article by sending article information
    # The user calling the API (or impersonated user) looks to be added as an author, even if they aren't. 
    # A duplicate "Author" entry occurs when adding them explicitly
    #
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] { location }
    def create(body:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      post(api_query: "account/articles", args: args, data: body, &block)
    end

    # Delete an article (WARNING!!!!!)
    #
    # @param article_id [Integer] Figshare id of the article
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def article_delete(article_id:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      delete(api_query: "account/articles/#{article_id}",  args: args, &block)
    end

    # Get a private article's details
    #
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @param article_id [Integer] Figshare id of the article
    def detail(article_id:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      get(api_query: "account/articles/#{article_id}",  args: args, &block)
    end
  
    # Updating an article by passing body parameters
    #
    # @param article_id [Integer] Figshare id of the article
    # @param body [Hash] See API docs.
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def update(article_id:, body:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      put(api_query: "account/articles/#{article_id}", args: args, data: body, &block)
    end
  
    # Will lift the embargo for the specified article
    #
    # @param article_id [Integer] Figshare id of the article
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def embargo_delete(article_id:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      delete(api_query: "account/articles/#{article_id}/embargo", args: args, &block)
    end
  
    # Get a private article embargo details
    #
    # @param article_id [Integer] Figshare id of the article
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] {is_embargoed, embargo_date, embargo_reason}
    def embargo_detail(article_id:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      get(api_query: "account/articles/#{article_id}/embargo", args: args, &block)
    end
  
    # Updates an article embargo status.
    # Does not imply that the article will be published when the embargo will expire. 
    # You must explicitly call the publish endpoint to enable this functionality.
    #
    # @param article_id [Integer] Figshare id of the article
    # @param is_embargoed [Boolean]
    # @param embargo_data [Time] Still needs to be published, after this date
    # @param embargo_type [Integer]
    # @param embargo_reason [String]
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def embargo_update(article_id:, is_embargoed: true, embargo_date: , embargo_type: 'file', embargo_reason:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      embargo_record = {"is_embargoed" => is_embargoed,
                        "embargo_date" => embargo_date.strftime("%Y-%m-%dT%H:%M:%S"),
                        "embargo_type" => embargo_type,
                        "embargo_reason" => embargo_reason
                      }
      put(api_query: "account/articles/#{article_id}/embargo", args: args, data: embargo_record, &block)
    end

    # Publish an article
    # If the whole article is under embargo, it will not be published immediately, but when the embargo expires or is lifted.
    # When an article is published, a new public version will be generated. 
    # Any further updates to the article will affect the private article data. 
    # In order to make these changes publicly visible, an explicit publish operation is needed.
    #
    # @param article_id [Integer] Figshare id of the article
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def publish(article_id:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      post(api_query: "account/articles/#{article_id}/publish", args: args, &block)
    end
    
    # Reserve DOI for article
    #
    # @param article_id [Integer] Figshare id of the article
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def reserve_doi(article_id:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      post(api_query: "account/articles/#{article_id}/reserve_doi", args: args, &block)
    end
  
    # Reserve Handle for article
    #
    # @param article_id [Integer] Figshare id of the article
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def reserve_handle(article_id:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      post(api_query: "account/articles/#{article_id}/reserve_handle", args: args, &block)
    end
  
    # Yield articles authors
    #
    # @param article_id [Integer] Figshare id of the article
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] {id, full_name, is_active, url_name, orcid_id}
    def authors(article_id, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      get(api_query: "account/articles/#{article_id}/authors", args: args, &block)
    end

    # Associate new authors with the article. This will add new authors to the list of already associated authors
    #
    # @param article_id [Integer] Figshare id of the article
    # @param authors [Array] Can be a mix of { id } and/or { name }
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def authors_add(article_id:, authors:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      post(api_query: "account/articles/#{article_id}/authors", args: args, data: {"authors" => authors}, &block)
    end
    
    # Replace existing authors list with a new list
    #
    # @param article_id [Integer] Figshare id of the article
    # @param authors [Array] Can be a mix of { id } and/or { name }
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def authors_replace(article_id:, authors:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      put(api_query: "account/articles/#{article_id}/authors", args: args, data: {"authors" => authors}, &block)
    end
    
    # Remove author from the article
    #
    # @param article_id [Integer] Figshare id of the article
    # @param author_id [Integer] Figshare id for the author
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def author_delete(article_id:, author_id:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      delete(api_query: "account/articles/#{article_id}/authors/#{author_id}", args: args, &block)
    end
    
    # List categories for a specific article
    #
    # @param article_id [Integer] Figshare id of the article
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # yield [Hash] { parent_id, id, title }
    def categories(article_id:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      get(api_query: "account/articles/#{article_id}/categories",  args: args, &block)
    end
  
    # Associate new categories with the article. 
    # This will add new categories to the list of already associated categories
    #
    # @param article_id [Integer] Figshare id of the article
    # @param categories [Array] [ categorie_id, ... ]
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def categories_add(article_id:, categories:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      post(api_query: "account/articles/#{article_id}/categories", args: args, data: { 'categories' => categories }, &block)
    end
  
    # Associate new categories with the article. This will remove all already associated categories and add these new ones
    #
    # @param article_id [Integer] Figshare id of the article
    # @param categories [Array] [ categorie_id, ... ]
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def categories_replace(article_id:, categories:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      put(api_query: "account/articles/#{article_id}/categories", args: args, data: { 'categories' => categories }, &block)
    end
  
    #  Delete category from article's categories
    #
    # @param article_id [Integer] Figshare id of the article
    # @param category_id [Integer] Figshare id of the category
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def categories_delete(article_id:, category_id:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      delete(api_query: "account/articles/#{article_id}/categories/#{category_id}", args: args, &block)
    end
  
    # List private links
    #
    # @param article_id [Integer] Figshare id of the article
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] {id, is_active, expires_date}
    def links(article_id:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      get(api_query: "account/articles/#{article_id}/private_links", args: args, &block)
    end
  
    # Create new private link for this article
    #
    # @param article_id [Integer] Figshare id of the article
    # @param private_link [Hash] { expires_date }
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] { location }
    def link_create(article_id:, private_link:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      post(api_query: "account/articles/#{article_id}/private_links", data: private_link, args: args, &block)
    end

    # Disable/delete private link for this article
    #
    # @param article_id [Integer] Figshare id of the article
    # @param link_id [Integer] 
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def link_delete(article_id:, link:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      delete(api_query: "account/articles/#{article_id}/private_links/#{link_id}", args: args, &block)
    end
  
    # Update private link for this article
    #
    # @param article_id [Integer] Figshare id of the article
    # @param expires_date [Time] 
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def link_update(article_id:, link_id:, expires_date:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      put(api_query: "account/articles/#{article_id}/private_links/#{link_id}", args: args, data: { "expires_date" => expires_date.iso8601 }, &block)
    end

    # List private files in an article
    #
    # @param article_id [Integer] Figshare id of the article
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] {status, viewer_type, preview_state, upload_url, upload_token, id, name, size, is_link_only, 
    #                 download_url, supplied_md5, computed_md5}
    def files(article_id:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      get(api_query: "account/articles/#{article_id}/files", args: args, &block)
    end
  
    # Single file detail
    #
    # @param article_id [Integer] Figshare id of the article
    # @param file_id [Integer] Figshare id of the file
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] {status, viewer_type, preview_state, upload_url, upload_token, id, name, size, is_link_only, 
    #                 download_url, supplied_md5, computed_md5}
    def file_detail(article_id:, file_id:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      get(api_query: "account/articles/#{article_id}/files/#{file_id}", args: args, &block)
    end

    # Delete a file from an article
    #
    # @param article_id [Integer] Figshare id of the article
    # @param file_id [Integer] Figshare id of the file
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def file_delete(article_id:, file_id: , impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      delete( api_query: "account/articles/#{article_id}/files/#{file_id}", args: args, &block )
    end

    # WARNING!!!! Delete every file in an article
    #
    # @param article_id [Integer] Figshare id of the article
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] Figshare file record of each file being deleted (if block_given?)
    def delete_all_files(article_id:, impersonate: nil)
      article_files(article_id: article_id, impersonate: impersonate) do |f| 
        yield f if block_given?
        article_file_delete(article_id: article_id, file_id: f['id'], impersonate: impersonate)
      end
    end
    
  end
end