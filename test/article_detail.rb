#!/usr/local/bin/ruby
require_relative '../lib/figshare_api_v2.rb'

@figshare = Figshare::Init.new(figshare_user: 'figshare_admin', conf_dir: "#{__dir__}/conf")

ARTICLE_ID = 13213907

@figshare.private_articles.detail(article_id: ARTICLE_ID, impersonate: 1188933) do |r|
  p r
end
