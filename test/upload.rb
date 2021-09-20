#!/usr/local/bin/ruby
require_relative '../lib/figshare_api_v2.rb'
@figshare = Figshare::Init.new(figshare_user: 'uploadTest', conf_dir: "#{__dir__}/conf")

TEST_ARTICLE_ID = 13087316
TEST_DIR = "#{__dir__}/test_data"

puts 'List test articles files'
@figshare.private_articles.files(article_id: TEST_ARTICLE_ID) { |f| p f }

puts
puts "Upload Dir #{TEST_DIR}"
@figshare.upload.upload_dir(article_id: TEST_ARTICLE_ID, directory: TEST_DIR, trace: 2)

puts
puts 'List test articles files'
@figshare.private_articles.files(article_id: TEST_ARTICLE_ID) { |f| p f }
