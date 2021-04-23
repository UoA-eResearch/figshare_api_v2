#!/usr/local/bin/ruby
require 'figshare_api_v2'

# Retrieve md5 sums of the existing files in the figshare article
# Sets @md5_cache[filename] => figshare.computed_md5
# 
# @param article_id [Integer] Figshare article ID
def cache_article_file_md5(article_id:)
  @md5_cache = {}
  @figshare.private_articles.files(article_id: article_id) do |f|
    @md5_cache[f['name']] = {:article_id => article_id, :id => f['id'], :md5 => f[ 'computed_md5']}
  end
end

# Upload all files in a directory, into one article.
# Check checksums, and only upload changed or new files
# Does not recurse through sub-directories, as figshare has a flat file structure.
#
# @param article_id [Integer] Figshare article id
# @param directory [String] path
# @param delete_extras [Boolean] delete any files in the figshare end, that aren't in the local directory.
def validate_upload_dir(article_id:, directory:, exclude_dot_files: true )
  missing_count = 0
  bad_count = 0
  extra_count = 0
  
  files = {}
  cache_article_file_md5(article_id: article_id)
  
  DirR.walk_dir(directory: directory, walk_sub_directories: false) do |d,f|
    next if exclude_dot_files && f =~ /^\..*/
    files[f] = true  #note that we have seen this filename
    if @md5_cache[f] #check to see if it has already been uploaded
      md5, size = Figshare::Upload.get_file_check_data("#{d}/#{f}")
      if @md5_cache[f][:md5] != md5 #file is there, but has changed, or previously failed to upload.
        puts "Mismatch: #{article_id} << #{d}/#{f} #{@md5_cache[f][:id]} MISMATCH '#{@md5_cache[f]}' != '#{md5}'"
        bad_count += 1
      end
    else
      puts "Missing:  #{article_id} << #{d}/#{f}" 
      missing_count += 1
    end
  end
  
  # Print out filename of files in the Figshare article, that weren't in the directory.
  @md5_cache.each do |fn, v|
    if ! files[fn]  
      puts "EXTRA:    #{article_id} << #{fn} #{v[:id]}" 
      extra_count += 1
    end
  end
  
  puts "Mismatch: #{bad_count}"
  puts "Missing:  #{missing_count}"
  puts "EXTRA:    #{extra_count}"
end

#First and only argument is the configuration file.
ARGV = ['conf/upload2.json'] #Fake ARGV
article_conf = JSON.parse(File.read(ARGV[0]))

@figshare = Figshare::Init.new(figshare_user: article_conf['figshare_user'], conf_dir: article_conf['figshare_conf_dir'])

article_list = article_conf['article_list']

Dir.chdir(article_conf['base_dir']) do 
  article_list.each do |a|
    puts "Validate #{a['dir']}"
    validate_upload_dir(article_id: a['article_id'], directory: a['dir'])
  end
end


