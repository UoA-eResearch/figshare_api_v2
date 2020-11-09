module Figshare
  VERSION = '0.9.2'

  require "wikk_webbrowser"
  require "wikk_json"
  require 'time'

  require_relative 'base.rb'
  require_relative 'authors.rb'
  require_relative 'institutions.rb'
  require_relative 'other.rb'
  require_relative 'private_articles.rb'
  require_relative 'private_collections.rb'
  require_relative 'private_projects.rb'
  require_relative 'public_articles.rb'
  require_relative 'public_collections.rb'
  require_relative 'public_projects.rb'
  require_relative 'upload.rb'
  require_relative 'stats.rb'
  require_relative 'oai_pmh.rb'
  
  # Hack :) to do a lazy initialization of the Figshare subclasses. i.e. only if they get called.
  # Usage:
  #  @figshare = Figshare::Init.new(figshare_user: 'figshare_admin', conf_dir: "#{__dir__}/conf")
  #
  #  @figshare.authors.detail(author_id: 12345) { |a| puts a }
  #  @figshare.institutions.private_articles { |article| puts article }
  #  ...
  #
  class Init
    # Intitialize the Init class, so it can dynamically initialize the Figshare subclasses
    #
    # @param figshare_user [String] figshare user, in the figshare_keys.json
    # @param conf_dir [String] directory for figshare_keys.json and figshare_site_params.json
    def initialize(figshare_user:, conf_dir:)
      @figshare_user = figshare_user
      @conf_dir = conf_dir
    end
    
    # Create Figshare::Authors, if it doesn't exist. Initialized with @figshare_user and @conf_dir
    #
    # @return [Figshare::Authors]
    def authors
      @authors ||= Authors.new(figshare_user: @figshare_user, conf_dir: @conf_dir)
    end

    # Create Figshare::Institutions, if it doesn't exist. Initialized with @figshare_user and @conf_dir
    #
    # @return [Figshare::Institutions]
    def institutions
      @institutions ||= Institutions.new(figshare_user: @figshare_user, conf_dir: @conf_dir)
    end
    
    # Create Figshare::Other, if it doesn't exist. Initialized with @figshare_user and @conf_dir
    #
    # @return [Figshare::Other]
    def other
      @other ||= Other.new(figshare_user: @figshare_user, conf_dir: @conf_dir)
    end
    
    # Create Figshare::PrivateArticles, if it doesn't exist. Initialized with @figshare_user and @conf_dir
    #
    # @return [Figshare::PrivateArticles]
    def private_articles
      @private_articles ||= PrivateArticles.new(figshare_user: @figshare_user, conf_dir: @conf_dir)
    end
    
    # Create Figshare::PrivateCollections, if it doesn't exist. Initialized with @figshare_user and @conf_dir
    #
    # @return [Figshare::PrivateCollections]
    def private_collections
      @private_collections ||= PrivateCollections.new(figshare_user: @figshare_user, conf_dir: @conf_dir)
    end
    
    # Create Figshare::PrivateProjects, if it doesn't exist. Initialized with @figshare_user and @conf_dir
    #
    # @return [Figshare::PrivateProjects]
    def private_projects
      @private_projects ||= PrivateProjects.new(figshare_user: @figshare_user, conf_dir: @conf_dir)
    end
    
    # Create Figshare::PublicArticles, if it doesn't exist. Initialized with @figshare_user and @conf_dir
    #
    # @return [Figshare::PublicArticles]
    def public_articles
      @public_articles ||= PublicArticles.new(figshare_user: @figshare_user, conf_dir: @conf_dir)
    end
    
    # Create Figshare::PublicCollections, if it doesn't exist. Initialized with @figshare_user and @conf_dir
    #
    # @return [Figshare::PublicCollections]
    def public_collections
      @public_collections ||= PublicCollections.new(figshare_user: @figshare_user, conf_dir: @conf_dir)
    end
    
    # Create Figshare::PublicProjects, if it doesn't exist. Initialized with @figshare_user and @conf_dir
    #
    # @return [Figshare::PublicProjects]
    def public_projects
      @public_projects ||= PublicProjects.new(figshare_user: @figshare_user, conf_dir: @conf_dir)
    end

    # Create Figshare::Upload, if it doesn't exist. Initialized with @figshare_user and @conf_dir
    #
    # @return [Figshare::Upload]
    def upload
      @upload ||= Upload.new(figshare_user: @figshare_user, conf_dir: @conf_dir)
    end
    
    # Create Figshare::Stats, if it doesn't exist. Initialized with @figshare_user and @conf_dir
    #
    # @return [Figshare::Stats]
    def stats
      @stats ||= Stats.new(figshare_user: @figshare_user, conf_dir: @conf_dir)
    end
    
    # Create Figshare::OAI_PMH, if it doesn't exist. Initialized with @figshare_user and @conf_dir
    #
    # @return [Figshare::OAI_PMH]
    def oai_pmh
      @oai_pmh ||= OAI_PMH.new(figshare_user: @figshare_user, conf_dir: @conf_dir)
    end
    
  end
end # module