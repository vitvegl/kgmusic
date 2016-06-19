require 'spec_helper'
require 'open-uri'

module KgMusic

  describe Downloader do
    before do
      @m = KgMusic::Downloader.new artist: "Metall%ica$", album: "Reload^"
    end

    it 'keys validation' do
      expect(@m.artist).to eq "Metallica"
      expect(@m.album).to eq "Reload"
    end

    it 'direct_link' do
      result = @m.search
      expect(URI.parse(result)).to be_kind_of(URI::Generic)
    end

  end

end