require 'test_helper'

module IndexTanked
  module ActiveRecordDefaults

    class InstanceCompanionTest < Test::Unit::TestCase
      context "An instance of a class with index-tanked included" do
        setup do
          class ::Person
            include IndexTanked

            index_tank :index => 'index-test', :url => "http://example.com" do
              field  :name, :text => nil
              text   "some text, why not"
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

          should "generate a doc_id for the instance" do
            assert_equal "Person:#{@instance.id}", @companion.doc_id
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
end
