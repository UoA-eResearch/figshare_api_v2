#!/usr/local/bin/ruby
require_relative '../lib/figshare_api_v2'
# require 'figshare_api_v2'

Dir.chdir(__dir__) # Needed with Atom, which stays in the project dir, not the script's dir.

@figshare = Figshare::Init.new(figshare_user: 'figshare_admin', conf_dir: 'conf' )

def by_upi(upi:)
  @figshare.institutions.accounts( institution_user_id: "#{upi}@auckland.ac.nz") do |a|
    p a
  end
end

def institute_accounts_by_9000(active: 1)
  # Globals.
  @all_users = {}
  @active_users = {}
  @inactive_users = {}
  @email = {}
  @institute_id = {}

  max_account_id = 0
  n_users = 0

  loop do
    this_loop_max_account_id = 0
    count_this_loop = 0
    @figshare.institutions.accounts(is_active: active, id_gte: max_account_id, cursor_pagination: false) do |a|
      n_users += 1
      puts "Duplicate at #{n_users} account_id: #{a['id']}" unless @all_users[a['id']].nil?

      @all_users[a['id']] = a
      @email[a['email']] = a
      @institute_id[a['institution_user_id']] = a
      if a['active'] == 1
        @active_users[a['id']] = a
      elsif a['active'] == 0
        @inactive_users[a['id']] = a
      else
        puts "User #{a['id']} active = '#{a['active']}'"
      end
      # Find the highest account_id seen so far this loop
      this_loop_max_account_id = a['id'].to_i if a['id'].to_i > this_loop_max_account_id
      count_this_loop += 1
    end
    puts "Inner loop count: #{count_this_loop}. id_gte: #{max_account_id}"
    break if count_this_loop == 0

    max_account_id = this_loop_max_account_id + 1
  end
end

def institute_accounts(active: 1)
  # Globals.
  # records of the form { "id"=>1171785, "first_name"=>"xx", "last_name"=>"xxxx", "email"=>"xxxx@auckland.ac.nz", "active"=>1,
  #                       "institution_id"=>12, "institution_user_id"=>"xxx001@auckland.ac.nz", "symplectic_user_id"=>"4488541",
  #                       "quota"=>10737418240, "used_quota"=>122072396, "user_id"=>1171779
  #                     }

  @all_users = {}       # Index is Figshare User ID
  @active_users = {}    # Index is Figshare User ID
  @inactive_users = {}  # Index is Figshare User ID
  @email = {}           # UoA email address. System account has "aucklandadmin@figshare.com"
  @institute_id = {}    # Index is upi@auckland.ac.nz. System accounts will have ''
  @used_quota_active = {}      # Index by Figshare User ID
  @used_quota_inactive = {}    # Index by Figshare User ID

  @figshare.institutions.accounts(is_active: active) do |a|
    puts "Duplicate #{a['id']}" unless @all_users[a['id']].nil?

    @all_users[a['id']] = a
    @email[a['email']] = a
    @institute_id[a['institution_user_id']] = a
    @used_quota_active[a['id']] = a if a['used_quota'] > 0 && a['active'] == 1
    @used_quota_inactive[a['id']] = a if a['used_quota'] > 0 && a['active'] == 0
    if a['active'] == 1
      @active_users[a['id']] = a
    elsif a['active'] == 0
      @inactive_users[a['id']] = a
    else
      puts "User #{a['id']} active = '#{a['active']}'"
    end
  end
end

def account_info(impersonate: nil)
  @figshare.other.private_account_info(impersonate: impersonate) do |a|
    p a
  end
end

def fetch_all_accounts(active: 1)
  begin_time = Time.now
  institute_accounts(active: active) # active 1, 0 or nil
  end_time = Time.now
  puts "Runtime: #{end_time - begin_time}"
  puts "Active: #{@active_users.length} Inactive: #{@inactive_users.length} Total #{@all_users.length}"
end

def fetch_all_accounts_9000(active: 1)
  begin_time = Time.now
  institute_accounts_by_9000(active: active) # active 1, 0 or nil
  end_time = Time.now
  puts "Runtime: #{end_time - begin_time}"
  puts "Active: #{@active_users.length} Inactive: #{@inactive_users.length} Total #{@all_users.length}"
end

# by_upi(upi: 'rbur004') # Just me
# user_info(account_id: 1171794)
# account_info(impersonate: 1813331 )
fetch_all_accounts(active: nil)
puts @used_quota_active.length
puts @used_quota_inactive.length
# fetch_all_accounts_9000(active: nil)
