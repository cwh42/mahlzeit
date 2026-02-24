require 'json'
require 'stringio'

RSpec.describe "mahlzeit.rb" do
  context "when no input file" do
    it 'prints a message' do
      expect { system %(./mahlzeit.rb) }
        .to output(a_string_including("one or more PDF-files"))
        .to_stderr_from_any_process
    end
  end

  context "with input file" do
    subject(:json) do
      cmd = %(./mahlzeit.rb #{v1 ? '-1' : ''} #{Dir.pwd}/spec/pdf/16.02.2026*.pdf)
      JSON.parse(`#{cmd}`)
    end

    let(:v1) { false }

    context 'default output format (v2)' do
      it 'outputs proper JSON' do
        expect(json).to be_an Array
      end

      context 'the returned menu' do
        subject(:menu) { json.first }

        it 'has a date' do
          expect(menu['date']).to a_string_matching(/2\d{3}-\d{2}-\d{2}/)
        end

        context 'the returned daily menu' do
          subject(:daily_menu) { menu.fetch('menu') }

          it 'is an Array' do
            expect(daily_menu).to be_an Array
          end

          it 'has 4 elements' do
            expect(daily_menu.size).to eq(4)
          end

          it 'has all of its elements be Strings' do
            expect(daily_menu).to all(be_a(String))
          end
        end
      end
    end

    context 'old output format' do
      let(:v1) { true }

      it 'outputs proper JSON' do
        expect(json).to be_a Hash
      end

      it 'all keys are a ISO 8601 week date' do
        expect(json.keys).to all(a_string_matching(/2\d{3}W\d{2}/))
      end

      context 'the returned menu' do
        subject(:menu) { json.values.first }

        it 'has 5 elements' do
          expect(menu.size).to eq(5)
        end

        it 'has all of its keys be Strings' do
          expect(menu.keys).to all(be_a(String))
        end

        it 'has all of its values be Hashes' do
          expect(menu.values).to all(be_a(Hash))
        end

        context 'the returned daily menu' do
          subject(:daily_menu) { menu.values.first }

          it 'has all of its keys and values be Strings' do
            expect(daily_menu.keys).to all(be_a(String))
            expect(daily_menu.values).to all(be_a(String))
          end
        end
      end
    end
  end
end
