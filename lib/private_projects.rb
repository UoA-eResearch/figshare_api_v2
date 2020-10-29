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
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] {role, storage, url, published_date, id, title}
    def list(storage: nil, roles: nil, order: 'published_date', order_direction: 'desc', impersonate: nil, &block)
      args = {}
      args['storage'] = storage if ! storage.nil?
      args['roles'] = roles if ! roles.nil?
      args['order'] = order if ! order.nil?
      args['order_direction'] = order_direction if ! order_direction.nil?
      args["impersonate"] = impersonate  if ! impersonate.nil?
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
    # @yield [Hash] {id, title, doi, handle, url, published_date}
    def search(institute: false, group_id: nil, impersonate: nil, 
                        published_since: nil, modified_since: nil, 
                        order: 'published_date', order_direction: 'desc',
                        search_for:,
                        &block
                       )
      args = { 'search_for' => search_for }
      args['institution'] = @institute_id if ! institute.nil?
      args['group'] = group_id if ! group_id.nil?
      args["impersonate"] = impersonate  if ! impersonate.nil?
      args['published_since'] = published_since if ! published_since.nil?
      args['modified_since'] = modified_since if ! modified_since.nil?
      args['order'] = order if ! order.nil?
      args['order_direction'] = order_direction if ! order_direction.nil?
      post(api_query: 'account/projects/search', args: args, &block)
    end

    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def create(impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
    end
    
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def delete(impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
    end
    
    # Return details of specific private project
    #
    # @param project_id [Integer] Figshare id of the project_id
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] See figshare api docs
    def detail(project_id:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      get(api_query: "account/projects/#{project_id}",  args: args, &block)
    end

    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def update(impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
    end
    
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def publish(impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
    end
    
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def notes(impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
    end
    
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def note_create(impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
    end
    
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def note_delete(impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
    end
    
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def note_detail(impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
    end
    
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def note_update(impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
    end
    
    # Leave a project (Please note: project's owner cannot leave the project.)
    #
    # @param project_id [Integer] Figshare id of the project_id
    def private_project_collaborators_leave(project_id:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      delete(api_query: "account/projects/#{project_id}/leave", args: args, &block)
    end
    
    # Get the project collaborators
    #
    # @param project_id [Integer] Figshare id of the project_id
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def collaborators(project_id:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      get(api_query: "account/projects/#{project_id}/collaborators", args: args, &block)
    end
    
    # Invite a new collaborators to the project
    #
    # @param project_id [Integer] Figshare id of the project_id
    # @param role_name [String]
    # @param user_id [Integer]
    # @param email [String]
    # @param comment [String]
    # @yield [String] { message }
    def collaborator_invite(project_id:, role_name:, user_id:, email:, comment:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      collaborator = { "role_name" => role_name, "user_id" => user_id, "email" => email, "comment" => comment }
      post(api_query: "account/project/#{project_id}/collaborators", args: args, data: collaborator, &block)
    end
    
    # Leave a project (Please note: project's owner cannot leave the project.)
    #
    # @param project_id [Integer] Figshare id of the project_id
    # @param user_id [Integer] Figshare id of a user in the project
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def collaborator_remove(project_id:, user_id:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      delete(api_query: "account/project/#{project_id}/collaborators/#{user_id}", args: args, &block)
    end
    
    # Return details of list of articles for a specific project
    #
    # @param project_id [Integer] Figshare id of the project
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    # @yield [Hash] See Figshare API Doc
    def articles(project_id:, impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
      get_paginate(api_query: "account/projects/#{project_id}/articles", args: args, &block)
    end
    
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def article_create(impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
    end
    
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def article_delete(impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
    end
    
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def article_detail(impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
    end
    
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def artilce_files(impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
    end
    
    # @param impersonate [Integer] Figshare account_id of the user we are making this call on behalf of
    def projec_artilce_file_detail(impersonate: nil, &block)
      args = {}
      args["impersonate"] = impersonate  if ! impersonate.nil?
    end
    
  end # End of class
end # End of Module
