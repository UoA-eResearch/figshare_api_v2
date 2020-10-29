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

@figshare = Figshare::Init.new(figshare_user: 'figshare_admin', conf_dir: "#{__dir__}/conf")

@figshare.authors.detail(author_id: 1188933) { |a| p a }
@figshare.authors.search(institute: true, search_for: 'Dane') { |a| p a }

exit(0)

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

