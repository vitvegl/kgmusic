require 'kgmusic/version'
require 'kgmusic/api'
#require 'unicode_utils/titlecase'
#require 'fileutils'
require 'curl'
require 'nokogiri'

module KgMusic
  module BaseMod
    #include UnicodeUtils

    UNALLOWED_SYMBOLS = [
      "`", "~", "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", ",", "_", "=",
      "+", "[", "{", "]", "}", "\\", "|", ";", ":", "\"", "<", ".", ">", "/", "?"
    ]

    protected
    def create_work_dir
      @work_dir = File.join(ENV['HOME'], 'kgmusic')
      Dir.mkdir(@work_dir, 0700) unless Dir.exist?(@work_dir)
    end

    def go_to(url, follow_location = true, **args)
      request = __perform_request(url, follow_location, **args)
      request.body_str
    end

    def __build_request(url, follow_location, **args)
      args.include?(:params) ? __url = Curl.urlalize(url, args[:params])
                             : __url = Curl.urlalize(url)

      c = Curl::Easy.new(__url) { |c| c.follow_location = follow_location }
      args[:opts].map { |k, v| c.set(k.to_sym, v) } if args.include?(:opts)
      c
    end

    def __perform_request(url, follow_location = false, **args)
      request = __build_request(url, follow_location, **args)
      request.perform
      request
    end

    def has_unallowed_symbols?(key)
      counter = UNALLOWED_SYMBOLS.select {|s| key.include?(s)}
      counter.size > 0 ? true : false
    end

    def strip_unallowed_symbols!(key)
      UNALLOWED_SYMBOLS.map {|s| key.delete!(s)}
    end

    def parse_html doc
      Nokogiri::HTML.parse doc
    end

    def validate(key)
      if key.is_a? String
        strip_unallowed_symbols!(key) if has_unallowed_symbols?(key)
        key
        #words = key.split
        #if words.size == 1
        #  key[0] =~ /^[[:lower:]]$/ ? titlecase(key) : key
        #elsif words.size > 1
        #  words.map {|w| titlecase(w) unless (w[0].ord === w[0])}.join(" ")
        #end
      else
        raise KeyError
      end
    end

    def parse_http_header(str)
      list = str.split(/[\r\n]+/).map(&:strip)
      Hash[list.flat_map { |s| s.scan(/^(\S+): (.+)/) }]
    end

    def __head_request(url)
      r = __perform_request(url, { opts: { nobody: true } })
      parse_http_header r.header_str
    end

    def get_content_length(uri)
      response = __head_request(uri)
      response['Content-Length'].to_i
    end

    def obtain_final_url(__uri)
      response = __perform_request(__uri)
      __header_str = response.header_str
      __headers = parse_http_header(__header_str)
      __headers['Location'] || __uri
    end

    def get_album_info(url)
      __response = go_to(url)
      doc = parse_html(__response)
      doc.css('div.album-info')
    end

    def get_direct_link(__url)
      __response = go_to(__url)
      doc = parse_html(__response)
      @direct_link = doc.css('a.download-block').attr('href').to_s
    end
  end
end
