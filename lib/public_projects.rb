module Figshare

  # Figshare public projects api
  #
  class PublicProjects < Base
    # Requests a list projects
    #
    # @param institution [Boolean] Just our institution
    # @param group_id [Integer] Only return this group's project
    # @param published_since [Time] Return results if published after this time
    # @param order [String] "published_date" Default, "modified_date", "views", "cites", "shares"
    # @param order_direction [String] "desc" Default, "asc"
    # @yield [Hash] {url, published_date, id, title}
    def list(institute: false,group_id: nil, published_since: nil, order: 'published_date', order_direction: 'desc', &block)
      args = {}
      args['institution'] = @institute_id if ! institute.nil?
      args['group'] = group_id if ! group_id.nil?
      args['published_since'] = published_since if ! published_since.nil?
      args['order'] = order if ! order.nil?
      args['order_direction'] = order_direction if ! order_direction.nil?
      get_paginate(api_query: 'projects', args: args, &block)
    end

    # Search within all projects
    #
    # @param institution [Boolean] Just our institution
    # @param group_id [Integer] Only return this group's project
    # @param published_since [Time] Return results if published after this time
    # @param modified_since [Time] Return results if modified after this time
    # @param order [String] "published_date" Default, "modified_date", "views", "cites", "shares"
    # @param order_direction [String] "desc" Default, "asc"
    # @yield [Hash] {id, title, doi, handle, url, published_date}
    def search(institute: false, group_id: nil,
                        published_since: nil, modified_since: nil, 
                        order: 'published_date', order_direction: 'desc',
                        search_for:,
                        &block
                       )
      args = { 'search_for' => search_for }
      args['institution'] = @institute_id if ! institute.nil?
      args['group'] = group_id if ! group_id.nil?
      args['published_since'] = published_since if ! published_since.nil?
      args['modified_since'] = modified_since if ! modified_since.nil?
      args['order'] = order if ! order.nil?
      args['order_direction'] = order_direction if ! order_direction.nil?
      post(api_query: 'account/projects/search', args: args, &block)
    end

    # Return details of specific project_id
    #
    # @param project_id [Integer] Figshare id of the project_id
    # @yield [Hash] See figshare api docs
    def detail(project_id:, &block)
      get(api_query: "projects/#{project_id}",  &block)
    end

    # Get list of articles for a specific project
    #
    # @param project_id [Integer] Figshare id of the project
    # @yield [Hash] See Figshare API Doc
    def articles(project_id:, &block)
      get_paginate(api_query: "projects/#{project_id}/articles", &block)
    end

  end # of class
end # of module
