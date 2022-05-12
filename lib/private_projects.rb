module Figshare
  # Figshare private project api
  #
  class PrivateProjects < Base
    # Requests a list private projects
    #
    # @param storage [String] group, individual (only return collections from this institution)
    # @param roles [String] Any combination of owner, collaborator, viewer separated by comma. Examples: "owner" or "owner,collaborator".
    # @param order [String] "published_date" Default, "modified_date", "views", "cites", "shares"
    # @param order_direction [String] "desc" Default, "asc"
    # @param page [Numeric] Pages start at 1. Page and Page size go together
    # @param page_size [Numeric]
    # @param offset [Numeric] offset is 0 based.  Offset and Limit go together
    # @param limit [Numeric]
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Array] [{role, storage, url, published_date, id, title}]
    def list( storage: nil,
              roles: nil,
              order: 'published_date',
              order_direction: 'desc',
              page: nil,
              page_size: nil,
              offset: nil,
              limit: nil,
              impersonate: nil,
              &block
            )
      args = {}
      args['storage'] = storage unless storage.nil?
      args['roles'] = roles unless roles.nil?
      args['order'] = order unless order.nil?
      args['order_direction'] = order_direction unless order_direction.nil?
      args['page'] = page unless page.nil?
      args['page_size'] = page_size unless page_size.nil?
      args['offset'] = offset unless offset.nil?
      args['limit'] = limit unless limit.nil?
      args['impersonate'] = impersonate unless impersonate.nil?
      get_paginate(api_query: 'account/projects', args: args, &block)
    end

    # Search within the own (or institute's) projects
    #
    # @param institution [Boolean] Just our institution
    # @param group_id [Integer] Only return this group's project
    # @param published_since [Time] Return results if published after this time
    # @param modified_since [Time] Return results if modified after this time
    # @param order [String] "published_date" Default, "modified_date", "views", "cites", "shares"
    # @param order_direction [String] "desc" Default, "asc"
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] {id, title, url, role, storage, published_date}
    def search( search_for:,
                institute: false,
                group_id: nil,
                published_since: nil,
                modified_since: nil,
                order: 'published_date',
                order_direction: 'desc',
                page: nil,
                page_size: nil,
                offset: nil,
                limit: nil,
                impersonate: nil,
                &block
              )
      args = { 'search_for' => search_for }
      args['institution'] = @institute_id unless institute.nil?
      args['group'] = group_id unless group_id.nil?
      args['impersonate'] = impersonate unless impersonate.nil?
      args['published_since'] = published_since unless published_since.nil?
      args['modified_since'] = modified_since unless modified_since.nil?
      args['order'] = order unless order.nil?
      args['order_direction'] = order_direction unless order_direction.nil?
      args['page'] = page unless page.nil?
      args['page_size'] = page_size unless page_size.nil?
      args['offset'] = offset unless offset.nil?
      args['limit'] = limit unless limit.nil?
      post_paginate(api_query: 'account/projects/search', args: args, &block)
    end

    # Create a new project
    #
    # @param title [String]
    # @param description [String]
    # #param group_id [Integer] Figshare group the project falls under.
    # @param funding [String]
    # @param funding_list [Array] [{id, title}, ... ]
    # @param custom_field_list [Array] [{name, value}, ... ]
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] { location }
    def create(title:, description:, group_id:, funding: '', funding_list: [], custom_field_list: nil, impersonate: nil, &block)
      args = { 'title' => title,
               'description' => description,
               'group_id' => group_id,
               'funding' => funding,
               'funding_list' => funding_list
             }
      args['custom_field_list'] = custom_field_list unless custom_field_list.nil?
      args['impersonate'] = impersonate unless impersonate.nil?
      post(api_query: 'account/projects', args: args, &block)
    end

    # Delete an existing project
    #
    # @param project_id [Integer] Figshare project ID
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def project_delete(project_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      delete(api_query: "account/projects/#{project_id}", args: args, &block)
    end

    # Return details of specific private project
    #
    # @param project_id [Integer] Figshare id of the project_id
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] See figshare api docs
    def detail(project_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      get(api_query: "account/projects/#{project_id}", args: args, &block)
    end

    # Update an existing project
    #
    # @param project_id [Integer] Figshare id of the project_id
    # @param title [String]
    # @param description [String]
    # @param funding [String]
    # @param funding_list [Array] [{id, title}, ... ]
    # @param custom_field_list [Array] [{name, value}, ... ]
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] { location }
    def update(project_id:, title: nil, description: nil, funding: nil, funding_list: nil, custom_field_list: nil, impersonate: nil, &block)
      args = {}
      args['title'] = title unless title.nil?
      args['description'] = description unless description.nil?
      args['funding'] = funding unless funding.nil?
      args['funding_list'] = funding_list unless funding_list.nil?
      args['custom_field_list'] = custom_field_list unless custom_field_list.nil?
      args['impersonate'] = impersonate unless impersonate.nil?
      put(api_query: "account/projects/#{project_id}", args: args, &block)
    end

    # Publish a project
    #
    # @param project_id [Integer] Figshare id of the project
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] {Message:}
    def publish(project_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      post(api_query: "account/projects/#{project_id}/publish", args: args, &block)
    end

    # List projects notes
    #
    # @param project_id [Integer] Figshare id of the project
    # @param page [Numeric] Pages start at 1. Page and Page size go together
    # @param page_size [Numeric]
    # @param offset [Numeric] offset is 0 based.  Offset and Limit go together
    # @param limit [Numeric]
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Array] [{id:, user_id:, abstract:, user_name:, created_date:, modified_date:}]
    def notes(  project_id:,
                page: nil,
                page_size: nil,
                offset: nil,
                limit: nil,
                impersonate: nil,
                &block
             )
      args = {}
      args['page'] = page unless page.nil?
      args['page_size'] = page_size unless page_size.nil?
      args['offset'] = offset unless offset.nil?
      args['limit'] = limit unless limit.nil?
      args['impersonate'] = impersonate unless impersonate.nil?
      get_paginate(api_query: "account/projects/#{project_id}/notes", args: args, &block)
    end

    # Create a project note
    #
    # @param project_id [Integer] Figshare id of the project
    # @param text [String] The note
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] { location }
    def note_create(project_id:, text:, impersonate: nil, &block)
      args = { 'text' => text }
      args['impersonate'] = impersonate unless impersonate.nil?
      post(api_query: "account/projects/#{project_id}/notes", args: args, &block)
    end

    # Delete a project note
    #
    # @param project_id [Integer] Figshare id of the project
    # @param note_id [Integer] Figshare id of the note
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def note_delete(project_id:, note_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      delete(api_query: "account/projects/#{project_id}/notes/#{note_id}", args: args, &block)
    end

    # Get a note's text
    #
    # @param project_id [Integer] Figshare id of the project
    # @param note_id [Integer] Figshare id of the note
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] { text:, id:, user_id:, abstract:, user_name:, created_date:, modified_data: }
    def note_detail(project_id:, note_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      get(api_query: "account/projects/#{project_id}/notes/#{note_id}", args: args, &block)
    end

    # update a project note
    #
    # @param project_id [Integer] Figshare id of the project
    # @param note_id [Integer] Figshare id of the note
    # @param text [String] The note
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def note_update(project_id:, note_id:, text:, impersonate: nil, &block)
      args = { 'text' => text }
      args['impersonate'] = impersonate unless impersonate.nil?
      put(api_query: "account/projects/#{project_id}/notes/#{note_id}", args: args, &block)
    end

    # Leave a project (Note: project's owner cannot leave the project.)
    #
    # @param project_id [Integer] Figshare id of the project_id
    def project_collaborators_leave(project_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      post(api_query: "account/projects/#{project_id}/leave", args: args, &block)
    end

    # Get the project collaborators
    #
    # @param project_id [Integer] Figshare id of the project_id
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Array] [{ status:, role_name:, user_id:, name: }]
    def collaborators(project_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      get(api_query: "account/projects/#{project_id}/collaborators", args: args, &block)
    end

    # Invite a new collaborators to the project
    #
    # @param project_id [Integer] Figshare id of the project_id
    # @param role_name [String] "viewer", ...
    # @param user_id [Integer] Need user_id and/or email
    # @param email [String] Need user_id and/or email
    # @param comment [String]
    # @yield [String] { message }
    def collaborator_invite(project_id:, role_name:, comment:, user_id: nil, email: nil, impersonate: nil, &block)
      raise 'collaborator_invite(): Need a user_id or an email address' if user_id.nil? && email.nil?

      args = {
        'role_name' => role_name,
        'comment' => comment
      }
      args['user_id'] = user_id unless user_id.nil?
      args['email'] = email unless email.nil?
      args['impersonate'] = impersonate unless impersonate.nil?
      collaborator = { 'role_name' => role_name, 'user_id' => user_id, 'email' => email, 'comment' => comment }
      post(api_query: "account/project/#{project_id}/collaborators", args: args, data: collaborator, &block)
    end

    # Leave a project (Please note: project's owner cannot leave the project.)
    #
    # @param project_id [Integer] Figshare id of the project_id
    # @param user_id [Integer] Figshare id of a user in the project
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def collaborator_remove(project_id:, user_id:, impersonate: nil, &block)
      raise 'collaborator_remove(): Need a user_id' if user_id.nil?

      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      delete(api_query: "account/project/#{project_id}/collaborators/#{user_id}", args: args, &block)
    end

    # Return details of list of articles for a specific project
    #
    # @param project_id [Integer] Figshare id of the project
    # @param page [Numeric] Pages start at 1. Page and Page size go together
    # @param page_size [Numeric]
    # @param offset [Numeric] offset is 0 based.  Offset and Limit go together
    # @param limit [Numeric]
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Array] See Figshare API Doc
    def articles( project_id:,
                  page: nil,
                  page_size: nil,
                  offset: nil,
                  limit: nil,
                  impersonate: nil,
                  &block
                )
      args = {}
      args['page'] = page unless page.nil?
      args['page_size'] = page_size unless page_size.nil?
      args['offset'] = offset unless offset.nil?
      args['limit'] = limit unless limit.nil?
      args['impersonate'] = impersonate unless impersonate.nil?
      get_paginate(api_query: "account/projects/#{project_id}/articles", args: args, &block)
    end

    # Create a new Article and associate it with this project
    #
    # @param project_id [Integer] Figshare id of the project
    # @param article_record [Hash] See docs.figshare.com
    # @param page [Numeric] Pages start at 1. Page and Page size go together
    # @param page_size [Numeric]
    # @param offset [Numeric] offset is 0 based.  Offset and Limit go together
    # @param limit [Numeric]
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] { entity_id:, location:, warnings: [ "string" ] }
    def article_create( project_id:,
                        article_record: nil,
                        page: nil,
                        page_size: nil,
                        offset: nil,
                        limit: nil,
                        impersonate: nil,
                        &block
                      )
      args = { 'article' => article_record }
      args['page'] = page unless page.nil?
      args['page_size'] = page_size unless page_size.nil?
      args['offset'] = offset unless offset.nil?
      args['limit'] = limit unless limit.nil?
      args['impersonate'] = impersonate unless impersonate.nil?
      # Figshare Docs say this should be post_paginate, but that makes no sense. Will have to test
      post_paginate(api_query: "account/projects/#{project_id}/articles", args: args, &block)
    end

    # delete an article from a project
    #
    # @param project_id [Integer] Figshare id of the project
    # @param article_id [Integer] Figshare id of the article
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def article_delete(project_id:, article_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      delete(api_query: "account/projects/#{project_id}/articles/#{article_id}", args: args, &block)
    end

    # Get the details of an artilcle in a project
    #
    # @param project_id [Integer] Figshare id of the project
    # @param article_id [Integer] Figshare id of the article
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] See docs.figshare.com for article hash
    def article_detail(project_id:, article_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      get(api_query: "account/projects/#{project_id}/articles/#{article_id}", args: args, &block)
    end

    # Get the files associated with an artilcle in a project
    #
    # @param project_id [Integer] Figshare id of the project
    # @param article_id [Integer] Figshare id of the article
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Array] See docs.figshare.com
    def artilce_files(project_id:, article_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      get(api_query: "account/projects/#{project_id}/articles/#{article_id}/files", args: args, &block)
    end

    # Get the files associated with an artilcle in a project
    #
    # @param project_id [Integer] Figshare id of the project
    # @param article_id [Integer] Figshare id of the article
    # @param file_id [Integer] Figshare id of the file
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def artilce_file_detail(project_id:, article_id:, file_id:, impersonate: nil, &block)
      args = {}
      args['impersonate'] = impersonate unless impersonate.nil?
      delete(api_query: "account/projects/#{project_id}/articles/#{article_id}/files/#{file_id}", args: args, &block)
    end
  end
end
