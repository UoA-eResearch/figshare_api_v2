#!/usr/local/bin/ruby
require_relative '../lib/figshare_api_v2.rb'

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

ARGV = [ "#{__dir__}/conf/run_2021-08-30.json" ]
# First and only argument is the configuration file.
article_conf = JSON.parse(File.read(ARGV[0]))

@figshare = Figshare::Init.new(figshare_user: article_conf['figshare_user'], conf_dir: article_conf['figshare_conf_dir'])
@user = { 'id' => article_conf['impersonate'] }

@article_list = article_conf['article_list']
set_article_id

@article_list.each do |a|
  @figshare.private_articles.detail(article_id: a['article_id'], impersonate: article_conf['impersonate']) do |r|
    p "title: #{r['title']}, doi: #{r['doi']}"
  end
end
