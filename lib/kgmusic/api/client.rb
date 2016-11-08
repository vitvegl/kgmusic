require "curl"
require "nokogiri"

module KgMusic

  module API

    class Client

      def initialize
        c = Curl::Easy.new('kibergrad.fm') do |c|
          c.follow_location = true
          c.perform
        end
        @@root = Nokogiri::HTML.parse(c.body_str)
        @connect_time = c.connect_time
        @primary_ip = c.primary_ip
        @request_size = c.request_size
        @content_type = c.content_type
      end

      def popular_artists
        @@root.xpath("//div[@class='popular-artists']//li/a").reduce([]) do |artists, element|
          artists << element.text
        end
      end

      def popular_genres
        @@root.xpath("//div//ul[@class='aim-menu css']/li/a").reduce([]) do |popular_genres, element|
          popular_genres << element.text
        end
      end

      def all_genres
        @@root.xpath("//div//ul[@class='aim-menu css']//li/a").reduce([]) do |all_genres, element|
          all_genres << element.text
        end
      end

    end

  end

end
