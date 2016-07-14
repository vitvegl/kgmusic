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
      @@work_dir = File.join(ENV['HOME'], 'kgmusic')
      Dir.mkdir(@@work_dir, 0700) unless Dir.exist?(@@work_dir)
    end

    def go_to(url, params = {}, &block)
      request = __perform_request(url, params, &block)
      request.body_str
    end

    def __build_request(url, params = {}, &block)
      __url = Curl.urlalize(url, params)
      Curl::Easy.new(__url, &block)
    end

    def __perform_request(url, params = {}, &block)
      request = __build_request(url, params, &block)
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
      request = __perform_request(url) { |r| r.set(:nobody, true) }

      parse_http_header(request.header_str)
    end

    def get_content_length(url)
      response = __head_request(url)
      response['Content-Length'].to_i
    end

    def obtain_final_url(url)
      response = __perform_request(url)
      headers = parse_http_header(response.header_str)

      headers['Location'] || url
    end

    def get_direct_link(url)
      response = go_to(url)
      doc = Nokogiri::HTML.parse(response)
      doc.css('a.download-block').attr('href').to_s
    end
  end
end
