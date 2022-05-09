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
    # @param page [Numeric] Pages start at 1. Page and Page size go together
    # @param page_size [Numeric]
    # @param offset [Numeric] offset is 0 based.  Offset and Limit go together
    # @param limit [Numeric]
    # @yield [Hash] {url, published_date, id, title}
    def list( institute: false,
              group_id: nil,
              published_since: nil,
              order: 'published_date',
              order_direction: 'desc',
              page: nil,
              page_size: nil,
              offset: nil,
              limit: nil,
              &block
            )
      args = {}
      args['institution'] = @institute_id unless institute.nil?
      args['group'] = group_id unless group_id.nil?
      args['published_since'] = published_since unless published_since.nil?
      args['order'] = order unless order.nil?
      args['order_direction'] = order_direction unless order_direction.nil?
      args['page'] = page unless page.nil?
      args['page_size'] = page_size unless page_size.nil?
      args['offset'] = offset unless offset.nil?
      args['limit'] = limit unless limit.nil?
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
    def search( search_for:,
                institute: false,
                group_id: nil,
                published_since: nil,
                modified_since: nil,
                order: 'published_date',
                order_direction: 'desc',
                &block
              )
      args = { 'search_for' => search_for }
      args['institution'] = @institute_id unless institute.nil?
      args['group'] = group_id unless group_id.nil?
      args['published_since'] = published_since unless published_since.nil?
      args['modified_since'] = modified_since unless modified_since.nil?
      args['order'] = order unless order.nil?
      args['order_direction'] = order_direction unless order_direction.nil?
      post(api_query: 'account/projects/search', args: args, &block)
    end

    # Return details of specific project_id
    #
    # @param project_id [Integer] Figshare id of the project_id
    # @yield [Hash] See figshare api docs
    def detail(project_id:, &block)
      get(api_query: "projects/#{project_id}", &block)
    end

    # Get list of articles for a specific project
    #
    # @param project_id [Integer] Figshare id of the project
    # @yield [Hash] See Figshare API Doc
    def articles(project_id:, &block)
      get_paginate(api_query: "projects/#{project_id}/articles", &block)
    end
  end
end
