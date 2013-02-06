require 'test_helper'

module IndexTanked
  module ActiveRecordDefaults

    class InstanceCompanionTest < Test::Unit::TestCase
      context "An instance of a class with index-tanked included" do
        setup do
          class ::Person
            include IndexTanked unless ancestors.include? IndexTanked::InstanceMethods

            index_tank :index => 'index-test', :url => "http://example.com" do
              field :name
              text  "some text, why not"
              var 0, 42
            end
          end

          IndexTanked::Configuration.index_availability = false
          IndexTanked::Configuration.add_to_index_fallback = lambda { |instance| return}

          @instance = Person.create! :name => 'Alphonse'
        end

        teardown do
          IndexTanked::Configuration.add_to_index_fallback = nil
          IndexTanked::Configuration.index_availability = nil
        end

        context "has a companion object for index tanked, the companion" do
          setup do
            @companion = @instance.index_tanked
          end

          should "serialize its data for adding to index tank" do
            assert_equal [{:text => "some text, why not Alphonse",
                           :name => "Alphonse",
                           :model => "Person",
                           :timestamp => @instance.created_at.to_i},
                          {:variables => { 0 => 42}}], @companion.data
          end

          should "serialize its data into a document hash for adding in batches" do
            document = {
              :docid => "Person:#{@instance.id}",
              :fields => {
                :text => "some text, why not Alphonse",
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

          context "An activerecord class inheriting from another activerecord class with single table inheritence" do
            setup do
              Programmer.reset!
              class ::Programmer
                include IndexTanked

                index_tank :index => 'index-test', :url => "http://example.com" do
                  field :name
                  text  "some text, why not"
                  var 0, 42
                end
              end

              IndexTanked::Configuration.index_availability = false
              IndexTanked::Configuration.add_to_index_fallback = lambda { |instance| return}

              @programmer = Programmer.create! :name => 'Ted'
            end

            teardown do
              IndexTanked::Configuration.add_to_index_fallback = nil
              IndexTanked::Configuration.index_availability = nil
            end

            should "call the after destroy callback with the right docids when an instance is destroyed" do
              Programmer.expects(:delete_doc_ids_from_index_tank).with(["Programmer:#{@programmer.id}","Person:#{@programmer.id}"])
              @programmer.destroy
            end

            should "serialize its data into a document hash for adding in batches, including its ancestors" do
              document = [{
                :docid => "Programmer:#{@programmer.id}",
                :fields => {
                  :text => "some text, why not Ted",
                  :name => "Ted",
                  :model => "Programmer",
                  :timestamp => @programmer.created_at.to_i
                },
                :variables => {
                  0 => 42
                }
              },
              {:docid => "Person:#{@programmer.id}",
               :fields => {
                 :text => "some text, why not Ted",
                 :name => "Ted",
                 :model => "Person",
                 :timestamp => @instance.created_at.to_i
               },
               :variables => {
                 0 => 42
               }
              }]
              assert_same_elements document, @programmer.index_tanked.document_for_batch_addition
            end
          end



          should "generate a doc_id for the instance" do
            assert_equal "Person:#{@instance.id}", @companion.doc_id
          end

          should "access its classes' index" do
            assert @companion.index.is_a? IndexTanked::IndexTank::Index
          end

          should "return an IndexTanked::IndexTank::Client" do
            assert @companion.api_client.is_a? IndexTanked::IndexTank::Client
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
