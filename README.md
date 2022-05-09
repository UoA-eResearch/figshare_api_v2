# figshare_api_v2

* Docs :: https://UoA-eResearch.github.io/figshare_api_v2/
* Source :: https://github.com/UoA-eResearch/figshare_api_v2
* Gem :: https://rubygems.org/gems/figshare_api_v2
* Figshare :: https://docs.figshare.com/

## DESCRIPTION:

Figshare version 2 API.

Actually the second version of the version 2 APIs. Lots of changes have been made by Figshare, mostly expanding what is returned from the API calls, but they also added some fields. Looks mostly backwards compatible.

## FEATURES/PROBLEMS:

* Stats API not implemented.
* oai pmh api not implemented.
* Need to build a test suite
* impersonate option, for PrivateArticles, PrivateCollections and PrivateProjects ignored for DELETE, and non-json POST and PUT.

## SYNOPSIS:

```
require 'figshare_api_v2'

# Either initialize once, and call @figshare.authors.x @figshare.institutions.x, ...
@figshare = Figshare::Init.new(figshare_user: 'figshare_admin', conf_dir: "#{__dir__}/conf")

@figshare.authors.detail(author_id: 12345) { |a| puts a }
@figshare.institutions.private_articles { |article| puts article }
#...

# Or initialize each class individually
@authors = Figshare::Authors.new(figshare_user: 'figshare_admin', conf_dir: "#{__dir__}/conf")
@institutions = Figshare::Institutions.new(figshare_user: 'figshare_admin', conf_dir: "#{__dir__}/conf")

@authors.detail(author_id: 12345) { |a| puts a }
@institutions.private_articles { |article| puts article }

#...
````

## REQUIREMENTS:

* depends on 'wikk_webbrowser' gem
* depends on 'wikk_json' gem (beware: adds to_j to the base classes)

## INSTALL:

* sudo gem install figshare_api_v2

## LICENSE:

The MIT License

Copyright (c) 2020

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
