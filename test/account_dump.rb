#!/usr/local/bin/ruby
require_relative '../lib/figshare_api_v2'

@figshare = Figshare::Init.new(figshare_user: 'figshare_admin', conf_dir: 'test/conf' )

def by_upi(upi:)
  @figshare.institutions.accounts( institution_user_id: "#{upi}@auckland.ac.nz") do |a|
    p a
  end
end

# Everyone
def everyone
  @figshare.institutions.accounts(is_active: 1) do |a|
    p a
  end
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
# Everyone
account_info(impersonate: 1171794 )
