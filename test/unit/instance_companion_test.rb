require 'test_helper'

module IndexTanked

  class InstanceCompanionTest < Test::Unit::TestCase
    context "An instance of a class with index-tanked included" do
      setup do
        class AnimalsRawr
          include IndexTanked

          attr_accessor :fish, :dog

          def initialize(opts={})
            @fish = opts[:fish]
            @dog = opts[:dog]
          end

          index_tank :index => 'animals', :url => "http://example.com" do
            doc_id lambda { |instance| "animals/fish/#{instance.fish}/dog/#{instance.dog}" }
            field  :dog
            field  :fish, :text => nil
            text   "animals fish dogs"
            var 0, 42
          end
        end

        @instance = AnimalsRawr.new({:fish => 'trout', :dog => 'shiba inu'})
      end

      teardown do
        AnimalsRawr.index_tanked.fields.clear
        AnimalsRawr.index_tanked.texts.clear
        AnimalsRawr.index_tanked.variables.clear
      end

      context "has a companion object for index tanked, the companion" do
        setup do
          @companion = @instance.index_tanked
        end

        should "serialize its data for adding to index tank" do
          assert_equal [{:text => "animals fish dogs shiba inu",
                         :fish => "trout",
                         :dog => "shiba inu"},
                        {:variables => { 0 => 42}}], @companion.data
        end

        should "serialize its data into a document hash for adding in batches" do
          document = {
            :docid => "animals/fish/trout/dog/shiba inu",
            :fields => {
              :fish => "trout", :dog => "shiba inu", :text => "animals fish dogs shiba inu"
            },
            :variables => {
              0 => 42
            }
          }
          assert_equal document, @companion.document_for_batch_addition
        end

        should "generate a doc_id for the instance" do
          assert_equal "animals/fish/trout/dog/shiba inu", @companion.doc_id
        end

        should "access its classes' index" do
          assert @companion.index.is_a? IndexTank::Index
        end

        should "return an IndexTank::Client" do
          assert @companion.api_client.is_a? IndexTank::Client
        end
      end
    end
  end
end
