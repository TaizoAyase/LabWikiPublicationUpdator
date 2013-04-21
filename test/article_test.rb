#encoding: utf-8

require "test/unit"
require "./article"

class PubMedArticleTest < Test::Unit::TestCase
	def test_initialize_year
		pubmed_id = 23535598
		article = PubMedArticle.new(pubmed_id)
		true_year = 2013
		assert_equal article.year.to_i, true_year
	end

	def test_parse
		test_file = "test/fixtures/wiki_article_template.txt"
		str = File.read(test_file)
		article = PubMedArticle.new.parser(str)
		assert_equal article.output.gsub("\n", ""), str.gsub("\n", "")
	end
end
