require 'curl'
require 'nokogiri'

module KgMusic

  module API

    module Collection

      class Generator

        private_class_method :new

        def initialize(url)
          c = Curl::Easy.new(url) { |c| c.follow_location = true; c.perform }
          root = Nokogiri::HTML.parse(c.body_str)
          last_page_uri_str = root.xpath("//div[@class='pager']//li[@class='last']/a/@href").text
          @@pages = last_page_uri_str.scan(/\d+$/).sample.to_i
        end

        def self.artists
          new('kibergrad.fm/artists')
          Fiber.new do
            (1..@@pages).map do |page|
              c = Curl::Easy.new("kibergrad.fm/artists?page=#{page}") do |c|
                c.follow_location = true
                c.perform
              end
              root = Nokogiri::HTML.parse(c.body_str)
              result = root.xpath("//div[@class='artist-item']").reduce([]) do |out, artist|
                out << {
                  :artist => artist.css('div.artist-info').at('a').text.strip,
                  :albums => artist.css('ul.artist-albums/li').reduce([]) { |albums, album| albums << album.at('img').attr('title') },
                  :tracks => artist.css('ul.artist-songs/li').reduce([]) { |tracks, track| tracks << track.css('a').text },
                  :all_albums => artist.css('div.albums-count').at('a').text.strip,
                  :all_tracks => artist.css('div.songs-count').at('a').text.strip
                }
              end
                Fiber.yield result
            end
          end
        end

        def self.albums
          new('kibergrad.fm/albums')

          Fiber.new do
            (1..@@pages).map do |page|
              c = Curl::Easy.new("kibergrad.fm/albums?page=#{page}") do |c|
                c.follow_location = true
                c.perform
              end

              root = Nokogiri::HTML.parse(c.body_str)
              result = root.xpath("//div[@class='album-item clearfix']").reduce([]) do |out, list|
                out << {
                  :artist => list.css('.album-desc/tr/td')[1].text.strip,
                  :album => list.css('.album-info/h3').text.strip,
                  :link => list.css('.album-info/h3/a/@href').children.to_s,
                  :year => list.css('.album-desc/tr/td')[3].text.strip,
                  :tags => list.css('.album-desc/tr/td')[5].text.strip
                }
              end
                Fiber.yield result
            end
          end
        end

      end

    end

  end

end
