module Figshare
  # Figshare Institutions API
  #
  class Institutions < Base
    # Upload hr file
    #
    # @param hr_xml_filename [String] Filename. See https://docs.figshare.com/#hr_feed_hr_feed_private_endpoint
    # @yield [Hash] { message:, data: null, errcode:}
    def hr_upload(hr_xml_filename:, &block)
      File.open(@file_name, 'rb') do |fin|
        hr_xml = fin.read
        args = { 'name' => 'hrfeed', 'filename' => hr_xml_filename }
        post(api_query: 'institution/hrfeed/upload', args: args, data: hr_xml, content_type: 'multipart/form-data', &block)
      end
    end

    # Get the institional account's details (not a person's account details)
    #
    # @yield [Hash] {id:, name: "institute"}
    def account(&block)
      get(api_query: 'account/institution', &block)
    end

    # Get the institional account embargo options (IP Ranges)
    #
    # @yield [Array] list of embargo ip ranges [ {id:, type: ip_range, ip_name: Figshare_IP_Range} ]
    def account_embargo_options(&block)
      get(api_query: 'account/institution/embargo_options', &block)
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
    # @param page [Numeric] Pages start at 1. Page and Page size go together
    # @param page_size [Numeric]
    # @param offset [Numeric] offset is 0 based.  Offset and Limit go together
    # @param limit [Numeric]
    # @yield [Hash] {id, title, doi, handle, group_id, url, url_public_html, url_public_api, url_private_htm,
    #                url_private_api, published_date, timeline {...}, thumb, defined_type, defined_name }
    def private_articles( status: nil,
                          published_since: nil,
                          modified_since: nil,
                          item_type: nil,
                          resource_doi: nil,
                          order: 'published_date',
                          order_direction: 'desc',
                          page: nil,
                          page_size: nil,
                          offset: nil,
                          limit: nil,
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
      args['page'] = page unless page.nil?
      args['page_size'] = page_size unless page_size.nil?
      args['offset'] = offset unless offset.nil?
      args['limit'] = limit unless limit.nil?
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
      get(api_query: "institutions/#{@institute_id}/articles/filter-by", args: args, &block)
    end

    # Get an institute group's custom fields
    #
    # @param group_id [Integer] Figshare group_id
    # @yield [Array] [ {id:, name: field_name, field_type: text } ]
    def group_custom_fields(group_id: nil, &block )
      args = {}
      args['group_id'] = group_id unless group_id.nil?
      get(api_query: 'account/institution/custom_fields', args: args, &block)
    end

    # Set institute group's custom fields, from a CSV file
    #
    # @param custom_field_id [Integer] Figshare group_id
    # @param filename [Integer] Figshare group_id
    # @yield [Hash] {code: 200, message: ok } ]
    def group_set_custom_fields(custom_field_id:, filename: )
      File.open(filename, 'rb') do |fin|
        custom_fields_csv = fin.read
        args = { 'name' => 'external_file', 'filename' => filename }
        post(api_query: "account/institution/custom_fields/#{custom_field_id}/items/upload", args: args, data: custom_fields_csv, content_type: 'multipart/form-data', &block)
      end
    end

    # Get institution categories (including parent Categories)
    #
    # @yield [Array] [ { parent_id: 1, id: 11, title: "Anatomy", path:"/450/1024/6532", source_id: "300204", taxonomy_id: 4 } ]
    def categories(&block)
      get(api_query: 'account/categories', &block)
    end

    # Get the groups for which the account has administrative privileges (assigned and inherited).
    #
    # @yield [Array] [ { id: 1, name: "Materials", resource_id: "string", parent_id: 0, association_criteria: "IT" } ]
    def groups(&block)
      get(api_query: 'account/groups', &block)
    end

    # Get the institional account group's embargo options (IP Ranges)
    #
    # @param group_id [Integer]
    # @yield [Array] list of embargo ip ranges [ {id:, type: ip_range, ip_name: Figshare_IP_Range} ]
    def group_embargo_options(group_id:, &block)
      get(api_query: "account/institution/groups/#{group_id}/embargo_options", &block)
    end

    # Get the roles available for groups and the institution group.
    #
    # @yield [Array] [ { id:, name:, category:, description: } ]
    def roles(&block)
      get(api_query: 'account/roles', &block)
    end

    # Get the accounts for which the account has administrative privileges (assigned and inherited).
    # Accounts are returned in account id order, and there is a 9000 user upper limit. See id_gte.
    #
    # @param is_active [Boolean] user account is active
    # @param institution_user_id [String] As set in the HR upload
    # @param email [String] as set in the HR upload
    # @param id_lte [Integer] ID is <= Introduced to get around the buffer limit of 9000 users
    # @param id_gte [Integer] ID is >= Introduced to get around the buffer limit of 9000 users
    # @param page [Numeric] Pages start at 1. Page and Page size go together
    # @param page_size [Numeric]
    # @param offset [Numeric] offset is 0 based.  Offset and Limit go together
    # @param limit [Numeric]
    # @yield [Array] [{ id:, first_name:, last_name:, institution_id:, email:, active:, institution_user_id:, quota:, used_quota:, user_id:, orcid_id: }]
    def accounts( is_active: nil,
                  institution_user_id: nil,
                  email: nil,
                  id_lte: nil,
                  id_gte: nil,
                  page: nil,
                  page_size: nil,
                  offset: nil,
                  limit: nil,
                  &block
                )
      args = {}
      args['is_active'] = is_active unless is_active.nil?
      args['institution_user_id'] = institution_user_id unless institution_user_id.nil?
      args['email'] = email unless email.nil?
      args['id_lte'] = id_lte unless id_lte.nil?
      args['id_gte'] = id_gte unless id_gte.nil?
      args['page'] = page unless page.nil?
      args['page_size'] = page_size unless page_size.nil?
      args['offset'] = offset unless offset.nil?
      args['limit'] = limit unless limit.nil?
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
    def account_create( email:,
                        first_name:,
                        last_name:,
                        group_id:,
                        institution_user_id: nil,
                        symplectic_user_id: nil,
                        quota: nil,
                        is_active: true,
                        &block
                      )
      args = {}
      args['email'] = email unless email.nil?
      args['first_name'] = first_name unless first_name.nil?
      args['last_name'] = last_name unless last_name.nil?
      args['group_id'] = group_id unless group_id.nil?
      args['institution_user_id'] = institution_user_id unless institution_user_id.nil?
      args['symplectic_user_id'] = symplectic_user_id unless symplectic_user_id.nil?
      args['quota'] = quota unless quota.nil?
      args['is_active'] = is_active unless is_active.nil?
      post(api_query: 'account/institution/accounts', args: args, &block)
    end

    # Update Institution Account
    #
    # @param account_id [Integer] Whose account
    # @param email [String]
    # @param first_name [String]
    # @param last_name [String]
    # @param group_id [Integer] Figshare group ID
    # @param institution_user_id [string]
    # @param symplectic_user_id [string]
    # @param quota [Integer] Figshare user quota
    # @param is_active [Boolean]
    def account_update( account_id:,
                        email: nil,
                        first_name: nil,
                        last_name: nil,
                        group_id: nil,
                        institution_user_id: nil,
                        symplectic_user_id: nil,
                        quota: nil,
                        is_active: true,
                        &block
                      )
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

    # Get institution Account Group Roles for an account
    #
    # @param account_id [Integer] Figshare user account id
    # @yield [Hash] { role_id [ { category, id, name }, ... ], ... }
    def group_roles(account_id:, &block)
      get(api_query: "account/institution/roles/#{account_id}", &block)
    end

    # Add Institution Account Group Roles
    #
    # @param account_id [Integer] Figshare user account id
    # @param body [Hash] see figshare api cryptic docs  { "2": [ 2, 7], "3": [7,9] }. Array of roles, per group
    def group_roles_add(account_id:, body:, &block)
      post(api_query: "account/institution/roles/#{account_id}", args: body, &block)
    end

    # Delete Institution Account Group Role
    #
    # @param account_id [Integer] Figshare user account id
    # @param role_id [Integer] Figshare role id
    # @param group_id [Integer] Figshare group id
    def group_role_delete( account_id:, role_id:, group_id:, &block)
      args = {}
      delete(api_query: "account/institution/roles/#{account_id}/#{group_id}/#{role_id}", args: args, &block)
    end

    # Get the accounts for which the account has administrative privileges (assigned and inherited).
    #
    # @param is_active [Boolean] user account is active
    # @param institution_user_id [String] As set in the HR upload
    # @param email [String] as set in the HR upload
    # @param page [Numeric] Pages start at 1. Page and Page size go together
    # @param page_size [Numeric]
    # @param offset [Numeric] offset is 0 based.  Offset and Limit go together
    # @param limit [Numeric]
    # @yield [Hash] {id, first_name, last_name, institution_id, email, active, institution_user_id, quota, used_quota, user_id, orcid_id}
    def account_search( search_for: nil,
                        is_active: nil,
                        institution_user_id: nil,
                        email: nil,
                        page: nil,
                        page_size: nil,
                        offset: nil,
                        limit: nil,
                        &block
                      )
      args = {}
      args['search_for'] = search_for unless search_for.nil?
      args['is_active'] = is_active unless is_active.nil?
      args['institution_user_id'] = institution_user_id unless institution_user_id.nil?
      args['email'] = email unless email.nil?
      args['page'] = page unless page.nil?
      args['page_size'] = page_size unless page_size.nil?
      args['offset'] = offset unless offset.nil?
      args['limit'] = limit unless limit.nil?
      post_paginate(api_query: 'account/institution/accounts/search', args: args, &block)
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
    # @param status [String] One of: pending, approved, rejected, closed
    # @param offset [Numeric] offset is 0 based.  Offset and Limit go together
    # @param limit [Numeric]
    # @yield [Hash] {id, group_id, account_id, assigned_to, article_id, version, comment_count, status, created_date. modified_date }
    def curation_review(  group_id: nil,
                          article_id: nil,
                          status: nil,
                          offset: nil,
                          limit: nil,
                          &block
                       )
      args = {}
      args['group_id'] = group_id unless group_id.nil?
      args['article_id'] = article_id unless article_id.nil?
      args['status'] = status unless status.nil?
      args['offset'] = offset unless offset.nil?
      args['limit'] = limit unless limit.nil?
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
    # @param offset [Numeric] offset is 0 based.  Offset and Limit go together
    # @param limit [Numeric]
    # @yield [Hash] { id, account_id, type, text}
    def curation_review_comments(curation_id:, offset: nil, limit: nil, &block)
      # Odd one, as has offset,limit not page,page_size.
      args = {}
      args['offset'] = offset unless offset.nil?
      args['limit'] = limit unless limit.nil?
      get_paginate(api_query: "account/institution/review/#{curation_id}/comments", args: args, by_offset: true, &block)
    end

    # Add a new comment to the review.
    #
    # @param curation_id [Integer] Figshare curation ID
    # @param comment [String] Comment text
    def curation_review_comments_update(curation_id:, comment:, &block)
      post(api_query: "account/institution/review/#{curation_id}/comments", args: { 'text' => comment }, &block)
    end
  end
end
