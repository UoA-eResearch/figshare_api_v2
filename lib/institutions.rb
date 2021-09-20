module Figshare
  # Figshare Institutions API
  #
  class Institutions < Base
    # Upload hr file
    #
    # @param hr_xml [String] See https://docs.figshare.com/#hr_feed_hr_feed_private_endpoint
    # @yield [Hash] { message:, data: null, errcode:}
    def hr_upload(hr_xml:, &block)
      put(api_query: 'institution/hrfeed/upload', data: hr_xml, content_type: 'multipart/form-data', &block)
    end

    # Get the institional account details
    #
    # @yield [Hash]
    def account(&block)
      get(api_query: 'account/institution', &block)
    end

    # Requests a list of private institute articles
    #
    # @param status [Integer] Only return items with this status
    # @param published_since [Time] Return results if published after this time
    # @param modified_since [Time] Return results if modified after this time
    # @param resource_doi [String] Matches this resource doi
    # @param item_type [String] Matches this item_type. See Figshare API docs for list (https://docs.figshare.com/#articles_list)
    # @param order [String] "published_date" Default, "modified_date", "views", "cites", "shares"
    # @param order_direction [String] "desc" Default, "asc"
    # @yield [Hash] {id, title, doi, handle, group_id, url, url_public_html, url_public_api, url_private_htm,
    #                url_private_api, published_date, timeline {...}, thumb, defined_type, defined_name }
    def private_articles( status: nil,
                          published_since: nil,
                          modified_since: nil,
                          item_type: nil,
                          resource_doi: nil,
                          order: 'published_date',
                          order_direction: 'desc',
                          &block
                        )
      args = {}
      args['status'] = status unless status.nil?
      args['item_type'] = item_type unless item_type.nil?
      args['resource_doi'] = resource_doi unless resource_doi.nil?
      args['published_since'] = published_since unless published_since.nil?
      args['modified_since'] = modified_since unless modified_since.nil?
      args['order'] = order unless order.nil?
      args['order_direction'] = order_direction unless order_direction.nil?
      get_paginate(api_query: 'account/institution/articles', args: args, &block)
    end

    # Requests an institute file
    #
    # @param resource_id [Integer] Figshare resource_id (publisher ID?)
    # @param filename [String] Figshare file name
    # @yield [Hash] {id, title, doi, handle, group_id, url, url_public_html, url_public_api, url_private_htm,
    #                url_private_api, published_date, timeline {...}, thumb, defined_type, defined_name }
    def articles_filter_by(resource_id: nil, filename: nil, &block )
      args = {}
      args['resource_id'] = resource_id unless resource_id.nil?
      args['filename'] = filename unless filename.nil?
      get(api_query: 'institutions/{@institute_id}/articles/filter-by', args: args, &block)
    end

    # Get institution categories (including parent Categories)
    #
    # @yield [Hash] { parent_id, id, title }
    def categories(&block)
      get(api_query: 'account/categories', &block)
    end

    # Get the groups for which the account has administrative privileges (assigned and inherited).
    #
    # @yield [Hash] { id, name, resource_id, parent_id, association_criteria }
    def groups(&block)
      get(api_query: 'account/groups', &block)
    end

    # Get the roles available for groups and the institution group.
    #
    # @yield [Hash] { id, name, category, description }
    def roles(&block)
      get(api_query: 'account/roles', &block)
    end

    # Get the accounts for which the account has administrative privileges (assigned and inherited).
    #
    # @param is_active [Boolean] user account is active
    # @param institution_user_id [String] As set in the HR upload
    # @param email [String] as set in the HR upload
    # @yield [Hash] { id, first_name, last_name, institution_id, email, active, institution_user_id }
    def accounts(is_active: nil, institution_user_id: nil, email: nil, &block)
      args = {}
      args['is_active'] = is_active unless is_active.nil?
      args['institution_user_id'] = institution_user_id unless institution_user_id.nil?
      args['email'] = email unless email.nil?
      get_paginate(api_query: 'account/institution/accounts', args: args, &block)
    end

    # Create new Institution Account
    #
    # @param email [String]
    # @param first_name [String]
    # @param last_name [String]
    # @param group_id [Integer] Figshare group ID
    # @param institution_user_id [string]
    # @param symplectic_user_id [string]
    # @param quota [Integer] Figshare user quota
    # @param is_active [Boolean]
    def account_create(email:, first_name:, last_name:, group_id:, institution_user_id: nil, symplectic_user_id: nil, quota: nil, is_active: true, &block)
      args = {}
      args['email'] = email unless email.nil?
      args['first_name'] = first_name unless first_name.nil?
      args['last_name'] = last_name unless last_name.nil?
      args['group_id'] = group_id unless group_id.nil?
      args['institution_user_id'] = institution_user_id unless institution_user_id.nil?
      args['symplectic_user_id'] = symplectic_user_id unless symplectic_user_id.nil?
      args['quota'] = quota unless quota.nil?
      args['is_active'] = is_active unless is_active.nil?
      post(api_query: "account/institution/accounts/#{account_id}", args: args, &block)
    end

    # Update Institution Account
    #
    # @param email [String]
    # @param first_name [String]
    # @param last_name [String]
    # @param group_id [Integer] Figshare group ID
    # @param institution_user_id [string]
    # @param symplectic_user_id [string]
    # @param quota [Integer] Figshare user quota
    # @param is_active [Boolean]
    def account_update(email:, first_name:, last_name:, group_id:, institution_user_id: nil, symplectic_user_id: nil, quota: nil, is_active: true, &block)
      args = {}
      args['email'] = email unless email.nil?
      args['first_name'] = first_name unless first_name.nil?
      args['last_name'] = last_name unless last_name.nil?
      args['group_id'] = group_id unless group_id.nil?
      args['institution_user_id'] = institution_user_id unless institution_user_id.nil?
      args['symplectic_user_id'] = symplectic_user_id unless symplectic_user_id.nil?
      args['quota'] = quota unless quota.nil?
      args['is_active'] = is_active unless is_active.nil?
      put(api_query: "account/institution/accounts/#{account_id}", args: args, &block)
    end

    # Get institution Account Group Roles
    #
    # @param account_id [Integer] Figshare user account id
    # @yield [Hash] { role_id [ { category, id, name }, ... ], ... }
    def group_roles(account_id:, &block)
      get(api_query: "account/institution/roles/#{account_id}", &block)
    end

    # Add Institution Account Group Roles
    #
    # @param account_id [Integer] Figshare user account id
    # @param body [Hash] see figshare api docs
    def group_roles_add(account_id:, body:, &block)
      post(api_query: "account/institution/roles/#{account_id}", args: body, &block)
    end

    # Delete Institution Account Group Role
    #
    # @param account_id [Integer] Figshare user account id
    # @param role_id [Integer] Figshare role id
    # @param group_id [Integer] Figshare group id
    def group_role_delete( role_id, group_id, account_id:, &block)
      args = {}
      args['account_id'] = account_id unless account_id.nil?
      args['role_id'] = role_id unless role_id.nil?
      args['group_id'] = group_id unless group_id.nil?
      delete(api_query: 'account/institution/roles/{account_id}', args: args, &block)
    end

    # Get the accounts for which the account has administrative privileges (assigned and inherited).
    #
    # @param is_active [Boolean] user account is active
    # @param institution_user_id [String] As set in the HR upload
    # @param email [String] as set in the HR upload
    # @yield [Hash] {id, first_name, last_name, institution_id, email, active, institution_user_id}
    def account_search(search_for: nil, is_active: nil, institution_user_id: nil, email: nil, &block)
      args = {}
      args['search_for'] = search_for unless search_for.nil?
      args['is_active'] = is_active unless is_active.nil?
      args['institution_user_id'] = institution_user_id unless institution_user_id.nil?
      args['email'] = email unless email.nil?
      post(api_query: 'account/institution/accounts/search', args: args, &block)
    end

    # Get institution user information using the account_id
    #
    # @param account_id [Integer] Figshare user account id
    # @yield [Hash] { id, first_name, last_name, name, is_active, url_name, is_public, job_title, orcid_id }
    def user(account_id:, &block)
      get(api_query: "account/institution/users/#{account_id}", &block)
    end

    # Get a list of curation reviews for this institution
    #
    # @param group_id [Integer] Figshare group ID
    # @param article_id [Integer] Figshare article ID
    # @param status [String] pending, approved, rejected, closed
    # @yield [Hash] {id, group_id, account_id, assigned_to, article_id, version, comment_count, status, created_date. modified_date }
    def curation_review(group_id: nil, article_id: nil, status: nil, &block)
      args = {}
      args['group_id'] = group_id unless group_id.nil?
      args['article_id'] = article_id unless article_id.nil?
      args['status'] = status unless status.nil?
      # Odd one, as has offset,limit not page,page_size
      get_paginate(api_query: 'account/institution/reviews', args: args, by_offset: true, &block)
    end

    # Get a curation review record
    #
    # @param curation_id [Integer] Figshare curation ID
    # @yield [Hash] see Figshare API docs for response sample
    def curation_review_detail(curation_id:, &block)
      get(api_query: "account/institution/review/#{curation_id}",  &block)
    end

    # Get a certain curation review's comments.
    #
    # @param curation_id [Integer] Figshare curation ID
    # @yield [Hash] { id, account_id, type, text}
    def curation_review_comments(curation_id:, &block)
      # Odd one, as has offset,limit not page,page_size.
      get_paginate(api_query: "account/institution/reviews/#{curation_id}/comments", by_offset: true, &block)
    end

    # Add a new comment to the review.
    #
    # @param curation_id [Integer] Figshare curation ID
    # @param comment [String] Comment text
    def curation_review_comments_update(curation_id:, comment:, &block)
      # Odd one, as has offset,limit not page,page_size.
      post(api_query: "account/institution/reviews/#{curation_id}/comments", args: { 'text' => comment }, &block)
    end
  end
end
