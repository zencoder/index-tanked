require 'test_helper'

module IndexTanked
  module ActiveRecordDefaults
    class InstanceMethodsTest < Test::Unit::TestCase
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

        should "have an index_tanked companion object" do
          assert @instance.index_tanked.is_a? ActiveRecordDefaults::InstanceCompanion
        end

        should "have a method to add itself to index tank" do
          @instance.class.expects(:add_to_index_tank).with(@instance.index_tanked.doc_id, @instance.index_tanked.data, true).returns(nil)
          @instance.add_to_index_tank
        end
      end
    end
  end
end
