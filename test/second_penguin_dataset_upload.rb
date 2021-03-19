#!/usr/local/bin/ruby
require 'figshare_api_v2'

def create_articles(article_list:)
  output = []
  article_list.each do |a|
    if a['article_id'] == 0 # Don't create, if it already has an article_id
      body = @figshare.private_articles.body(
              title: a['title'], 
              description: a['description'], 
              defined_type: "dataset",
              authors: [{'name'=>'Peter Hadden'}],
              keywords: ['Penguin', 'Micro CT', 'os opticus', 'eye', 'scleral ring'],
              categories: [10,728,159],
              custom_fields: {'Contact' => 'peter.h211@gmail.com'}
            )
            
      @figshare.private_articles.create(body: body, impersonate: @user['id']) do |r|
        # r is of the form {"location"=>"https://api.figshare.com/v2/account/articles/14219846"}
        puts r
        article_id = r['location'].gsub(/^.*account\/articles\//, '')
        output << "\{ \"dir\": \"#{File.basename(a['dir'])}\", \"article_id\": => #{article_id} \},"
      end
    end
  end
  puts
  puts "New Article IDs"
  output.each do |o|
    puts o
  end
end
    
def test_create_articles
  ARGV = ['conf/article_create1.json'] #Fake ARGV
  article_conf = JSON.parse(File.read(ARGV[0]))
  @figshare = Figshare::Init.new(figshare_user: article_conf['figshare_user'], conf_dir: article_conf['figshare_conf_dir'])
    
  article_list_create = article_conf['article_list']
  @user = { 'id' => article_conf['impersonate'] }

  Dir.chdir(article_conf['base_dir']) do 
    create_articles(article_list: article_list_create)
  end
end

def test_upload
  ARGV = ['conf/upload2.json'] #Fake ARGV
  article_conf = JSON.parse(File.read(ARGV[0]))

  @figshare = Figshare::Init.new(figshare_user: article_conf['figshare_user'], conf_dir: article_conf['figshare_conf_dir'])

  article_list_upload = article_conf['article_list']

  Dir.chdir(article_conf['base_dir']) do 
    article_list_upload.each do |a|
      puts "Upload Dir #{a['dir']}"
      @figshare.upload.upload_dir(article_id: a['article_id'], directory: a['dir'], trace: 1)
    end

    puts "Added   #{@figshare.upload.new_count}"
    puts "Bad MD5 #{@figshare.upload.bad_count}"
  end
end

