# -*- ruby -*-
require 'rubygems'
require 'hoe'
Hoe.plugin :yard
load "#{__dir__}/version"

Hoe.spec PROJECT do 
  self.readme_file = "README.md"
  self.developer( "Rob Burrowes","r.burrowes@auckland.ac.nz")
  remote_rdoc_dir = '' # Release to root
  
  self.yard_title = PROJECT
  self.yard_options = ['--markup', 'markdown', '--protected']

  self.dependency "wikk_json", "~> 0.1.2"
  self.dependency "wikk_webbrowser", "~> 0.9.0"
  self.dependency "dir_r", "~> 1.0.0"
end


#Validate manfest.txt
#rake check_manifest

#Local checking. Creates pkg/
#rake gem

#create doc/
#rake docs  

#Copy up to rubygem.org
#rake release VERSION=1.0.1
