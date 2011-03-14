require 'test_helper'

module IndexTanked

  class ConfigurationTest < Test::Unit::TestCase

    context "IndexTank Configuration" do

      should "have the correct accessors." do
        readers = [:url, :index, :search_availability, :index_availability, :add_to_index_fallback, :delete_from_index_fallback, :timeout]
        writers = readers.map { |reader| :"#{reader}=" }
        assert (readers + writers).all? { |accessor| Configuration.respond_to? accessor }
      end

      context "search availability" do
        context "where search_availability is a Proc" do
          setup do
            Configuration.search_availability = proc { true if 1 > 0 }
          end

          should "execute the proc for the search_available? method." do
            assert Configuration.search_availability.is_a? Proc
            assert_equal true, Configuration.search_available?
          end
        end

        context "where search_availabilty is not a proc" do
          setup do
            Configuration.search_availability = false
          end

          should "return the value of search_availability for the search_available? method." do
            assert_equal Configuration.search_available?, Configuration.search_availability
            assert_equal false, Configuration.search_available?
          end
        end

        context "index availability" do
          context "where index_availability is a Proc" do
            setup do
              Configuration.index_availability = proc { true if 1 > 0 }
            end

            should "execute the proc for the index_available? method." do
              assert Configuration.index_availability.is_a? Proc
              assert_equal true, Configuration.index_available?
            end
          end

          context "where index_availabilty is not a proc" do
            setup do
              Configuration.index_availability = false
            end

            should "return the value of index_availability for the search_available? method." do
              assert_equal Configuration.index_available?, Configuration.index_availability
              assert_equal false, Configuration.index_available?
            end
          end
        end

      end
    end
  end

end