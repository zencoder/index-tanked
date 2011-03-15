require 'test_helper'

module IndexTanked

  class SearchResultTest < Test::Unit::TestCase
    context "A search result" do
      setup do
        IndexTanked::Configuration.search_availability = true
        @search_result = SearchResult.new('bacon', IndexTank::Index.new('list_o_bacon'), :page => 1, :per_page => 5)
      end

      context "without an index" do
        setup do
          @search_result = SearchResult.new('bacon', nil, :page => 1, :per_page => 5)
        end

        context "when executed by calling any of its methods" do
          should "raise an exception" do
            assert_raises SearchError do
              @search_result.raw_result
            end
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
            @raw_result = {"results"=>[{"docid"=>"/blogposts/1"}, {"docid"=>"/blogposts/2"}, {"docid"=>"/blogposts/3"}, {"docid"=>"/blogposts/4"}, {"docid"=>"/blogposts/5"}], "search_time"=>"0.002", "facets"=>{}, "matches"=>25}
          end
        end

        should "know how long the search took" do
          assert_equal "0.002", @search_result.search_time
        end

        should "return the facets hash" do
          assert_equal({}, @search_result.facets)
        end

        should "know how many total results were found" do
          assert_equal 25, @search_result.matches
        end

        should "have a paginated collection of results" do
          assert_equal [{"docid"=>"/blogposts/1"},
                        {"docid"=>"/blogposts/2"},
                        {"docid"=>"/blogposts/3"},
                        {"docid"=>"/blogposts/4"},
                        {"docid"=>"/blogposts/5"}],
                       @search_result.results
          assert @search_result.results.is_a? WillPaginate::Collection
        end
      end
    end
  end
end
