require 'test_helper'

module IndexTanked
  class ClassMethodsTest < Test::Unit::TestCase
    context "A class with index-tanked included" do
      setup do

        IndexTanked::Configuration.index_availability = true

        class TestObject
          include IndexTanked

          attr_accessor :field1, :field2, :field3, :field4, :field5

          def initialize(*args)
            @field1, @field2, @field3, @field4, @field5 = args
          end

          index_tank :index => 'test_index', :url => "http://example.com" do
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

      teardown do
        TestObject.index_tanked.fields.clear
        TestObject.index_tanked.variables.clear
        TestObject.index_tanked.texts.clear
      end

      should "have access to its companion object" do
        assert TestObject.index_tanked.is_a? IndexTanked::ClassCompanion
      end

      should "get a search result when it searches index tank" do
        assert TestObject.search_index_tank('delicious apples').is_a? IndexTanked::SearchResult
      end

      context "adding documents to index tank" do
        context "when indexing is disabled" do
          setup do
            IndexTanked::Configuration.index_availability = false
          end

          teardown do
            IndexTanked::Configuration.index_availability = true
          end

          should "raise an exception" do
            assert_raises IndexTanked::IndexingDisabledError do
              TestObject.add_to_index_tank('/docid/1', [{:apples => :delicious}])
            end
          end
        end

        context "when a timeout is set" do
          setup do
            IndexTanked::Configuration.timeout = 0.2
          end

          teardown do
            IndexTanked::Configuration.timeout = nil
          end

          context "and the request takes too long" do
            setup do
              $testing_index_tanked_timeout = true
            end

            teardown do
              $testing_index_tanked_timeout = nil
            end

            should "raise an exception" do
              assert_raises TimeoutExceededError do
                TestObject.add_to_index_tank('/docid/1', [{:apples => :delicious}])
              end
            end

            should "not raise an exception if fallback is false" do
              IndexTank::Document.any_instance.expects(:add).returns(200)
              Timer.expects(:timeout).never
              assert_nothing_raised do
                TestObject.add_to_index_tank('/docid/1', [{:apples => :delicious}], false)
              end
            end
          end
        end

        context "when an exception is raised" do
          setup do
            IndexTank::Document.any_instance.expects(:add).raises(StandardError)
          end

          context "and the call was made to #add_to_index_tank with the third argument true or absent" do
            context "and a fallback method is configured it" do
              setup do
                IndexTanked::Configuration.add_to_index_fallback do |data|
                  "class: #{data[:class].to_s.split('::').last}, doc_id: #{data[:doc_id]}, data: {#{data[:data][0].to_a.join(' => ')}}, error: #{data[:error].class}"
                end
              end

              teardown do
                IndexTanked::Configuration.add_to_index_fallback = nil
              end

              should "call the fallback method" do
                assert_equal "class: TestObject, doc_id: /docid/1, data: {apples => delicious}, error: StandardError",
                             TestObject.add_to_index_tank('/docid/1', [{:apples => :delicious}])
              end
            end

            context "and a fallback method is not configured it" do
              should "raise the exception" do
                assert_raises StandardError do
                  TestObject.add_to_index_tank('/docid/1', [{:apples => :delicious}])
                end
              end
            end
          end

          context "and the call was made to #add_to_index_tank_without_fallback" do
            context "and a fallback method is configured it" do
              setup do
                IndexTanked::Configuration.add_to_index_fallback = proc { |data| "class: #{data[:class].to_s.split('::').last}, doc_id: #{data[:doc_id]}, data: {#{data[:data][0].to_a.join(' => ')}}, error: #{data[:error].class}" }
              end

              teardown do
                IndexTanked::Configuration.add_to_index_fallback = nil
              end

              should "raise_the_exception" do
                assert_raises StandardError do
                  TestObject.add_to_index_tank_without_fallback('/docid/1', [{:apples => :delicious}])
                end
              end
            end

            context "and a fallback method is not configured it" do
              should "raise the exception" do
                assert_raises StandardError do
                  TestObject.add_to_index_tank_without_fallback('/docid/1', [{:apples => :delicious}])
                end
              end
            end
          end

        end

      end

      context "deleting documents from index tank" do
        context "when indexing is disabled" do
          setup do
            IndexTanked::Configuration.index_availability = false
          end

          teardown do
            IndexTanked::Configuration.index_availability = true
          end

          should "raise an exception" do
            assert_raises IndexTanked::IndexingDisabledError do
              TestObject.delete_from_index_tank('/docid/1')
            end
          end
        end

        context "when a timeout is set" do
          setup do
            IndexTanked::Configuration.timeout = 0.2
          end

          teardown do
            IndexTanked::Configuration.timeout = nil
          end

          context "and the request takes too long" do
            setup do
              $testing_index_tanked_timeout = true
            end

            teardown do
              $testing_index_tanked_timeout = nil
            end

            should "raise an exception" do
              assert_raises TimeoutExceededError do
                TestObject.delete_from_index_tank('/docid/1')
              end
            end
          end
        end

        context "when an exception is raised" do
          setup do
            IndexTank::Document.any_instance.expects(:delete).raises(StandardError)
          end

          context "and the call was made to #delete_from_index_tank with the third argument true or absent" do
            context "and a fallback method is configured it" do
              setup do
                IndexTanked::Configuration.delete_from_index_fallback = proc { |data| "class: #{data[:class].to_s.split('::').last}, doc_id: #{data[:doc_id]}, error: #{data[:error].class}" }
              end

              teardown do
                IndexTanked::Configuration.delete_from_index_fallback = nil
              end

              should "call the fallback method" do
                assert_equal "class: TestObject, doc_id: /docid/1, error: StandardError",
                             TestObject.delete_from_index_tank('/docid/1')
              end
            end

            context "and a fallback method is not configured it" do
              should "raise the exception" do
                assert_raises StandardError do
                  TestObject.delete_from_index_tank('/docid/1')
                end
              end
            end
          end

          context "and the call was made to #delete_from_index_tank_without_fallback" do
            context "and a fallback method is configured it" do
              setup do
                IndexTanked::Configuration.delete_from_index_fallback = proc { |data| "class: #{data[:class].to_s.split('::').last}, doc_id: #{data[:doc_id]}, error: #{data[:error].class}" }
              end

              teardown do
                IndexTanked::Configuration.delete_from_index_fallback = nil
              end

              should "raise_the_exception" do
                assert_raises StandardError do
                  TestObject.delete_from_index_tank_without_fallback('/docid/1')
                end
              end
            end

            context "and a fallback method is not configured it" do
              should "raise the exception" do
                assert_raises StandardError do
                  TestObject.delete_from_index_tank_without_fallback('/docid/1')
                end
              end
            end
          end
        end
      end
    end
  end
end