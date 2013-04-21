#encoding: utf-8

require "ap"
require "./publication"
require "./article"

#f = "./labwiki_before.txt"
out = Publication.new
pub = PubMedArticle.search("Nureki O")
pub.each do |id|
	out << PubMedArticle.new(id)
end

puts out.output
