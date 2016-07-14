require "kgmusic/basemod"
#require "progressbar"

module KgMusic

  class Client < API::Client; end

  class Artists < API::Artists; end

  class Albums < API::Albums; end

  class Collection < API::Collection::Generator; end

  class Downloader

    include BaseMod

    attr_reader :artist, :album, :direct_link

    def initialize(artist:, album:)
      @artist = validate(artist)
      @album = validate(album)
    end

    def search

      url = 'kibergrad.fm/search'

      params = { q: "#{self.artist} - #{self.album}", p: "albums" }

      response = go_to(url, params) { |r| r.follow_location = true }
      doc = Nokogiri::HTML.parse(response)

      album_info = doc.css('div.album-info')

      unless album_info.nil?
        begin
          if album_info.size == 1
            download_page = album_info.css('h3').at('a').attr('href')
          elsif album_info.size > 1
            full_match_index = album_info.css('h3').find_index { |element| element.at('a').children.to_s === @album }
            result = album_info.css('h3')[full_match_index]
            download_page = result.at('a').attr('href')
          end
            @direct_link = get_direct_link(download_page)
        rescue
        end
      end

    end

    def download_album

        create_work_dir()
        url = obtain_final_url(@direct_link)

        outfile = File.join(@@work_dir, "#{@artist} - #{@album}.zip")
        content_length = get_content_length url

        File.open(outfile, 'ab') do |f|

          fsize = File.size(outfile)

          req = __build_request(url) do |r|
          
            r.set(:resume_from, fsize) if fsize > 0
          
            r.on_body { |body| f.write(body) }
          
            r.on_progress do |dlt, dln, _, _|
              printf("\r %i of %i MBytes received ...", (dln / 1_000_000), (dlt / 1_000_000))
              true
            end
          
          end
          
          req.perform if content_length > fsize

        end

      nil
    end
  end
end
