#!/usr/local/bin/ruby
# require_relative '../lib/figshare_api_v2'
require 'figshare_api_v2'

Dir.chdir(__dir__) # Needed with Atom, which stays in the project dir, not the script's dir.

@figshare = Figshare::Init.new(figshare_user: 'figshare_admin', conf_dir: 'conf' )

def by_upi(upi:)
  @figshare.institutions.accounts( institution_user_id: "#{upi}@auckland.ac.nz") do |a|
    p a
  end
end

def accounts_wrapper(id_gte: 0, active: 1, &block)
  puts "id_gte: #{id_gte}"
  highest_id_gte = 0
  count = 0
  @figshare.institutions.accounts(is_active: active, id_gte: id_gte, page_size: 50) do |a|
    next if a.nil? || a['id'].nil?

    puts 'Out of order ' if highest_id_gte > a['id'].to_i
    puts "Same as the previous one #{a['id']} " if highest_id_gte == a['id'].to_i
    count += 1
    highest_id_gte = a['id'].to_i
    yield a
  end

  puts "Count: #{count}"
  # We might have reached the upper limit of Figshare's buffer, and need to recurse.
  accounts_wrapper(id_gte: highest_id_gte + 1, active: active, &block) unless highest_id_gte == 0
end

def institute_accounts(active: 1)
  # Globals.
  @all_users = {}
  @active_users = {}
  @inactive_users = {}
  @email = {}
  @institute_id = {}

  accounts_wrapper(active: active) do |a|
    puts "Duplicate #{a['id']}" unless @all_users[a['id']].nil?

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
  end
end

def account_info(impersonate: nil)
  @figshare.other.private_account_info(impersonate: impersonate) do |a|
    p a
  end
end

def fetch_all_accounts
  begin_time = Time.now
  institute_accounts(active: 1) # active 1, 0 or nil
  end_time = Time.now
  puts "Runtime: #{end_time - begin_time}"
  puts "Active: #{@active_users.length} Inactive: #{@inactive_users.length} Total #{@all_users.length}"
end

# by_upi(upi: 'rbur004') # Just me
# user_info(account_id: 1171794)
# account_info(impersonate: 1171794 )
fetch_all_accounts
