require 'helpers'
require 'pdf/reader'
require 'date'

RSpec.describe do
  before do
    @debug = false
    @ignore = %w[]
    @ignore_category = []
    @headers = %w[.* Montag Dienstag Mittwoch Donnerstag Freitag]
    @header_regexp = header_regexp
  end

  let(:text) do
    PDF::Reader.new("pdf/16.02.2026 - 22.02.2026_1.pdf").pages.first.text
  end

  describe '#parse' do
    subject { parse(text) }

    it 'returns an Array' do
      is_expected.to be_an Array
    end

    it 'returns a Date and a Hash' do
      expect(subject.size).to eq(2)
      expect(subject.first).to be_a Date
      expect(subject.last).to be_a Hash
    end

    context 'the returned menu' do
      subject(:menu) { parse(text).last }

      it 'has 5 elements' do
        expect(menu.size).to eq(5)
      end

      it 'has all of its keys be Strings' do
        expect(menu.keys).to all(be_a(String))
      end

      it 'has all of its values be Hashes' do
        expect(menu.values).to all(be_a(Hash))
      end
    end
  end
end
