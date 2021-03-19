#!/usr/local/bin/ruby
require_relative '../lib/figshare_api_v2.rb'

ARGV = ['conf/upload2.json']
#First and only argument is the configuration file.
article_conf = JSON.parse(File.read(ARGV[0]))

@figshare = Figshare::Init.new(figshare_user: article_conf['figshare_user'], conf_dir: article_conf['figshare_conf_dir'])

article_list = article_conf['article_list']

article_list.each do |a|
  @figshare.private_articles.detail(article_id: a['article_id'], impersonate: article_conf['impersonate']) do |r|
    p "title: #{r['title']}, doi: #{r['doi']}"
  end
end
