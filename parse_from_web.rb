#encoding: utf-8

require 'open-uri'
require 'nokogiri'
require 'ap'
require './article'

url = 'http://www.nurekilab.net/index.php/ja?Publication'
html = open(url).read.encode('utf-8')
tds = Nokogiri::HTML.parse(html, url) 

ol_tag = tds.xpath('//ol/li')
puts 'size of li tag'
puts ol_tag.size

ary = []
lists.each do |ol|
  #inner = Nokogiri::HTML.parse(ol.inner_html)
  inner = ol
  inner.search("span[@class = pub_year]").text =~ /\d\d\d\d/
  year = Regexp.last_match.to_s.to_i
  year_range = 2011..2015
  break unless year_range.include? year #2011-2015年以前のものは処理しない
  ary << year

  url = inner.search("div[@class = pub_dblink]/a/@href").to_s
  /list_uids=(\d+)/ =~ url
  p_id = $1
  puts p_id 
end
ap ary

# 既存のArticleと新規のものとの比較だけなら、
# タイトル他の情報はパースしないで==で比較する
class WebArticle < Article
  def self.parse(url)
    ol_tag.size
  end

  def self.set_year_range(start, last)
    old, new = [start, last].sort
    @@year_range = old.to_i..new.to_i
    return @@year_range
  end

  def initialize(url)
    raise unless @@year_range
    html = open(url).read.encode('utf-8')
    tds = Nokogiri::HTML.parse(html, url)
    
    lists = tds.xpath('//ol/li')
    lists.each do |li_tag|
      
    end
  end

  def ==(other)
    @pubmedid.to_i == other.pubmedid.to_i
  end

  private

end
