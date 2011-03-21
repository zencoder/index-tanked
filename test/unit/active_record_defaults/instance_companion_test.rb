require 'test_helper'

module IndexTanked
  module ActiveRecordDefaults

    class InstanceCompanionTest < Test::Unit::TestCase
      context "An instance of a class with index-tanked included" do
        setup do
          class ::Person
            include IndexTanked

            index_tank :index => 'index-test', :url => "http://example.com" do
              field :name, :text => nil
              text  "some text, why not"
              var 0, 42
            end
          end

          IndexTanked::Configuration.index_availability = false
          IndexTanked::Configuration.add_to_index_fallback = lambda { |instance| return}

          @instance = Person.create! :name => 'Alphonse'
        end

        teardown do
          Person.index_tanked.fields.clear
          Person.index_tanked.texts.clear
          Person.index_tanked.variables.clear
          IndexTanked::Configuration.add_to_index_fallback = nil
          IndexTanked::Configuration.index_availability = nil
        end

        context "has a companion object for index tanked, the companion" do
          setup do
            @companion = @instance.index_tanked
          end

          should "serialize its data for adding to index tank" do
            assert_equal [{:text => "some text, why not",
                           :name => "Alphonse",
                           :model => "Person",
                           :timestamp => @instance.created_at.to_i},
                          {:variables => { 0 => 42}}], @companion.data
          end

          should "serialize its data into a document hash for adding in batches" do
            document = {
              :docid => "Person:#{@instance.id}",
              :fields => {
                :text => "some text, why not",
                :name => "Alphonse",
                :model => "Person",
                :timestamp => @instance.created_at.to_i
              },
              :variables => {
                0 => 42
              }
            }
            assert_equal document, @companion.document_for_batch_addition
          end

          should "generate a doc_id for the instance" do
            assert_equal "Person:#{@instance.id}", @companion.doc_id
          end

          should "access its classes' index" do
            assert @companion.index.is_a? IndexTank::Index
          end

          should "return an IndexTank::Client" do
            assert @companion.api_client.is_a? IndexTank::Client
          end

          should "return false for for dependencies_changed? if no dependent fields have changed" do
            assert_equal false, @companion.dependencies_changed?
          end

          should "return true for for dependencies_changed? if dependent fields have changed" do
            @instance.name = "fowlduck"
            assert_equal true, @companion.dependencies_changed?
          end
        end

        should "reload the object when it goes to index and gets an ActiveRecord::MissingAttributeError" do
          person = Person.find(@instance.id, :select => "id")

          assert_raises IndexTanked::ActiveRecordDefaults::InstanceCompanion::MissingAttributeError do
            person.name
          end

          person.index_tanked.data

          assert_equal "Alphonse", person.name
        end
      end
    end
  end
end
