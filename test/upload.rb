#!/usr/local/bin/ruby
require_relative '../lib/figshare_api_v2.rb'
@figshare = Figshare::Init.new(figshare_user: 'uploadTest', conf_dir: "#{__dir__}/conf")

TEST_ARTICLE_ID=13087316
TEST_FILE="#{__dir__}/test_data/seniormarching.mp4"

@figshare.upload.upload(article_id: TEST_ARTICLE_ID, file_name: TEST_FILE, trace: true)

