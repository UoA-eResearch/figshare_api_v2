#!/usr/local/bin/ruby
require_relative '../lib/figshare_api_v2.rb'

@figshare = Figshare::Init.new(figshare_user: 'figshare_admin', conf_dir: "#{__dir__}/conf")

BASE_DIR = 'data_2021-03-16/'

article_list = [
  { :dir => "#{BASE_DIR}AV 11055 A", :article_id => 14226644 },
  { :dir => "#{BASE_DIR}AV 1134 A", :article_id => 14226647 },
  { :dir => "#{BASE_DIR}AV 1334 B", :article_id => 14226650 },
  { :dir => "#{BASE_DIR}AV 1178 A", :article_id => 14226653 },
  { :dir => "#{BASE_DIR}AV 1179 A", :article_id => 14226656 },
  { :dir => "#{BASE_DIR}AV 1909 C", :article_id => 14226659 },
  { :dir => "#{BASE_DIR}AV 7889 A", :article_id => 14226662 },
  { :dir => "#{BASE_DIR}AV 7889 B", :article_id => 14226665 },
  { :dir => "#{BASE_DIR}AV 800 A", :article_id => 14226668 },
  { :dir => "#{BASE_DIR}AV 800 B", :article_id => 14226671 },
  { :dir => "#{BASE_DIR}AV 957 A", :article_id => 14226674 },
  { :dir => "#{BASE_DIR}AV 958 A", :article_id => 14226677 },
  { :dir => "#{BASE_DIR}AV 958 B", :article_id => 14226680 },
  { :dir => "#{BASE_DIR}AV 959 A", :article_id => 14226683 },
  { :dir => "#{BASE_DIR}AV 964 A", :article_id => 14226686 },
  { :dir => "#{BASE_DIR}AV 966 A", :article_id => 14226689 },
  { :dir => "#{BASE_DIR}King 055 A", :article_id => 14226692 },
  { :dir => "#{BASE_DIR}King 055 B", :article_id => 14226695 },
]

article_list.each do |a|
  @figshare.private_articles.detail(article_id: a[:article_id], impersonate: 1188933) do |r|
    p "#{r['title']}, #{r['doi']}"
    puts
  end
end
