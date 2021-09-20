#!/usr/local/bin/ruby
require_relative '../lib/figshare_api_v2.rb'

# Globle check, across the author's articles, for files that have the same MD5 checksum.
# First and only argument is the configuration file.
ARGV = [ 'conf/upload2.json' ] # Fake ARGV
article_conf = JSON.parse(File.read(ARGV[0]))

@figshare = Figshare::Init.new(figshare_user: article_conf['figshare_user'], conf_dir: article_conf['figshare_conf_dir'])

article_list = article_conf['article_list']

global_file_names = {} # All files records inserted here, so we can spot duplicates
duplicates = [] # Output messages.
bad_checksum = [] # upload failed

# @figshare.private_articles.list(impersonate: article_conf['impersonate']) do |a|
article_list.each do |a|
  @figshare.private_articles.files(article_id: a['article_id']) do |f|
    if f['computed_md5'] == ''
      # Upload failed
      bad_checksum << "Upload Failed: #{a['id']} #{f['name']} #{f['id']}"
    elsif global_file_names[f['computed_md5']].nil?
      # Haven't had this checksum before
      global_file_names[f['computed_md5']] = { article_id: a['article_id'], file_id: f['id'], name: f['name'], md5: f['computed_md5'] }
    else
      # Found a duplicate MD5
      e = global_file_names[f['computed_md5']]
      duplicates << "Duplicate #{a['article_id']} #{f['name']} #{f['id']} #{f['computed_md5']}"
      duplicates << "WITH      #{e[:article_id]} #{e[:name]} #{e[:file_id]} #{e[:md5]}"
    end
  end
end

puts "File Count #{global_file_names.length}"
bad_checksum.each { |s| puts "    #{s}" }
puts if bad_checksum.length > 0
duplicates.each { |s| puts "    #{s}" }
