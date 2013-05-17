#encoding: utf-8

require "ap"
require "bio"
require "yaml"

class Article

  attr_reader :pubmedid
  
  def initialize
    @year = nil
    @pubmedid = nil

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

  #ある文字列を与えたときに、それがArticleのどの要素になるか判断して
  #要素を追加するメソッド
  def parser(str)
    str_splitted = str.split("\n")
    str_splitted.each do |elem|
      next unless elem =~ /^(.):(.*)$/
      key, val = get_key_val(elem)
      @table[key] = val
    end
    self
  end
  
  def to_s
    @table.to_s
  end

  #出力用インスタンスメソッド
  def output
    out = ""
    out << "#pubref(){{"
    @table.each do |key, val|
      out <<  "#{key.to_s}: #{val.to_s}\n"
    end
    out << "}}\n"
    out
  end

  def ==(other)
    @pubmedid == other.pubmedid
  end

  private

  #既存のLabo Wikiの各エントリの各行からkeyとvalueを配列で返す
  def get_key_val(str)
    str.chomp!
    str =~ /^(.):(.*)$/
    key = $1.to_sym
    val_tmp = $2
    if val_tmp =~ /^\s*$/
      val = nil
    else
      val = val_tmp.gsub(/(^\s|\s+$)/, "")
    end
    return key, val
  end

end

#基本的に記事の情報はPubMedから取ってきている
#PubMed以外の場合も考えて、Articleクラスを継承して
#こちらにPubMed関連のメソッドを実装しておく
class PubMedArticle < Article
  include Comparable

  @@config = YAML.load(File.read("conf.yaml"))

  #NCBI用のEmailをセットしておく
  Bio::NCBI.default_email = @@config["email"]

  attr_reader :year

  def self.parse(str)
    PubMedArticle.new.parser(str)
  end

  #任意の検索ワードで検索し、PubMedIDを返すクラスメソッド
  #optionハッシュはBio::PubMedのesearchに従う
  def self.search(keyword = "", option = {})
    Bio::PubMed.esearch(keyword, option)
  end

  #PubMedIDを与えるコンストラクタ
  #ハッシュを生成し、MEDLINEオブジェクトからハッシュをセット
  def initialize(pubmed_id = nil)
    super()
    if pubmed_id
      @pubmedid = pubmed_id.to_i
      pubmed_to_medline
      medline_to_table
      @year = @medline.year
    end
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
    manuscript = Bio::PubMed.efetch(@pubmedid.to_s)
    @medline = Bio::MEDLINE.new(manuscript.first)
  end

  #セットされたMEDLINEオブジェクトから
  #ハッシュを設定
  def medline_to_table
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
