module Figshare
  # Figshare Author APIs
  #
  class Authors < Base
    # Search authors
    #
    # @param institution [Boolean] Just our institution. We have already stored the institute_id.
    # @param orcid [String] Matches this orcid
    # @param group_id [Integer] Only return this group's collections
    # @param is_active [Boolean]
    # @param is_public [Boolean]
    # @param order [String] "published_date" Default, "modified_date", "views", "cites", "shares"
    # @param order_direction [String] "desc" Default, "asc"
    # @param page [Numeric] Pages start at 1. Page and Page size go together
    # @param page_size [Numeric]
    # @param offset [Numeric] offset is 0 based.  Offset and Limit go together
    # @param limit [Numeric]
    # @yield [Hash] {id, first_name, last_name, full_name, url_name, is_active, is_public, orcid_id, institution_id, group_id, job_title}
    def search( search_for:,
                institute: false,
                group_id: nil,
                orcid: nil,
                is_active: true,
                is_public: true,
                order: 'published_date',
                order_direction: 'desc',
                page: nil,
                page_size: nil,
                offset: nil,
                limit: nil,
                &block
              )
      args = { 'search_for' => search_for }
      args['institution'] = @institute_id.to_i if institute
      args['group_id'] = group_id unless group_id.nil?
      args['is_active'] = is_active unless is_active.nil?
      args['is_public'] = is_public unless is_public.nil?
      args['orcid'] = orcid unless orcid.nil?
      args['order'] = order unless order.nil?
      args['order_direction'] = order_direction unless order_direction.nil?
      args['page'] = page unless page.nil?
      args['page_size'] = page_size unless page_size.nil?
      args['offset'] = offset unless offset.nil?
      args['limit'] = limit unless limit.nil?
      post_paginate(api_query: 'account/authors/search', args: args, &block)
    end

    # Get an authors details
    #
    # @param author_id [Integer] Figshare Author ID
    # @yield [Hash] {id, first_name, last_name, full_name, url_name, is_active, is_public, orcid_id, institution_id, group_id, job_title}
    def detail(author_id:, &block)
      get(api_query: "account/authors/#{author_id}", &block)
    end
  end
end
