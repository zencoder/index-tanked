require 'test_helper'

module IndexTanked

  class InstanceMethodsTest < Test::Unit::TestCase
    context "An instance of a class with index-tanked included" do
      setup do
        class AnimalsRawr
          include IndexTanked

          attr_accessor :fish, :dog

          def initialize(opts={})
            @fish = opts[:fish]
            @dog = opts[:dog]
          end

          index_tank :index => 'animals', :url => "http://example.com" do
            doc_id lambda { |instance| "animals/fish/#{instance.fish}/dog/#{instance.dog}" }
            field  :dog
            field  :fish, :text => nil
            text   "animals fish dogs"
            var 0, 42
          end
        end

        @instance = AnimalsRawr.new({:fish => 'trout', :dog => 'shiba inu'})
      end

      teardown do
        AnimalsRawr.index_tanked.fields.clear
        AnimalsRawr.index_tanked.texts.clear
        AnimalsRawr.index_tanked.variables.clear
      end

      should "have an index_tanked companion object" do
        assert @instance.index_tanked.is_a? IndexTanked::InstanceCompanion
      end

      should "have a method to add itself to index tank" do
        @instance.class.expects(:add_to_index_tank).with(@instance.index_tanked.doc_id, @instance.index_tanked.data).returns(nil)
        @instance.add_to_index_tank
      end

    end
  end
end
