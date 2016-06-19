require 'spec_helper'

module KgMusic

  module API

    describe Client do

      before do
        @cli = KgMusic::Client.new
      end

      describe '#popular_artists' do
        it 'return array' do
          expect(@cli.popular_artists).to be_kind_of(Array)
        end
      end

      describe '#popular_genres' do
        it 'return array' do
          expect(@cli.popular_genres).to be_kind_of(Array)
        end
      end

      describe '#all_genres' do
        it 'return array' do
          expect(@cli.all_genres).to be_kind_of(Array)
        end
      end
    end

  end

end
