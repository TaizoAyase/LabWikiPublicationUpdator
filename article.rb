#encoding: utf-8

require "ap"
require "bio"
require "yaml"

class Article
	def initialize
		@title = nil
		@author = nil
		@journal = nil
		@vil = nil
		@page = nil
		@year = nil
		@pubmedid = nil
		@pdbid = nil

		@table = {
			:t => nil,
			:a => nil,
			:j => nil,
			:v => nil,
			:p => nil,
			:y => nil,
			:i => nil,
			:s => nil
		}
	end

	#ある文字列を与えたときに、
	#それがArticleのどの要素になるか判断して
	#要素を追加するインスタンスメソッド
	#既存の記事情報からこのRuby内で扱う
	#ハッシュ形式に変換する
	def parser(str)
		str.chomp!
		str =~ /^(.):(.*)$/
		key = $1.to_sym
		val_tmp = $2
		if val_tmp =~ /^\s*$/
			val = nil
		else
			val = val_tmp.gsub(/(^\s|\s+$)/, "")
		end
		
		@table[key] = val
		return @table
	end
	
	def to_s
		@table.to_s
	end

	#出力用インスタンスメソッド
	def output
		puts "#pubref(){{"
		@table.each do |key, val|
			puts "#{key.to_s}: #{val.to_s}"
		end
		puts "}}"
		print "\n"
	end
end

#基本的に記事の情報はPubMedから取ってきている
#PubMed以外の場合も考えて、Articleクラスを継承して
#こちらにPubMed関連のメソッドを実装しておく
class PubMedArticle < Article
	include Comparable

	str = File.read("conf.yaml")
	@@config = YAML.load(str)

	attr_reader :date
	attr_reader :year

	#任意の検索ワードで検索し、PubMedIDを返すクラスメソッド
	#optionハッシュはBio::PubMedのesearchに従う
	def self.search(keyword = "", option = {})
		#AyaseのGmailのアカウントで認証しておく
		#特に誰の認証で使うかはここでは関係ないだろう
		Bio::NCBI.default_email = @@config["email"]
		Bio::PubMed.esearch(keyword, option)
	end

	#PubMedIDを与えるコンストラクタ
	#ハッシュを生成し、privateメソッドを呼び出す
	#比較用の@dateを定義する
	def initialize(pubmed_id)
		super()
		@pubmedid = pubmed_id.to_i
		pubmed_to_medline
		table_set
		#pattern = "%Y %b %d"
		#@date = Date.strptime(@medline.date, pattern)
		@year = @medline.year
		return self
	end

	#<=>演算子の定義により、Array#sortが
	#使えるようにする
	#順序は日付順に定義される
	def <=>(other)
		raise ArgumentError unless other.instance_of? PubMedArticle
		self.date <=> other.date	
	end

	private
	#PubMedIDからMEDLINEオブジェクトの情報を取り出す
	def pubmed_to_medline
		raise unless @pubmedid
		puts @pubmedid
		manuscript = Bio::PubMed.efetch(@pubmedid.to_s)
		@medline = Bio::MEDLINE.new(manuscript.first)
	end

	#セットされたMEDLINEオブジェクトから
	#ハッシュを設定
	def table_set
		raise unless @medline

		@table = {
			:t => @medline.title,
			:a => @medline.authors,
			:j => @medline.journal,
			:v => @medline.volume,
			:p => @medline.pages,
			:y => @medline.year,
			:i => @pubmedid,
			:s => nil
		}
	end
end
