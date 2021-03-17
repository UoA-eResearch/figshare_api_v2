#!/usr/local/bin/ruby
require 'figshare_api_v2'


#BASE_DIR = 'Hadden/'
#article_list = [
#  { :dir => "#{BASE_DIR}Hadden G1 Gentoo head_fig 6", :article_id => 12924782 },
#  { :dir => "#{BASE_DIR}Hadden Gentoo eye detail_fig 3", :article_id => 13180055 },
#   { :dir => "#{BASE_DIR}Hadden Gentoo eye detail_fig 3", :article_id => 13115888 },
#  { :dir => "#{BASE_DIR}Hadden K1 King K203 head_fig 5/King_Penguin_K203_ABI_ Y black Y Slices", :article_id => 12924744 },
#  { :dir => "#{BASE_DIR}Hadden K2 King K208 L eye_fig 8 a, b, c/King eye muscle rec", :article_id => 12924741 },
#  { :dir => "#{BASE_DIR}Hadden L1 Little penguin head_fig 7a, b/Penguin Rec", :article_id => 12924735 },
#  { :dir => "#{BASE_DIR}Hadden Ossicle 10449 A_fig 1 b.  Fig 2/AV 10449 Rec", :article_id => 12924734 },
#  { :dir => "#{BASE_DIR}Hadden ossicle 1178 A 2nd_fig 4", :article_id => 12924749 },
#  { :dir => "#{BASE_DIR}Hadden Pub ossicle raw  tiff", :article_id => 12924713 },
#   { :dir => "/mnt/Hadden Little penguin head", :article_id => 13206026 }, #Title: Hadden Little penguin micro CT IKI stained head
#   { :dir => "#{BASE_DIR}/AV 1181 C__IR", :article_id => 12924753 },
#   { :dir => "#{BASE_DIR}Gentoo_chick__IR", :article_id => 13213907 },
#]


def create_articles(article_list:)
  output = []
  article_list.each do |a|
    if a[:article_id] == 0
      body = @figshare.private_articles.body(
              title: a[:title], 
              description: a[:description], 
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
        output << "\{ :dir => \#\{BASE_DIR\}#{File.basename(a[:dir])}, :article_id => #{article_id} \},"
      end
    end
  end
  puts
  output.each do |o|
    puts o
  end
end
    
def upload_articles(article_list:)
  article_list.each do |a|
    puts "Upload Dir #{a[:dir]}"
    #@figshare.upload.upload_dir(article_id: a[:article_id], directory: a[:dir], trace: 1)
  end

  puts "Added   #{@figshare.upload.new_count}"
  puts "Bad MD5 #{@figshare.upload.bad_count}"
end

BASE_DIR = 'data_2021-03-16/'

article_list_create = [
  { :dir => "#{BASE_DIR}AV 11055 A", :title => 'Hadden royal penguin (AV 11055 A) micro CT scleral ring', :description => 'The following scleral rings are all in the collection of Otago Museum, Dunedin: three from Snares crested penguins (Eudyptes robustus) collection IDs AV 10449 A, AV 1178 A and AV 10449, one from a royal penguin (Eudyptes schlegeli), collection ID AV 11055 A,  one from a yellow-eyed penguin (Megadyptes antipodes), collection ID AV 1181 C, six from Fiordland crested penguins (Eudyptes pachyrhynchus) collection IDs AV 966 A, 964 A, 1179 A, AV 7889 A, AV 7889 B, AV 1134 A and six labelled as being from little penguins (because of the location of their collection in and around Dunedin, probably Eudyptula novaehollandiae), collection IDs AV 800 A, AV 800 B, AV 957 A, AV 958 A, AV 958 B, AV 959 A.', :article_id => 0 },
  { :dir => "#{BASE_DIR}AV 1134 A", :title => 'Hadden Fiordland crested penguin (AV 1134 A) micro CT scleral ring',  :description => 'The following scleral rings are all in the collection of Otago Museum, Dunedin: three from Snares crested penguins (Eudyptes robustus) collection IDs AV 10449 A, AV 1178 A and AV 10449, one from a royal penguin (Eudyptes schlegeli), collection ID AV 11055 A,  one from a yellow-eyed penguin (Megadyptes antipodes), collection ID AV 1181 C, six from Fiordland crested penguins (Eudyptes pachyrhynchus) collection IDs AV 966 A, 964 A, 1179 A, AV 7889 A, AV 7889 B, AV 1134 A and six labelled as being from little penguins (because of the location of their collection in and around Dunedin, probably Eudyptula novaehollandiae), collection IDs AV 800 A, AV 800 B, AV 957 A, AV 958 A, AV 958 B, AV 959 A.', :article_id => 0 },
  { :dir => "#{BASE_DIR}AV 1334 B", :title => 'Hadden Fiordland crested penguin (AV 1134 B) micro CT scleral ring',  :description => 'The following scleral rings are all in the collection of Otago Museum, Dunedin: three from Snares crested penguins (Eudyptes robustus) collection IDs AV 10449 A, AV 1178 A and AV 10449, one from a royal penguin (Eudyptes schlegeli), collection ID AV 11055 A,  one from a yellow-eyed penguin (Megadyptes antipodes), collection ID AV 1181 C, six from Fiordland crested penguins (Eudyptes pachyrhynchus) collection IDs AV 966 A, 964 A, 1179 A, AV 7889 A, AV 7889 B, AV 1134 A and six labelled as being from little penguins (because of the location of their collection in and around Dunedin, probably Eudyptula novaehollandiae), collection IDs AV 800 A, AV 800 B, AV 957 A, AV 958 A, AV 958 B, AV 959 A.', :article_id => 0 },
  { :dir => "#{BASE_DIR}AV 1178 A", :title => 'Hadden Snares crested penguin (AV 1178 A) micro CT scleral ring',  :description => 'The following scleral rings are all in the collection of Otago Museum, Dunedin: three from Snares crested penguins (Eudyptes robustus) collection IDs AV 10449 A, AV 1178 A and AV 10449, one from a royal penguin (Eudyptes schlegeli), collection ID AV 11055 A,  one from a yellow-eyed penguin (Megadyptes antipodes), collection ID AV 1181 C, six from Fiordland crested penguins (Eudyptes pachyrhynchus) collection IDs AV 966 A, 964 A, 1179 A, AV 7889 A, AV 7889 B, AV 1134 A and six labelled as being from little penguins (because of the location of their collection in and around Dunedin, probably Eudyptula novaehollandiae), collection IDs AV 800 A, AV 800 B, AV 957 A, AV 958 A, AV 958 B, AV 959 A.', :article_id => 0 },
  { :dir => "#{BASE_DIR}AV 1179 A", :title => 'Hadden Fiordland crested penguin (AV 1179 A) micro CT scleral ring',  :description => 'The following scleral rings are all in the collection of Otago Museum, Dunedin: three from Snares crested penguins (Eudyptes robustus) collection IDs AV 10449 A, AV 1178 A and AV 10449, one from a royal penguin (Eudyptes schlegeli), collection ID AV 11055 A,  one from a yellow-eyed penguin (Megadyptes antipodes), collection ID AV 1181 C, six from Fiordland crested penguins (Eudyptes pachyrhynchus) collection IDs AV 966 A, 964 A, 1179 A, AV 7889 A, AV 7889 B, AV 1134 A and six labelled as being from little penguins (because of the location of their collection in and around Dunedin, probably Eudyptula novaehollandiae), collection IDs AV 800 A, AV 800 B, AV 957 A, AV 958 A, AV 958 B, AV 959 A.', :article_id => 0 },
  { :dir => "#{BASE_DIR}AV 1909 C", :title => 'Hadden Snares crested penguin (AV 1909 C) micro CT scleral ring',  :description => 'The following scleral rings are all in the collection of Otago Museum, Dunedin: three from Snares crested penguins (Eudyptes robustus) collection IDs AV 10449 A, AV 1178 A and AV 10449, one from a royal penguin (Eudyptes schlegeli), collection ID AV 11055 A,  one from a yellow-eyed penguin (Megadyptes antipodes), collection ID AV 1181 C, six from Fiordland crested penguins (Eudyptes pachyrhynchus) collection IDs AV 966 A, 964 A, 1179 A, AV 7889 A, AV 7889 B, AV 1134 A and six labelled as being from little penguins (because of the location of their collection in and around Dunedin, probably Eudyptula novaehollandiae), collection IDs AV 800 A, AV 800 B, AV 957 A, AV 958 A, AV 958 B, AV 959 A.', :article_id => 0 },
  { :dir => "#{BASE_DIR}AV 7889 A", :title => 'Hadden Fiordland crested penguin (AV 7889 A) micro CT scleral ring',  :description => 'The following scleral rings are all in the collection of Otago Museum, Dunedin: three from Snares crested penguins (Eudyptes robustus) collection IDs AV 10449 A, AV 1178 A and AV 10449, one from a royal penguin (Eudyptes schlegeli), collection ID AV 11055 A,  one from a yellow-eyed penguin (Megadyptes antipodes), collection ID AV 1181 C, six from Fiordland crested penguins (Eudyptes pachyrhynchus) collection IDs AV 966 A, 964 A, 1179 A, AV 7889 A, AV 7889 B, AV 1134 A and six labelled as being from little penguins (because of the location of their collection in and around Dunedin, probably Eudyptula novaehollandiae), collection IDs AV 800 A, AV 800 B, AV 957 A, AV 958 A, AV 958 B, AV 959 A.', :article_id => 0 },
  { :dir => "#{BASE_DIR}AV 7889 B", :title => 'Hadden Fiordland crested penguin (AV 7889 B) micro CT scleral ring',  :description => 'The following scleral rings are all in the collection of Otago Museum, Dunedin: three from Snares crested penguins (Eudyptes robustus) collection IDs AV 10449 A, AV 1178 A and AV 10449, one from a royal penguin (Eudyptes schlegeli), collection ID AV 11055 A,  one from a yellow-eyed penguin (Megadyptes antipodes), collection ID AV 1181 C, six from Fiordland crested penguins (Eudyptes pachyrhynchus) collection IDs AV 966 A, 964 A, 1179 A, AV 7889 A, AV 7889 B, AV 1134 A and six labelled as being from little penguins (because of the location of their collection in and around Dunedin, probably Eudyptula novaehollandiae), collection IDs AV 800 A, AV 800 B, AV 957 A, AV 958 A, AV 958 B, AV 959 A.', :article_id => 0 },
  { :dir => "#{BASE_DIR}AV 800 A", :title => 'Hadden little penguin (AV 800 A) micro CT scleral ring',  :description => 'The following scleral rings are all in the collection of Otago Museum, Dunedin: three from Snares crested penguins (Eudyptes robustus) collection IDs AV 10449 A, AV 1178 A and AV 10449, one from a royal penguin (Eudyptes schlegeli), collection ID AV 11055 A,  one from a yellow-eyed penguin (Megadyptes antipodes), collection ID AV 1181 C, six from Fiordland crested penguins (Eudyptes pachyrhynchus) collection IDs AV 966 A, 964 A, 1179 A, AV 7889 A, AV 7889 B, AV 1134 A and six labelled as being from little penguins (because of the location of their collection in and around Dunedin, probably Eudyptula novaehollandiae), collection IDs AV 800 A, AV 800 B, AV 957 A, AV 958 A, AV 958 B, AV 959 A.', :article_id => 0 },
  { :dir => "#{BASE_DIR}AV 800 B", :title => 'Hadden little penguin (AV 800 B) micro CT scleral ring',  :description => 'The following scleral rings are all in the collection of Otago Museum, Dunedin: three from Snares crested penguins (Eudyptes robustus) collection IDs AV 10449 A, AV 1178 A and AV 10449, one from a royal penguin (Eudyptes schlegeli), collection ID AV 11055 A,  one from a yellow-eyed penguin (Megadyptes antipodes), collection ID AV 1181 C, six from Fiordland crested penguins (Eudyptes pachyrhynchus) collection IDs AV 966 A, 964 A, 1179 A, AV 7889 A, AV 7889 B, AV 1134 A and six labelled as being from little penguins (because of the location of their collection in and around Dunedin, probably Eudyptula novaehollandiae), collection IDs AV 800 A, AV 800 B, AV 957 A, AV 958 A, AV 958 B, AV 959 A.', :article_id => 0 },
  { :dir => "#{BASE_DIR}AV 957 A", :title => 'Hadden little penguin (AV 957 A) micro CT scleral ring',  :description => 'The following scleral rings are all in the collection of Otago Museum, Dunedin: three from Snares crested penguins (Eudyptes robustus) collection IDs AV 10449 A, AV 1178 A and AV 10449, one from a royal penguin (Eudyptes schlegeli), collection ID AV 11055 A,  one from a yellow-eyed penguin (Megadyptes antipodes), collection ID AV 1181 C, six from Fiordland crested penguins (Eudyptes pachyrhynchus) collection IDs AV 966 A, 964 A, 1179 A, AV 7889 A, AV 7889 B, AV 1134 A and six labelled as being from little penguins (because of the location of their collection in and around Dunedin, probably Eudyptula novaehollandiae), collection IDs AV 800 A, AV 800 B, AV 957 A, AV 958 A, AV 958 B, AV 959 A.', :article_id => 0 },
  { :dir => "#{BASE_DIR}AV 958 A", :title => 'Hadden little penguin (AV 958 A) micro CT scleral ring',  :description => 'The following scleral rings are all in the collection of Otago Museum, Dunedin: three from Snares crested penguins (Eudyptes robustus) collection IDs AV 10449 A, AV 1178 A and AV 10449, one from a royal penguin (Eudyptes schlegeli), collection ID AV 11055 A,  one from a yellow-eyed penguin (Megadyptes antipodes), collection ID AV 1181 C, six from Fiordland crested penguins (Eudyptes pachyrhynchus) collection IDs AV 966 A, 964 A, 1179 A, AV 7889 A, AV 7889 B, AV 1134 A and six labelled as being from little penguins (because of the location of their collection in and around Dunedin, probably Eudyptula novaehollandiae), collection IDs AV 800 A, AV 800 B, AV 957 A, AV 958 A, AV 958 B, AV 959 A.', :article_id => 0 },
  { :dir => "#{BASE_DIR}AV 958 B", :title => 'Hadden little penguin (AV 958 B) micro CT scleral ring',   :description => 'The following scleral rings are all in the collection of Otago Museum, Dunedin: three from Snares crested penguins (Eudyptes robustus) collection IDs AV 10449 A, AV 1178 A and AV 10449, one from a royal penguin (Eudyptes schlegeli), collection ID AV 11055 A,  one from a yellow-eyed penguin (Megadyptes antipodes), collection ID AV 1181 C, six from Fiordland crested penguins (Eudyptes pachyrhynchus) collection IDs AV 966 A, 964 A, 1179 A, AV 7889 A, AV 7889 B, AV 1134 A and six labelled as being from little penguins (because of the location of their collection in and around Dunedin, probably Eudyptula novaehollandiae), collection IDs AV 800 A, AV 800 B, AV 957 A, AV 958 A, AV 958 B, AV 959 A.', :article_id => 0 },
  { :dir => "#{BASE_DIR}AV 959 A", :title => 'Hadden little penguin (AV 959 A) micro CT scleral ring',  :description => 'The following scleral rings are all in the collection of Otago Museum, Dunedin: three from Snares crested penguins (Eudyptes robustus) collection IDs AV 10449 A, AV 1178 A and AV 10449, one from a royal penguin (Eudyptes schlegeli), collection ID AV 11055 A,  one from a yellow-eyed penguin (Megadyptes antipodes), collection ID AV 1181 C, six from Fiordland crested penguins (Eudyptes pachyrhynchus) collection IDs AV 966 A, 964 A, 1179 A, AV 7889 A, AV 7889 B, AV 1134 A and six labelled as being from little penguins (because of the location of their collection in and around Dunedin, probably Eudyptula novaehollandiae), collection IDs AV 800 A, AV 800 B, AV 957 A, AV 958 A, AV 958 B, AV 959 A.', :article_id => 0 },
  { :dir => "#{BASE_DIR}AV 964 A", :title => 'Hadden Fiordland crested penguin (AV 964 A) micro CT scleral ring',  :description => 'The following scleral rings are all in the collection of Otago Museum, Dunedin: three from Snares crested penguins (Eudyptes robustus) collection IDs AV 10449 A, AV 1178 A and AV 10449, one from a royal penguin (Eudyptes schlegeli), collection ID AV 11055 A,  one from a yellow-eyed penguin (Megadyptes antipodes), collection ID AV 1181 C, six from Fiordland crested penguins (Eudyptes pachyrhynchus) collection IDs AV 966 A, 964 A, 1179 A, AV 7889 A, AV 7889 B, AV 1134 A and six labelled as being from little penguins (because of the location of their collection in and around Dunedin, probably Eudyptula novaehollandiae), collection IDs AV 800 A, AV 800 B, AV 957 A, AV 958 A, AV 958 B, AV 959 A.',  :article_id => 0 },
  { :dir => "#{BASE_DIR}AV 966 A", :title => 'Hadden Fiordland crested penguin (AV 966 A) micro CT scleral ring',  :description => 'The following scleral rings are all in the collection of Otago Museum, Dunedin: three from Snares crested penguins (Eudyptes robustus) collection IDs AV 10449 A, AV 1178 A and AV 10449, one from a royal penguin (Eudyptes schlegeli), collection ID AV 11055 A,  one from a yellow-eyed penguin (Megadyptes antipodes), collection ID AV 1181 C, six from Fiordland crested penguins (Eudyptes pachyrhynchus) collection IDs AV 966 A, 964 A, 1179 A, AV 7889 A, AV 7889 B, AV 1134 A and six labelled as being from little penguins (because of the location of their collection in and around Dunedin, probably Eudyptula novaehollandiae), collection IDs AV 800 A, AV 800 B, AV 957 A, AV 958 A, AV 958 B, AV 959 A.',  :article_id => 0 },
  { :dir => "#{BASE_DIR}King 055 A", :title => 'Hadden king penguin (King 055 A) micro CT scleral ring', :description => 'Two king penguin (Aptenodytes patagonicus) scleral rings are also included, King 055 A and King 055 B, currently held in the Department of Ophthalmology, University of Auckland.', :article_id => 0 },
  { :dir => "#{BASE_DIR}King 055 B", :title => 'Hadden king crested penguin (King 055 B) micro CT scleral ring', :description => 'Two king penguin (Aptenodytes patagonicus) scleral rings are also included, King 055 A and King 055 B, currently held in the Department of Ophthalmology, University of Auckland.',:article_id => 0 },
]

@figshare = Figshare::Init.new(figshare_user: 'figshare_admin', conf_dir: "#{__dir__}/conf")
@user = { 'id' => 1188933 } #Dane 

# Created articles
#create_articles(article_list: article_list_create)

article_list_upload = [
  { :dir => "#{BASE_DIR}AV 11055 A", :article_id => 14226644 },
  { :dir => "#{BASE_DIR}AV 1134 A", :article_id => 14226647 },
  { :dir => "#{BASE_DIR}AV 1334 B", :article_id => 14226650 },
  { :dir => "#{BASE_DIR}AV 1178 A", :article_id => 14226653 },
  { :dir => "#{BASE_DIR}AV 1179 A", :article_id => 14226656 },
  { :dir => "#{BASE_DIR}AV 1909 C", :article_id => 14226659 },
  { :dir => "#{BASE_DIR}AV 7889 A", :article_id => 14226662 },
  { :dir => "#{BASE_DIR}AV 7889 B", :article_id => 14226665 },
  { :dir => "#{BASE_DIR}AV 800 A", :article_id => 14226668 },
  { :dir => "#{BASE_DIR}AV 800 B", :article_id => 14226671 },
  { :dir => "#{BASE_DIR}AV 957 A", :article_id => 14226674 },
  { :dir => "#{BASE_DIR}AV 958 A", :article_id => 14226677 },
  { :dir => "#{BASE_DIR}AV 958 B", :article_id => 14226680 },
  { :dir => "#{BASE_DIR}AV 959 A", :article_id => 14226683 },
  { :dir => "#{BASE_DIR}AV 964 A", :article_id => 14226686 },
  { :dir => "#{BASE_DIR}AV 966 A", :article_id => 14226689 },
  { :dir => "#{BASE_DIR}King 055 A", :article_id => 14226692 },
  { :dir => "#{BASE_DIR}King 055 B", :article_id => 14226695 },
]

upload_articles(article_list: article_list_upload)

