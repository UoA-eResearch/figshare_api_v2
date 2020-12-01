#!/usr/local/bin/ruby
require_relative '../lib/figshare_api_v2.rb'

def test_private_article_files
  article_api = Figshare::PrivateArticles.new(figshare_user: 'figshare_admin', conf_dir: "#{__dir__}/conf")
  article_api.files(article_id: 12924963) do |a|
    p a
  end
end

def test_author_search
  authors = Figshare::Authors.new(figshare_user: 'figshare_admin', conf_dir: "#{__dir__}/conf")
  authors.search(institute: true, search_for: 'Dane') { |r| p r; puts }
end

def test_author_detail(id:)
  authors = Figshare::Authors.new(figshare_user: 'figshare_admin', conf_dir: "#{__dir__}/conf")
  authors.detail(author_id: id) { |a| p a }
end

def test_institute_account
  institute = Figshare::Institutions.new(figshare_user: 'figshare_admin', conf_dir: "#{__dir__}/conf")
  institute.accounts(email: 'd.gerneke@auckland.ac.nz')  { |a| p a; puts } #look for institute accounts, with this email address
end

def test_user(id:)
  institute = Figshare::Institutions.new(figshare_user: 'figshare_admin', conf_dir: "#{__dir__}/conf")
  institute.user(account_id: id) { |a| p a }
end

def test_private_collections_list(id:)
  collections = Figshare::PrivateCollections.new(figshare_user: 'figshare_admin', conf_dir: "#{__dir__}/conf")
  #Assume Dane's identity, to list his collections
  collections.list(impersonate: id) do |c|
    p c
    puts
  end
end

def test_private_collection_detail(id:)
  collections = Figshare::PrivateCollections.new(figshare_user: 'figshare_admin', conf_dir: "#{__dir__}/conf")
  #Assume Dane's identity, to list his collections
  collections.detail(collection_id: 5114849, impersonate: id) do |c|
    p c
    puts
  end
end

def test_private_collection_articles(id:)
  collections = Figshare::PrivateCollections.new(figshare_user: 'figshare_admin', conf_dir: "#{__dir__}/conf")
  #Assume Dane's identity, to list his collections
  collections.articles(collection_id: 5114849, impersonate: id) do |c|
    p c
    puts
  end
end

def test_private_project_list
  projects = Figshare::PrivateProjects.new(figshare_user: 'figshare_admin', conf_dir: "#{__dir__}/conf")
  projects.list  { |a| p a; puts }
end

def test_article_list_and_delete_files
  puts "Dump the dummy project details"
  @figshare.private_articles.detail(article_id: 13087316) { |a| p a }
  puts
  puts "Dump the dummy project file list"
  @figshare.private_articles.files(article_id: 13087316) { |f| p f }
  puts
  puts "Delete the dummy projects files"
  @figshare.private_articles.files(article_id: 13087316) do |f|
    puts "Deleting file #{f['name']}"
    @figshare.private_articles.file_delete(article_id: 13087316, file_id: f['id'])
  end
  puts
  puts "List the files, after they have been deleted (shouldn't be any)"
  @figshare.private_articles.files(article_id: 13087316) { |f| p f }
end

def penguin_file_sequence_check(files:, delete: false)
  first_fn  = ''
  duplicates = []
  missing = []
  extra_files = []
  delete_these = []
  
  file_name = []
  files.each do |f| 
    file_name << { 'name' => f['name'], 'id' => f['id']}
  end
  file_name.sort_by! { |obj| obj['name'] }

  sequence = 0
  base = ''
  #Find the first sequence number (array has been sorted)
  file_name.each do |fn|
    if fn['name'] =~ /^.+[0-9]+.bmp/
      base = fn['name'].gsub(/^(.+[^0-9])[0-9]+.bmp$/, '\1')
      sequence = -1 # fn['name'].gsub(/#{base}([0-9]+).bmp/, '\1').to_i
      first_fn = fn['name'] #So we can report neatly
      break
    end
  end
    
  last_fn = ''
  file_name[0..-1].each do |fn|
    if fn['name'] =~ /#{base}[0-9]+.bmp/
      next_seq = fn['name'].gsub(/#{base}([0-9]+).bmp/, '\1').to_i
      if sequence != -1 && next_seq == sequence
        duplicates << "Duplicate #{fn['name']} #{fn['id']}"
        delete_these << fn['id']
      elsif next_seq != sequence + 1 && sequence != -1
        if sequence+1 == next_seq - 1
          missing << "Gap between #{sequence} and #{fn['name']} ( i.e missing #{sequence + 1} )"
        else
          missing << "Gap between #{sequence} and #{fn['name']} ( i.e missing #{sequence + 1} to #{next_seq - 1} )"
        end
      else
        last_fn = fn['name'] #So we can report neatly
      end
      sequence = next_seq
    else
      extra_files << { 'name' => fn['name'], 'id' => fn['id']}
    end
  end
  puts "Files: #{first_fn} to #{last_fn}" if first_fn != ''
  if missing.length > 0
    missing.each { |s| puts "    #{s}"}
  else
    #puts "    No missing files between first and last file number"
  end
  if false
    if duplicates.length > 0
      duplicates.each { |s| puts "    #{s}"}
      delete_these.each do |fid|
        if delete
          puts "Deleting #{fid}"
          delete_article_files(article_id: article_id, file_id: fid)
        end
      end
    else
      puts "    No duplicate files"
    end
  end
  if extra_files.length > 0
    puts
    puts "Additional files:"
    extra_files.each { |s| puts "  #{s}" }
  end
  puts
  puts "File Count: #{file_name.length}"
end

def penguin_summary
  #test_private_collection_detail(id: 1188933) #collection's detail using dane's userid
  @figshare.private_collections.articles_add(collection_id: 5114849, articles: [12924734], impersonate: 1188933)
  puts "Collections"
  @figshare.private_collections.list(impersonate: 1188933) do |c|
    puts "###########################################################"
    puts "Title: #{c['title']}"
    puts "ID: #{c['id']}"
    puts "Pulbic: #{!c['published_date'].nil?}"
    puts "DOI: #{c['doi']}"
    puts "Data Sets:"
    @figshare.private_collections.articles(collection_id: c['id'], impersonate: 1188933) do |a| 
      puts "    #{a['id']} #{a['title']} #{a['doi']}"
    end
  end
  puts 
  return
  puts "Data Sets"
  #look up Dane's articles id , title
  @figshare.private_articles.list(impersonate: 1188933) do |a| #puts "#{a['id']} #{a['title']} #{a['doi']}" }
    @figshare.private_articles.detail(article_id: a['id'], impersonate: 1188933) do |ad|
      puts "###########################################################"
      puts "Title: #{ad['title']}"
      puts "ID: #{ad['id']}"
      puts "Description: #{ad['description']}"
      puts "Pulbic: #{ad['is_public']}"
      puts "DOI: #{ad['doi']}"
      print "Authors: "
      ad['authors'].each { |author| print "#{author['full_name']}, "}
      print "\n"
     # p ad 
      penguin_file_sequence_check(files: ad['files'])
    end
    puts
  end
end


@figshare = Figshare::Init.new(figshare_user: 'figshare_admin', conf_dir: "#{__dir__}/conf")
penguin_summary

exit(0)

@figshare.private_articles.list(impersonate: 1188933) { |a| puts "#{a['id']} #{a['title']} #{a['doi']}" }
exit(0)

files = {}
@figshare.private_articles.files(article_id: 13180055) { |f| files[f['name']] = "#{f['id']} #{f['name']} #{f['computed_md5']}"}
files.sort.each { |fn,h| puts h }
exit(0)
#look up one of Dane's articles file list
#@figshare.private_articles.files(article_id: 13180055) { |f| p f }

exit(0)
#test_article_list_and_delete_files
#@figshare.private_articles.files(article_id: 13087316)  { |f| p f }

@figshare.authors.detail(author_id: 1188933) { |a| p a }
@figshare.authors.search(institute: true, search_for: 'Dane') { |a| p a }

puts "######## test_author_search"
test_author_search #search for "Dane"

puts "######## test_private_project_list"
test_private_project_list


puts "######## test_private_collection_detail"
test_author_detail(id: 1188933) #Dane's author id

puts "######## test_user"
test_user(id: 1188933) #Dane's user id

puts "######## test_institute_account"
test_institute_account #filtered by Dane's email

puts "######## test_private_collection_detail"
test_private_collection_detail(id: 1188933) #collection's detail using dane's userid

puts "######## test_private_collection_articles"
test_private_collection_articles(id: 1188933) #Dane's collection's articles

