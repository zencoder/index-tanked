require 'test_helper'

class IndexTankedTest < Test::Unit::TestCase
  context "In an object with index-tanked included" do
    setup do

      IndexTanked::Configuration.url = "http://example.com"

      class TestObject
        include IndexTanked

        attr_accessor :field1, :field2, :field3, :field4, :field5

        def initialize(*args)
          @field1, @field2, @field3, @field4, @field5 = args
        end

        index_tanked 'index_tanked_test' do
          doc_id lambda { |test_object| "test-#{test_object.field1}" }
          field  :field1
          field  :field2, :text => nil
          field  :third_field, :field3, :text => lambda { |test_object| "third_field_#{test_object.field3}" }
          field  :field4, :text => "some-string"
          field  :field5, lambda { |test_object| "field-five_#{test_object.field5}"}
          text   "some-arbitrary-text"
          text   "some-more-just-cause"
          var 0, :field1
          var 1, lambda { |test_object| test_object.field2 }
        end
      end

    end

    context "the class" do
      should "have the appropriate class methods" do
        class_methods = [:index_tanked_fields, :index_tanked_text, :index_tanked_index_name, :index_tanked_doc_id, :index_tanked]
        assert class_methods.all? { |method| TestObject.respond_to? method }
      end

      should "be indexing 5 fields" do
        assert_equal 5, TestObject.index_tanked_fields.size
      end

      should "adding one item to the text field" do
        assert_equal 2, TestObject.index_tanked_text.size
      end

      should "have a method by which to estabish the document id of an instance" do
        assert TestObject.index_tanked_doc_id.is_a? Proc
      end

      should "know which index it should use" do
        assert_equal 'index_tanked_test', TestObject.index_tanked_index_name
      end
    end

    context "an instance of the class" do
      setup do
        @test_object = TestObject.new('one', 'two', 'three', 'four', 'five')
      end

      should "know it's document id" do
        assert_equal 'test-one', @test_object.index_tank_doc_id
      end

      should "have the correct data for index tank" do
        field_data, other_data = *@test_object.index_tank_data
        assert_equal 'one', field_data[:field1]
        assert_equal 'two', field_data[:field2]
        assert_equal 'three', field_data[:third_field]
        assert_equal 'four', field_data[:field4]
        assert_equal 'field-five_five', field_data[:field5]
        assert_equal 'some-arbitrary-text some-more-just-cause one third_field_three some-string field-five_five', field_data[:text]
        assert_equal 'one', other_data[:variables][0]
        assert_equal 'two', other_data[:variables][1]
      end
    end

  end
end
