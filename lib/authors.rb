module Figshare
  # Figshare Author APIs
  #
  class Authors < Base
    # Search authors
    #
    # @param institution [Boolean] Just our institution
    # @param group_id [Integer] Only return this group's collections
    # @param orcid [String] Matches this orcid
    # @param is_active [Boolean]
    # @param is_public [Boolean]
    # @param order [String] "published_date" Default, "modified_date", "views", "cites", "shares"
    # @param order_direction [String] "desc" Default, "asc"
    # @yield [Hash] {id, first_name, last_name, full_name, url_name, is_active, is_public, orcid_id, institution_id, group_id, job_title}
    def search(institute: false, group_id: nil, orcid: nil,
                is_active: true, is_public: true,  
                order: 'published_date', order_direction: 'desc',
                search_for:,
                &block
              )
      args = { 'search_for' => search_for }
      args['institution'] = @institute_id if ! institute.nil?
      args['group_id'] = group_id if ! group_id.nil?
      args['is_active'] = is_active if ! is_active.nil?
      args['is_public'] = is_public if ! is_public.nil?
      args['orcid'] = orcid if ! orcid.nil?
      args['order'] = order if ! order.nil?
      args['order_direction'] = order_direction if ! order_direction.nil?
      post(api_query: 'account/authors/search', args: args, &block)
    end
    
    # Get an authors details
    #
    # @param author_id [Integer] Figshare Author ID
    # @yield [Hash] {id, first_name, last_name, full_name, url_name, is_active, is_public, orcid_id, institution_id, group_id, job_title}
    def detail(author_id:, &block)
      get(api_query: "account/authors/#{author_id}",  &block)
    end
  end

end
