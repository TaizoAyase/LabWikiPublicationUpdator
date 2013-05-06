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

  def test_initialize_pubmedid
		pubmed_id = 23535598
		article = PubMedArticle.new(pubmed_id)
		assert_equal article.pubmedid.to_i, pubmed_id
  end

	def test_parse_and_output
		test_file = "test/fixtures/wiki_article_template.txt"
		str = File.read(test_file)
		article = PubMedArticle.parse(str)
		assert_equal article.output.gsub("\n", ""), str.gsub("\n", "")
	end

  def test_initialize_non_argument_connot_get_year
    article = PubMedArticle.new
    assert_nil article.year
  end

  def test_initialize_non_argument_connot_get_pubmedid
    article = PubMedArticle.new
    assert_nil article.pubmedid
  end

  def test_search_not_nil
    # search all article in PubMed
    result = PubMedArticle.search("All[Filter]")
    assert_not_nil result.first
  end
end
