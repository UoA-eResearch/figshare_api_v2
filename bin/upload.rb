#!/usr/local/bin/ruby
require 'figshare_api_v2'

# Find any existing articles, and set the article IDs on our end
# This is useful, if we run this script a second time, to ensure all files have been copied.
def set_article_id
  # Create hash index, so we can look up by title
  articles_title_index = {}
  @article_list.each_with_index do |a, i|
    articles_title_index[a['title']] = i
  end

  # List all the users articles, and see if the ones in the conf file already exist.
  @figshare.private_articles.list(impersonate: @user['id']) do |l|
    # search by title (and assume that the title is unique, for this user's articles)
    if (a_id = articles_title_index[l['title']]) != nil && @article_list[a_id]['article_id'] == 0
      @article_list[a_id]['article_id'] = l['id']
    end
  end

  puts 'Existing articles IDs'
  @article_list.each { |a| puts "Article #{a['article_id']} - #{a['title']}" }
end

def create_new_articles
  output = [] # Save the output, until we are finish.

  @article_list.each do |a|
    next unless a['article_id'] == 0 # Don't create, if it already has an article_id

    body = @figshare.private_articles.body(
      title: a['title'],
      description: a['description'],
      defined_type: 'dataset',
      authors: a['authors'].length == 0 ? nil : a['authors'],
      keywords: a['keywords'],
      categories: a['categories'],
      custom_fields: a['custom_fields']
    )

    @figshare.private_articles.create(body: body, impersonate: @user['id']) do |r|
      # r is of the form {"location"=>"https://api.figshare.com/v2/account/articles/14219846"}
      puts r
      article_id = r['location'].gsub(/^.*account\/articles\//, '')
      a['article_id'] = article_id
      output << "\{ \"article_id\": => #{article_id}, \"dir\": \"#{File.basename(a['dir'])}\"},"
    end
  end
  puts
  puts 'New Article IDs'
  # Saved up output.
  output.each do |o|
    puts o
  end
end

def reserve_doi
  @article_list.each do |a|
    @figshare.private_articles.detail(article_id: a['article_id'], impersonate: @user['id']) do |article|
      if article['doi'].length == 0
        @figshare.private_articles.reserve_doi(article_id: a['article_id'], impersonate: @user['id'])
      end
    end
  end
end

# Upload each article's files to Figshare.
def upload_files(base_dir: )
  Dir.chdir(base_dir) do
    @article_list.each do |a|
      if a['article_id'] == 0 # Don't create, if it already has an article_id
        stderr.puts "Skipping: Article has no ID - '#{a['title']}'"
      else
        puts "Upload Dir #{a['dir']}"
        @figshare.upload.upload_dir(article_id: a['article_id'], directory: a['dir'], trace: 1)
      end
    end

    puts "Added   #{@figshare.upload.new_count}"
    puts "Bad MD5 #{@figshare.upload.bad_count}"
  end
end

# Find any existing collection, and set the collection IDs on our end
# This is useful, if we run this script a second time, to ensure all files have been copied.
# @param impersonate [Integer] Figshare user ID
# @param collection [Hash] Details of the collection being created
def set_collection_id(impersonate:, collection:)
  # List all the users collections, and see if the ones in the conf file already exist.
  @figshare.private_collections.search(impersonate: impersonate, search_for: collection['title']) do |a|
    # Double check we have gotten a close match
    collection['collection_id'] = a['id'].to_i if collection['title'] == a['title']
  end
end

# Creates a new collection, and reserves a DOI
# @param impersonate [Integer] Figshare user ID
# @param collection [Hash] Details of the collection being created
def create_new_collection(impersonate:, collection:)
  set_collection_id(impersonate: impersonate, collection: collection)
  return if collection['collection_id'] != 0

  # Will do the job for a collection too. Should create a collection specific one
  body = @figshare.private_collections.body(
    title: collection['title'],
    description: collection['description'],
    authors: collection['authors'].length == 0 ? nil : collection['authors'],
    keywords: collection['keywords'],
    categories: collection['categories']
  )
  @figshare.private_collections.create(body: body, impersonate: impersonate) do |c|
    collection['collection_id'] = c['entity_id']
    @figshare.private_collections.reserve_doi(collection_id: collection['collection_id'], impersonate: impersonate) do |r|
      collection['doi'] = r['doi']
    end
    puts "Created Collection #{collection['collection_id']}: #{collection['title']}}"
  end
end

# Adds the articles in article_list to the private collection
# @param impersonate [Integer] Figshare user ID
# @param collection [Hash] Details of the collection we want to add the articles to (only collection_id being important)
# @param article_list [Hash] Details of the articles being added (only article_id being important)
def add_articles_to_collection(impersonate:, collection:, article_list:)
  articles = []
  article_list.each do |article|
    articles << article['article_id']
  end
  @figshare.private_collections.articles_add(collection_id: collection['collection_id'], articles: articles, impersonate: impersonate)
end

if ARGV.length != 1
  warn 'Usage: upload upload_config_file'
  exit(-1)
end

article_conf = JSON.parse(File.read(ARGV[0]))
@figshare = Figshare::Init.new(figshare_user: article_conf['figshare_user'], conf_dir: File.dirname(ARGV[0]) )
@user = { 'id' => article_conf['impersonate'] }
@collection = article_conf['collection']

@article_list = article_conf['article_list']
puts '******************* Check for Existing Articles *******************************'
set_article_id

puts '******************* Create Articles             *******************************'
create_new_articles

puts '******************* Reserving Article DOIs      *******************************'
reserve_doi

puts '******************* Upload Articles             *******************************'
upload_files(base_dir: article_conf['base_dir'])

if ! @collection.nil?
  puts '******************* Create Collection             *******************************'
  create_new_collection(impersonate: @user['id'], collection: @collection)
  puts '******************* Add Articles to Collection    *******************************'
  add_articles_to_collection(impersonate: @user['id'], collection: @collection, article_list: @article_list)
end
