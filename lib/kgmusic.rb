require "kgmusic/basemod"
#require "progressbar"

module KgMusic

  class Client < API::Client; end

  class Artists < API::Artists; end

  class Albums < API::Albums; end

  class Collection < API::Collection::Generator; end

  class Downloader

    include BaseMod

    attr_reader :artist, :album, :work_dir
    attr_reader :direct_link

    def initialize(artist:, album:)
      @artist = validate(artist)
      @album = validate(album)
      create_work_dir
    end

    protected

    def run
      url = 'kibergrad.fm/search'
      params = { q: "#{self.artist} - #{self.album}", p: "albums" }
      #album_info = get_album_info url, params

      response = go_to(url, { params: params })
      doc = parse_html(response)
      album_info = doc.css('div.album-info')

      unless album_info.nil?
        begin
          if album_info.size == 1
            download_page = album_info.css('h3').at('a').attr('href')
          elsif album_info.size > 1
            full_match_index = album_info.css('h3').find_index { |e| e.at('a').children.to_s === @album }
            result = album_info.css('h3')[full_match_index]
            download_page = result.at('a').attr('href')
          end
            get_direct_link download_page
        rescue
        end
      end
    end

    def get_album
      url = obtain_final_url @direct_link
      create_work_dir
      outfile = File.join(@work_dir, "#{self.artist} - #{self.album}.zip")
      content_length = get_content_length url

      begin
        File.open(outfile, 'ab+') do |f|
          fsize = File.size(outfile)
          c = Curl::Easy.new url do |curl|
            curl.set(:resume_from, fsize) if fsize > 0
            curl.on_body { |body| f.write body }
          end
          c.on_progress do |dlt, dln, ult, uln|
            printf("\r %i of %i MBytes received ...", (dln / 1_000_000), (dlt / 1_000_000))
            true
          end
          c.perform if content_length > fsize
        end
      rescue => ex
        puts ex.message
      end
        nil
    end

    public

    def search
      run
    end

    def download_album
      get_album
    end
  end
end
