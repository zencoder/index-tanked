require 'test_helper'

module IndexTanked
  module ActiveRecordDefaults
    class SearchResultTest < Test::Unit::TestCase
      context "A search result" do
        setup do
          IndexTanked::Configuration.add_to_index_fallback = lambda { |instance| nil }
          Person.reset!
          (1..5).each { |n| Person.create! :name => "blah#{n}" }
          IndexTanked::Configuration.search_availability = true
          @search_result = SearchResult.new('bacon', IndexTank::Index.new('list_o_bacon'), Person, :page => 1, :per_page => 5)
        end

        teardown do
          IndexTanked::Configuration.add_to_index_fallback = nil
        end

        should "know which model it belongs to" do
          assert_equal Person, @search_result.model
        end

        context "without an index" do
          setup do
            @search_result = SearchResult.new('bacon', nil, Person, :page => 1, :per_page => 5)
          end

          context "when executed by calling any of its methods" do
            should "raise an exception" do
              assert_raises SearchError do
                @search_result.raw_result
              end
            end

            should "call paginate on the original model / scope if paginate is called on the search result" do
              Person.expects(:paginate).with({:per_page => 10, :page => 1})
              @search_result.paginate(:per_page => 10, :page => 1)
            end
          end
        end

        context "when executed by calling any of its methods" do
          context "while search is disabled" do
            setup do
              IndexTanked::Configuration.search_availability = false
            end

            teardown do
              IndexTanked::Configuration.search_availability = true
            end

            should "raise an exception" do
              assert_raises SearchingDisabledError do
                @search_result.raw_result
              end
            end
          end
        end

        context "whose search has successfully executed" do
          setup do
            @search_result.instance_exec do
              @raw_result = {"results"=>[{"docid"=>"Person:1"}, {"docid"=>"Person:2"}, {"docid"=>"Person:3"}, {"docid"=>"Person:5"}, {"docid"=>"Person:6"}, {"docid"=>"Person:7"}], "search_time"=>"0.002", "facets"=>{}, "matches"=>7}
            end
          end

          should "know how long the search took" do
            assert_equal "0.002", @search_result.search_time
          end

          should "return the facets hash" do
            assert_equal({}, @search_result.facets)
          end

          should "know how many total results were found" do
            assert_equal 7, @search_result.matches
          end

          should "have a paginated collection of results" do
            assert_equal [{"docid"=>"Person:1"},
                          {"docid"=>"Person:2"},
                          {"docid"=>"Person:3"},
                          {"docid"=>"Person:5"},
                          {"docid"=>"Person:6"},
                          {"docid"=>"Person:7"}],
                         @search_result.results
            assert @search_result.results.is_a? WillPaginate::Collection
          end

          should "have a list of database ids" do
            assert_equal [1, 2, 3, 5, 6, 7], @search_result.ids
          end

          should "retrieve the records from the database" do
            assert_equal 4, @search_result.records.size
            assert @search_result.records.all? { |record| record.is_a? Person }
            assert_equal "blah1", @search_result.records.first.name
          end

          should "return database records even if there is a problem with the missing ids handler" do
            Configuration.missing_activerecord_ids_handler = lambda { |model, ids| raise StandardError }
            assert_equal 4, @search_result.records.size
            assert @search_result.records.all? { |record| record.is_a? Person }
            assert_equal "blah1", @search_result.records.first.name
            Configuration.missing_activerecord_ids_handler = nil
          end

          should "have a list of ids that were returned by the query, but that don't exist in the database once records has been called" do
            @search_result.records
            assert_same_elements [6, 7], @search_result.missing_ids
          end

          should "call the missing_ids_handler if it's been configured and there are missing_ids" do
            Configuration.missing_activerecord_ids_handler = lambda { |model, ids| true }
            Configuration.missing_activerecord_ids_handler.expects(:call).with(Person, [6,7])
            @search_result.records
            Configuration.missing_activerecord_ids_handler = nil
          end

          should "not call the missing_ids_handler if it hasn't been configured and there are missing_ids" do
            Configuration.missing_activerecord_ids_handler.expects(:call).never
            @search_result.records
          end

          should "retrieve paginated records from the database" do
            @records = @search_result.paginate(:per_page => 5, :page => 1)
            assert_equal 4, @records.size
            assert @records.all? { |record| record.is_a? Person }
            assert_equal "blah1", @records.first.name
            assert @records.is_a? WillPaginate::Collection
          end
        end
      end
    end
  end
end
