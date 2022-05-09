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

# Everyone
def active
  active_users = {}
  email = {}
  institute_id = {}
  count = 0
  inactive = 0

  begin_time = Time.now
  @figshare.institutions.accounts(is_active: 1) do |a|
    next if a.nil? || a['id'].nil?

    active_users[a['id']] = a
    email[a['email']] = a
    institute_id[a['institution_user_id']] = a
    if a['active'] == 1
      count += 1
    else
      inactive += 1
      puts 'Found inactive user in active'
      p a
    end
  end
  end_time = Time.now
  puts "Active: active #{count} inactive #{inactive} users #{active_users.length} #{email.length} #{institute_id.length} Time #{end_time - begin_time}."
end

def not_active
  email = {}
  institute_id = {}
  inactive_users = {}
  count = 0
  inactive = 0

  begin_time = Time.now
  @figshare.institutions.accounts(is_active: 0) do |a|
    next if a.nil? || a['id'].nil?

    inactive_users[a['id']] = a
    email[a['email']] = a
    institute_id[a['institution_user_id']] = a
    if a['active'] == 1
      count += 1
      puts 'Found active user in inactive list'
      p a
    else
      inactive += 1
    end
  end
  end_time = Time.now
  puts "Not Active: active #{count} inactive #{inactive} users #{inactive_users.length} #{email.length} #{institute_id.length} Time #{end_time - begin_time}."
end

def everyone
  everyone = {}
  email = {}
  institute_id = {}
  count = 0
  inactive = 0

  begin_time = Time.now
  @figshare.institutions.accounts do |a|
    next if a.nil? || a['id'].nil?

    everyone[a['id']] = a
    email[a['email']] = a
    institute_id[a['institution_user_id']] = a
    if a['active'] == 1
      count += 1
    else
      inactive += 1
    end
    # p a
    # return if count == 10
  end
  end_time = Time.now
  puts "Everyone: active #{count} inactive #{inactive} users #{everyone.length}  #{email.length} #{institute_id.length} Time #{end_time - begin_time}."
end

def user_info(account_id: )
  @figshare.institutions.user( account_id: account_id) do |a|
    p a
  end
end

def account_info(impersonate: nil)
  @figshare.other.private_account_info(impersonate: impersonate) do |a|
    p a
  end
end

# by_upi(upi: 'rbur004') # Just me
# user_info(account_id: 1171794)
# Everyone. There looks to be a 9000 total responses limit?
everyone
active
not_active
# account_info(impersonate: 1171794 )
