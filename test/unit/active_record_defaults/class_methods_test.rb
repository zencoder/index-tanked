require 'test_helper'

module IndexTanked
  module ActiveRecordDefaults
    class ClassMethodsTest < Test::Unit::TestCase
      context "An activerecord class with index-tanked included" do
        setup do

          IndexTanked::Configuration.index_availability = true

          class ::Person
            include IndexTanked

            index_tank :index => 'test-index', :url => 'http://example.com' do
              field :name
            end
          end
        end

        teardown do
          Person.index_tanked.fields.clear
          Person.index_tanked.variables.clear
          Person.index_tanked.texts.clear
        end

        should "have access to its companion object" do
          assert Person.index_tanked.is_a? ClassCompanion
        end

        should "get a search result when it searches index tank" do
          assert Person.search_index_tank('delicious apples').is_a? SearchResult
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
                Person.add_to_index_tank('/docid/1', [{:apples => :delicious}])
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
                  Person.add_to_index_tank('/docid/1', [{:apples => :delicious}])
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
                  IndexTanked::Configuration.add_to_index_fallback = proc { |data| "class: #{data[:class].to_s.split('::').last}, doc_id: #{data[:doc_id]}, data: {#{data[:data][0].to_a.join(' => ')}}, error: #{data[:error].class}" }
                end

                teardown do
                  IndexTanked::Configuration.add_to_index_fallback = nil
                end

                should "call the fallback method" do
                  assert_equal "class: Person, doc_id: /docid/1, data: {apples => delicious}, error: StandardError",
                               Person.add_to_index_tank('/docid/1', [{:apples => :delicious}])
                end
              end

              context "and a fallback method is not configured it" do
                should "raise the exception" do
                  assert_raises StandardError do
                    Person.add_to_index_tank('/docid/1', [{:apples => :delicious}])
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
                    Person.add_to_index_tank_without_fallback('/docid/1', [{:apples => :delicious}])
                  end
                end
              end

              context "and a fallback method is not configured it" do
                should "raise the exception" do
                  assert_raises StandardError do
                    Person.add_to_index_tank_without_fallback('/docid/1', [{:apples => :delicious}])
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
                Person.delete_from_index_tank('/docid/1')
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
                  Person.delete_from_index_tank('/docid/1')
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
                  assert_equal "class: Person, doc_id: /docid/1, error: StandardError",
                               Person.delete_from_index_tank('/docid/1')
                end
              end

              context "and a fallback method is not configured it" do
                should "raise the exception" do
                  assert_raises StandardError do
                    Person.delete_from_index_tank('/docid/1')
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
                    Person.delete_from_index_tank_without_fallback('/docid/1')
                  end
                end
              end

              context "and a fallback method is not configured it" do
                should "raise the exception" do
                  assert_raises StandardError do
                    Person.delete_from_index_tank_without_fallback('/docid/1')
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end