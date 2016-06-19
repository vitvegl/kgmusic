require "curl"
require "nokogiri"

module KgMusic

  module API

    class Artists

      private_class_method :new

      def initialize(url)
        c = Curl::Easy.new(url) do |c|
          c.follow_location = true
          c.perform
        end

        @@root = Nokogiri::HTML.parse(c.body_str)
        last_page_uri_str = @@root.xpath("//div[@class='pager']//li[@class='last']/a/@href").text
        @@pages = last_page_uri_str.scan(/\d+$/).sample.to_i
      end

      private

      def self.get_info
        @@root.xpath("//div[@class='artist-item']").reduce([]) do |out, artist|
          out << {
            :artist => artist.css('div.artist-info').at('a').text.strip,
            :albums => artist.css('ul.artist-albums/li').reduce([]) { |albums, album| albums << album.at('img').attr('title') },
            :tracks => artist.css('ul.artist-songs/li').reduce([]) { |tracks, track| tracks << track.css('a').text },
            :all_albums => artist.css('div.albums-count').at('a').text.strip,
            :all_tracks => artist.css('div.songs-count').at('a').text.strip
          }

        end
      end

      public

      def self.show_info ( number )
        new("kibergrad.fm/artists")
        if number == 1
          get_info
        elsif number.between?( 1, @@pages )
          new("kibergrad.fm/artists?page=#{number}")
          get_info
        else
          raise RangeError
        end

      end

    end

  end

end
