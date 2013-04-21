#encoding: utf-8

require "ap"
require "./publication"
require "./article"
require "yaml"

config = YAML.load("conf.yaml")

#f = "./labwiki_before.txt"
out = Publication.new
pub = PubMedArticle.search(config["keyword"])
pub.each do |id|
	out << PubMedArticle.new(id)
end

puts out.output
