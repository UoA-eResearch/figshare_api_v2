#!/usr/local/bin/ruby
require 'figshare_api_v2'

def upload(article_list:)
  # Upload each dir to the article specified. 
  # Will not overwrite existing files in Figshare, if they have the same MD5 sum.
  # It pays to run this script multiple times, as the uploads can silently fail.

  article_list.each do |a|
    begin
      puts "Upload Dir #{a['dir']}"
      @figshare.upload.upload_dir(article_id: a['article_id'], directory: a['dir'], trace: 1)
    rescue WIKK::WebBrowser::Error => error
      puts "Web error (probably unrepeatable): %s"
      puts "Retrying this directory once more (#{a['dir']}). Will not catch the next Web error!"
      @figshare.upload.upload_dir(article_id: a['article_id'], directory: a['dir'], trace: 1)
    end
  end

  puts "Added   #{@figshare.upload.new_count}"
  puts "Bad MD5 #{@figshare.upload.bad_count}"
end

if ARGV.length != 1
  warn "Usage: upload upload_config_file"
  exit -1
end

#First and only argument is the configuration file.
upload_conf = JSON.parse(File.read(ARGV[0]))
@figshare = Figshare::Init.new(figshare_user: upload_conf['figshare_user'], conf_dir: upload_conf['figshare_conf_dir'])

Dir.chdir(upload_conf['base_dir']) do 
  # Now in the base_dir containing the article directories, as specified in the article_list
  upload(article_list: upload_conf['article_list'])
end

