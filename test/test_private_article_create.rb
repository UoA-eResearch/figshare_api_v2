#!/usr/local/bin/ruby
require_relative '../lib/figshare_api_v2'
Dir.chdir(__dir__) # Needed with Atom, which stays in the project dir, not the script's dir.

@figshare = Figshare::Init.new(figshare_user: 'figshare_admin', conf_dir: 'conf')

body = @figshare.private_articles.body(
  title: 'test',
  description: 'test description',
  defined_type: 'dataset',
  authors: [ { 'name' => 'A N Author' } ],
  keywords: [ 'Penguin', 'Micro CT', 'os opticus', 'eye', 'scleral ring' ],
  categories: [ 10, 728, 159 ],
  custom_fields: { 'Contact' => 'anauthor@gmail.com' }
)

puts "JSON body\n#{body}"

@figshare.institutions.account_search(email: 'r.burrowes@auckland.ac.nz') do |u|
  @user = u
  puts "user_id #{@user['id']}"
end

unless @user.nil?
  @figshare.private_articles.create(body: body, impersonate: @user['id']) do |r|
    # r is of the form {"location"=>"https://api.figshare.com/v2/account/articles/14219846"}
    puts r
    @article_id = r['location'].gsub(/^.*account\/articles\//, '')
    puts "Article ID #{@article_id}"
  end
end

puts 'Article Info'
unless @article_id.nil?
  @figshare.private_articles.detail(article_id: @article_id, impersonate: @user['id']) do |r|
    puts r
  end
end
