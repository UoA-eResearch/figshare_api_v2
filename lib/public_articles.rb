module Figshare
  # Figshare Public Articles API
  #
  class PublicArticles < Base
    # Requests a list of public articles
    #
    # @param institution [Boolean] Just our institution
    # @param group_id [Integer] Only return this group's collections
    # @param published_since [Time] Return results if published after this time
    # @param modified_since [Time] Return results if modified after this time
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
    # @yield [Array] [{id, title, doi, handle, url, published_date,...}] see docs.figshare.com
    def list( institute: false,
              group_id: nil,
              published_since: nil,
              modified_since: nil,
              item_type: nil,
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
      args = {}
      args['institution'] = @institute_id unless institute.nil?
      args['group_id'] = group_id unless group_id.nil?  # Not sure if this should be 'group' or 'group_id'. API has conflicting info
      args['item_type'] = item_type unless item_type.nil?
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
      get_paginate(api_query: 'articles', args: args, &block)
    end

    # Search within the public articles
    #
    # @param institution [Boolean] Just our institution
    # @param group_id [Integer] Only return this group's collections
    # @param published_since [Time] Return results if published after this time
    # @param modified_since [Time] Return results if modified after this time
    # @param resource_doi [String] Matches this resource doi
    # @param item_type [String] Matches this item_type. See Figshare API docs for list (https://docs.figshare.com/#articles_list)
    # @param doi [String] Matches this doi
    # @param handle [String] Matches this handle
    # @param order [String] "published_date" Default, "modified_date", "views", "cites", "shares"
    # @param order_direction [String] "desc" Default, "asc"
    # @yield [Hash] {id, title, doi, handle, url, published_date}
    def search( search_for:,
                institute: false,
                group_id: nil,
                published_since: nil,
                modified_since: nil,
                item_type: nil,
                resource_doi: nil,
                doi: nil,
                handle: nil,
                order: 'published_date',
                order_direction: 'desc',
                &block
              )
      args = { 'search_for' => search_for }
      args['institution'] = @institute_id unless institute.nil?
      args['group_id'] = group_id unless group_id.nil?
      args['item_type'] = item_type unless item_type.nil?
      args['resource_doi'] = resource_doi unless resource_doi.nil?
      args['doi'] = doi unless doi.nil?
      args['handle'] = handle unless handle.nil?
      args['published_since'] = published_since unless published_since.nil?
      args['modified_since'] = modified_since unless modified_since.nil?
      args['order'] = order unless order.nil?
      args['order_direction'] = order_direction unless order_direction.nil?
      post(api_query: 'articles/search', args: args, &block)
    end

    # Return details of specific article (default version)
    #
    # @param article_id [Integer] Figshare id of the article
    # @yield [Hash] See figshare api docs
    def detail(article_id:, &block)
      get(api_query: "articles/#{article_id}", &block)
    end

    # Return details of list of versions for a specific article
    #
    # @param article_id [Integer] Figshare id of the artcle
    # @yield [Hash] See figshare api docs
    def versions(article_id:, &block)
      get(api_query: "articles/#{article_id}/versions", &block)
    end

    # Return details of specific article version
    #
    # @param article_id [Integer] Figshare id of the article
    # @param version_id [Integer] Figshare id of the article's version
    # @param embargo [Boolean] Include only embargoed items
    # @param confidentiality [Boolean] Include only confidential items
    # @yield [Hash] See figshare api docs
    def version_detail(article_id:, version_id:, embargo: false, confidentiality: false, &block)
      if embargo
        get(api_query: "articles/#{article_id}/versions/#{version_id}/embargo", &block)
      elsif confidentiality
        get(api_query: "articles/#{article_id}/versions/#{version_id}/confidentiality", &block)
      else
        get(api_query: "articles/#{article_id}/versions/#{version_id}", &block)
      end
    end

    # Return details of list of files for a specific articles
    #
    # @param article_id [Integer] Figshare id of the article
    # @yield [Hash] {id, title, doi, handle, url, published_date}
    def files(article_id:)
      get(api_query: "articles/#{article_id}/files", &block)
    end

    # Return details of a specific file for a specific articles
    #
    # @param article_id [Integer] Figshare id of the article
    # @param file_id [Integer] Figshare id of the file
    # @yield [Hash] See figshare api docs
    def file_detail(article_id:, file_id:, &block)
      get(api_query: "articles/#{article_id}/files/#{file_id}", &block)
    end
  end
end
