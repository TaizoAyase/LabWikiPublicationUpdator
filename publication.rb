#encoding: utf-8

require "ap"
require "bio"

class Publication
  attr_accessor :ary
  
  def self.parser(str)
    ary = str.split("\n")
    flag = false
    list = Publication.new
    while line = ary.shift
      line.chomp!
      case line
      when "#pubref(){{"
        art = Article.new
        flag = true
      when "}}"
        flag = false
        list.ary << art
      else
        art.parser(line) if flag
      end
    end
    return list
  end

  #記事情報はAry中の要素の1つ1つとして
  #格納される
  #つまりArrayの要素1つ=1つの記事
  def initialize
    @ary = []
    @yaer = nil
  end

  def set_year_range(from, to)
    @year = Range.new(from, to)
    return self
  end

  #要素の追加用演算子
  #Arrayと同じ感覚で扱える
  def <<(other)
    flag = nil
    @ary << other
    #flag = year_check
    flag = true
    if flag
      return self
    else
      puts "Warning:publish year is not correct."
      return self
    end
  end

  #出力用インスタンスメソッド
  def output
    @ary.each do |art|
      art.output
    end
  end

  def to_s
    @ary.to_s
  end

  private
  def year_check
    @ary.select! do |art|
      @year.include? art.year.to_i
    end
  end
end
