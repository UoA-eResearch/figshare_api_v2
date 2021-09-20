#!/usr/local/bin/ruby
require 'figshare_api_v2'

# Find any existing articles, and set the article IDs
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

    authors = []
    if a['authors'].instance_of?(Array)
      a['authors'].each do |author|
        authors << if author.instance_of?(Hash)
                     author
                   else
                     { 'name' => author }
                   end
      end
    end

    body = @figshare.private_articles.body(
      title: a['title'],
      description: a['description'],
      defined_type: 'dataset',
      authors: authors.length == 0 ? nil : authors,
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

if ARGV.length != 1
  warn 'Usage: upload upload_config_file'
  exit(-1)
end

article_conf = JSON.parse(File.read(ARGV[0]))
@figshare = Figshare::Init.new(figshare_user: article_conf['figshare_user'], conf_dir: File.dirname(ARGV[0]) )
@user = { 'id' => article_conf['impersonate'] }

@article_list = article_conf['article_list']
puts '******************* Check for Existing Articles *******************************'
set_article_id

puts '******************* Reserving DOIs *******************************'
reserve_doi

puts '******************* Create Articles             *******************************'
create_new_articles

puts '******************* Upload Articles             *******************************'
upload_files(base_dir: article_conf['base_dir'])
