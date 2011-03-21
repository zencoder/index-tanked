require 'test_helper'

module IndexTanked
  module ActiveRecordDefaults
    class IndexTankedTest < Test::Unit::TestCase
      context "An instance of a activerecord class with index-tanked included" do
        setup do
          Configuration.index_availability = true
          class ::Person
            include IndexTanked

            index_tank :index => 'test-index', :url => 'http://example.com' do
              field :name
            end
          end
          stub_request(:put, 'example.com/v1/indexes/test-index/docs/')
          @person = Person.create!(:name => 'Pedro')
        end

        teardown do
          Configuration.index_availability = nil
        end

        context "when an instance is saved" do
          should "not add document to indextank if no attributes have changed" do
            person = Person.find(@person.id)
            person.expects(:add_to_index_tank).never
            person.save
          end

          should "add document to indextank if attributes have changed" do
            person = Person.find(@person.id)
            person.name = "Jorge"
            person.expects(:add_to_index_tank)
            person.save
          end
        end
      end
    end
  end
end
