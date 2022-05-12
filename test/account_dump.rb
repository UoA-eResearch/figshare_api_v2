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

def institute_accounts(active: 1)
  # Globals.
  @all_users = {}
  @active_users = {}
  @inactive_users = {}
  @email = {}
  @institute_id = {}

  @figshare.institutions.accounts(is_active: active) do |a|
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
# account_info(impersonate: 1813331 )
# fetch_all_accounts
