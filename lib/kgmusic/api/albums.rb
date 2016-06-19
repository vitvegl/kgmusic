require 'curl'
require 'nokogiri'

module KgMusic
  module API
    class Albums
      private_class_method :new

      def initialize(url)
        c = Curl::Easy.new(url) do |c|
          c.follow_location = true
          c.perform
        end

        @@root = Nokogiri::HTML.parse(c.body_str)
        last_album_uri_str = @@root.xpath("//div[@class='pager']//li[@class='last']/a/@href").text
        @@pages = last_album_uri_str.scan(/\d+$/).sample.to_i
      end

      private

      def self.get_info
        @@root.xpath("//div[@class='album-item clearfix']").reduce([]) do |out, list|
          out << {
            :artist => list.css('.album-desc/tr/td')[1].text.strip,
            :album => list.css('.album-info/h3').text.strip,
            :link => list.css('.album-info/h3/a/@href').children.to_s,
            :year => list.css('.album-desc/tr/td')[3].text.strip,
            :tags => list.css('.album-desc/tr/td')[5].text.strip
          }
        end
      end

      public

      def self.show_info( number )
        new("kibergrad.fm/albums")
        if number == 1
          get_info
        elsif number.between?(1, @@pages)
          new("kibergrad.fm/albums?page=#{number}"); get_info
        else
          raise RangeError
        end
      end

    end # class Albums
  end # module API
end # module KgMusic
