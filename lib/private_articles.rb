module Figshare
  # Figshare private articles API
  #
  class PrivateArticles < Base
    # Get Own Articles (or private articles of others if institute is true)
    #
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @param page [Numeric] Pages start at 1. Page and Page size go together
    # @param page_size [Numeric]
    # @param offset [Numeric] offset is 0 based.  Offset and Limit go together
    # @param limit [Numeric]
    # @yield [Array] [{id, title, doi, handle, url, published_date, ...}] See docs.figshare.com
    def list( impersonate: nil,
              page: nil,
              page_size: nil,
              offset: nil,
              limit: nil,
              &block
            )
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      args['page'] = page unless page.nil?
      args['page_size'] = page_size unless page_size.nil?
      args['offset'] = offset unless offset.nil?
      args['limit'] = limit unless limit.nil?
      get_paginate(api_query: 'account/articles', args: args, &block)
    end

    # Search within the private articles (our own, or the institutes)
    #
    # @param institution [Boolean] Just our institution
    # @param group_id [Integer] Only return this group's collections
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @param published_since [Time] Return results if published after this time
    # @param modified_since [Time] Return results if modified after this time
    # @param resource_id [String] Looks like a quoted Integer
    # @param resource_doi [String] Matches this resource doi
    # @param item_type [String] Matches this item_type. See Figshare API docs for list (https://docs.figshare.com/#articles_list)
    # @param doi [String] Matches this doi
    # @param handle [String] Matches this handle
    # @param order [String] "published_date" Default, "modified_date", "views", "cites", "shares"
    # @param order_direction [String] "desc" Default, "asc"
    # @param page [Numeric] Pages start at 1. Page and Page size go together
    # @param page_size [Numeric]
    # @param offset [Numeric] offset is 0 based.  Offset and Limit go together
    # @param limit [Numeric]
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Array] [{id, title, doi, handle, url, published_date, ...}] See docs.figshare.com
    def search( search_for:,
                institute: false,
                group_id: nil,
                impersonate: nil,
                published_since: nil,
                modified_since: nil,
                item_type: nil,
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
      args['institution'] = @institute_id.to_i if institute # Inconsistent use. Other calls use institute_id
      args['group'] = group_id unless group_id.nil? # Not sure if this changed from group_id to group
      args['item_type'] = item_type unless item_type.nil?
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
      post_paginate(api_query: 'account/articles/search', args: args, &block)
    end

    # Create a body for use with create and update methods
    #
    # @param title [String] Required
    # @param description [String] The article description. In a publisher case, usually this is the remote article description
    # @param tags [Array] List of tags (strings) to be associated with the article. Tags can be used instead
    # @param keywords [Array] List of tags (strings) to be associated with the article. Tags can be used instead
    # @param references [Array] List of links to be associated with the article (e.g ["http://link1", "http://link2", "http://link3"])
    # @param categories [Array] List of category ids to be associated with the article(e.g [1, 23, 33, 66])
    # @param categories_by_source_id [Array] List of category ids to be associated with the article(e.g ["300204", "400207"])
    # @param authors [Array] List of authors to be associated with the article. The list can contain the following fields: id, name, first_name, last_name, email, orcid_id. If an id is supplied, it will take priority and everything else will be ignored. No more than 10 authors. For adding more authors use the specific authors endpoint. e.g. { "name" => "Joe X"} and or { "id" => 123 }
    # @param custom_fields [Hash] List of key, values pairs to be associated with the article. eg. { "key" => "value"}
    # @param custom_fields_list [Array] List of key, values pairs to be associated with the article. eg. [{ "key" => "value"}]
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
    def body( title:,
              description: nil,
              tags: nil,
              keywords: nil,
              references: nil,
              categories: nil,
              categories_by_source_id: nil,
              authors: nil,
              custom_fields: nil,
              custom_fields_list: nil,
              defined_type: nil,
              funding: nil,
              funding_list: nil,
              license: nil,
              doi: nil,
              handle: nil,
              resource_doi: nil,
              resource_title: nil,
              timeline: nil,
              group_id: nil,
              contact: nil
            )
      body_ = {
        'title' => title
      }
      body_['description'] = description unless description.nil?
      body_['tags'] = tags unless tags.nil?
      body_['keywords'] = keywords unless keywords.nil?
      body_['references'] = references unless references.nil?
      body_['categories'] = categories unless categories.nil?
      body_['categories_by_source_id'] = categories_by_source_id unless categories_by_source_id.nil?
      body_['authors'] = authors unless authors.nil?
      body_['custom_fields'] = custom_fields unless custom_fields.nil?
      body_['custom_fields_list'] = custom_fields_list unless custom_fields_list.nil?
      body_['defined_type'] = defined_type unless defined_type.nil?
      body_['funding'] = funding unless funding.nil?
      body_['funding_list'] = funding_list unless funding_list.nil?
      body_['license'] = license unless license.nil?
      body_['doi'] = doi unless doi.nil?
      body_['handle'] = handle unless handle.nil?
      body_['resource_doi'] = resource_doi unless resource_doi.nil?
      body_['resource_title'] = resource_title unless resource_title.nil?
      body_['timeline'] = timeline unless timeline.nil?
      body_['group_id'] = group_id unless group_id.nil?
      body_['contact'] = contact unless contact.nil?

      return body_
    end

    # Create a new Article by sending article information
    # The user calling the API (or impersonated user) looks to be added as an author, even if they aren't.
    # A duplicate "Author" entry occurs when adding them explicitly
    #
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] { entity_id:, location:, warnings: [ "string"] }
    def create(body:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      post(api_query: 'account/articles', args: args, data: body, &block)
    end

    # Delete an article (WARNING!!!!!)
    #
    # @param article_id [Integer] Figshare id of the article
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def article_delete(article_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      delete(api_query: "account/articles/#{article_id}", args: args, &block)
    end

    # Get a private article's details
    #
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @param article_id [Integer] Figshare id of the article
    # @yield [Hash] See docs.figshare.com
    def detail(article_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      get(api_query: "account/articles/#{article_id}", args: args, &block)
    end

    # Updating an article by passing body parameters
    #
    # @param article_id [Integer] Figshare id of the article
    # @param body [Hash] See API docs.
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def update(article_id:, body:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      put(api_query: "account/articles/#{article_id}", args: args, data: body, &block)
    end

    # Will lift the embargo for the specified article
    #
    # @param article_id [Integer] Figshare id of the article
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def embargo_delete(article_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      delete(api_query: "account/articles/#{article_id}/embargo", args: args, &block)
    end

    # Get a private article embargo details
    #
    # @param article_id [Integer] Figshare id of the article
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] {is_embargoed, embargo_date, embargo_title, embargo_reason, embargo_options [{...}] }
    def embargo_detail(article_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      get(api_query: "account/articles/#{article_id}/embargo", args: args, &block)
    end

    # Updates an article embargo status.
    # Does not imply that the article will be published when the embargo will expire.
    # You must explicitly call the publish endpoint to enable this functionality.
    #
    # @param article_id [Integer] Figshare id of the article
    # @param is_embargoed [Boolean]
    # @param embargo_date [Time] Still needs to be published, after this date
    # @param embargo_type [Integer]
    # @param embargo_title [String]
    # @param embargo_reason [String]
    # @param embargo_options [Array]
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def embargo_update( article_id:,
                        embargo_date:, embargo_title:, embargo_reason:,
                        is_embargoed: true,
                        embargo_type: 'file',
                        embargo_options: [],
                        impersonate: nil,
                        &block
    )
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      embargo_record = { 'is_embargoed' => is_embargoed,
                         'embargo_date' => embargo_date.strftime('%Y-%m-%dT%H:%M:%S'),
                         'embargo_type' => embargo_type,
                         'embargo_title' => embargo_title,
                         'embargo_reason' => embargo_reason,
                         'embargo_options' => embargo_options
                       }
      put(api_query: "account/articles/#{article_id}/embargo", args: args, data: embargo_record, &block)
    end

    # Article Resource
    #
    # @param article_id [Integer] Figshare id of the article
    # @param resource [Hash]
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] {location:, "string"}
    def article_resource( article_id:,
                          id:,
                          title:,
                          doi:,
                          link:,
                          status:,
                          version:,
                          impersonate: nil,
                          &block
                        )
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      resource_record = {
        'id' => id,
        'title' => title,
        'doi' => doi,
        'link' => link,
        'status' => status,
        'version' => version
      }
      post(api_query: "account/articles/#{article_id}/resource", args: args, data: resource_record, &block)
    end

    # Publish an article
    # If the whole article is under embargo, it will not be published immediately, but when the embargo expires or is lifted.
    # When an article is published, a new public version will be generated.
    # Any further updates to the article will affect the private article data.
    # In order to make these changes publicly visible, an explicit publish operation is needed.
    #
    # @param article_id [Integer] Figshare id of the article
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] {location:, "string"}
    def publish(article_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      post(api_query: "account/articles/#{article_id}/publish", args: args, &block)
    end

    # Reserve DOI for article
    #
    # @param article_id [Integer] Figshare id of the article
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] {doi:, "string"}
    def reserve_doi(article_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      post(api_query: "account/articles/#{article_id}/reserve_doi", args: args, &block)
    end

    # Reserve Handle for article
    #
    # @param article_id [Integer] Figshare id of the article
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] {handle:, "string"}
    def reserve_handle(article_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      post(api_query: "account/articles/#{article_id}/reserve_handle", args: args, &block)
    end

    # Update Article Version
    #
    # @param article_id [Integer]
    # @param version_id [Interger]
    # @param body [Hash] Update fields, rather than overwrite article metadata. see docs.figshare.com
    def article_version(article_id:, version_id:, body: nil, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      if body.nil?
        put(api_query: "account/articles/#{article_id}/versions/#{version_id}/", args: args, &block)
      else
        patch(api_query: "account/articles/#{article_id}/versions/#{version_id}/", args: args, data: body, &block)
      end
    end

    # Update Article Thumbnail of a specific version of the article
    #
    # @param article_id [Integer]
    # @param version_id [Interger]
    # @param file_id [integer] File id of one of the articles files, to use as a thumbnail. see docs.figshare.com
    def article_version_update_thumbnail(article_id:, version_id:, file_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      args['file_id'] = file_id
      put(api_query: "account/articles/#{article_id}/versions/#{version_id}/update_thumb", args: args, &block)
    end

    # Yield articles authors
    #
    # @param article_id [Integer] Figshare id of the article
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] [{id, full_name, is_active, url_name, orcid_id}]
    def authors(article_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      get(api_query: "account/articles/#{article_id}/authors", args: args, &block)
    end

    # Associate new authors with the article. This will add new authors to the list of already associated authors
    #
    # @param article_id [Integer] Figshare id of the article
    # @param authors [Array] Can be a mix of [{ id: 1234 } and/or { name: "x y" }]
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def authors_add(article_id:, authors:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      post(api_query: "account/articles/#{article_id}/authors", args: args, data: { 'authors' => authors }, &block)
    end

    # Replace existing authors list with a new list
    #
    # @param article_id [Integer] Figshare id of the article
    # @param authors [Array] Can be a mix of [{ id: 1234 } and/or { name: "x y" }]
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def authors_replace(article_id:, authors:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      put(api_query: "account/articles/#{article_id}/authors", args: args, data: { 'authors' => authors }, &block)
    end

    # Remove author from the article
    #
    # @param article_id [Integer] Figshare id of the article
    # @param author_id [Integer] Figshare id for the author
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def author_delete(article_id:, author_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      delete(api_query: "account/articles/#{article_id}/authors/#{author_id}", args: args, &block)
    end

    # List categories for a specific article
    #
    # @param article_id [Integer] Figshare id of the article
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # yield [Hash] { parent_id, id, title, path, source_id, taxonomy_id }
    def categories(article_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      get(api_query: "account/articles/#{article_id}/categories", args: args, &block)
    end

    # Associate new categories with the article.
    # This will add new categories to the list of already associated categories
    #
    # @param article_id [Integer] Figshare id of the article
    # @param categories [Array] [ categorie_id, ... ]
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def categories_add(article_id:, categories:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      post(api_query: "account/articles/#{article_id}/categories", args: args, data: { 'categories' => categories }, &block)
    end

    # Associate new categories with the article. This will remove all already associated categories and add these new ones
    #
    # @param article_id [Integer] Figshare id of the article
    # @param categories [Array] [ categorie_id, ... ]
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def categories_replace(article_id:, categories:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      put(api_query: "account/articles/#{article_id}/categories", args: args, data: { 'categories' => categories }, &block)
    end

    #  Delete category from article's categories
    #
    # @param article_id [Integer] Figshare id of the article
    # @param category_id [Integer] Figshare id of the category
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def categories_delete(article_id:, category_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      delete(api_query: "account/articles/#{article_id}/categories/#{category_id}", args: args, &block)
    end

    # List private links
    #
    # @param article_id [Integer] Figshare id of the article
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] {id, is_active, expires_date, html_location}
    def links(article_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      get(api_query: "account/articles/#{article_id}/private_links", args: args, &block)
    end

    # Create new private link for this article
    #
    # @param article_id [Integer] Figshare id of the article
    # @param expires_date [Time]
    # @param read_only [Boolean]
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] { location:, html_location:, token: }
    def link_create(article_id:, expires_date: nil, read_only: true, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      link_properties = {}
      link_properties['expires_date'] = expires_date.iso8601 unless expires_date.nil?
      link_properties['read_only'] = read_only unless read_only.nil?
      post(api_query: "account/articles/#{article_id}/private_links", data: link_properties, args: args, &block)
    end

    # Disable/delete private link for this article
    #
    # @param article_id [Integer] Figshare id of the article
    # @param link_id [Integer]
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def link_delete(article_id:, link_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      delete(api_query: "account/articles/#{article_id}/private_links/#{link_id}", args: args, &block)
    end

    # Update private link for this article
    #
    # @param article_id [Integer] Figshare id of the article
    # @param expires_date [Time]
    # @param read_only [Boolean]
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def link_update(article_id:, link_id:, expires_date: nil, read_only: nil, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      link_properties = {}
      link_properties['expires_date'] = expires_date.iso8601 unless expires_date.nil?
      link_properties['read_only'] = read_only unless read_only.nil?
      put(api_query: "account/articles/#{article_id}/private_links/#{link_id}", args: args, data: link_properties, &block)
    end

    # List private files in an article
    #
    # @param article_id [Integer] Figshare id of the article
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] {status, viewer_type, preview_state, upload_url, upload_token, id, name, size, is_link_only,
    #                 download_url, supplied_md5, computed_md5}
    def files(article_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
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
      args['impersonate'] = impersonate unless impersonate.nil?
      get(api_query: "account/articles/#{article_id}/files/#{file_id}", args: args, &block)
    end

    # Delete a file from an article
    #
    # @param article_id [Integer] Figshare id of the article
    # @param file_id [Integer] Figshare id of the file
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def file_delete(article_id:, file_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
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
