require 'test_helper'

module IndexTanked

  class ClassCompanionTest < Test::Unit::TestCase
    context "Initializing a class companion" do
      setup do
        Configuration.url = "http://example.com"
        Configuration.index = "test_index"
      end

      should "raise an error if no url is provided" do
        assert_raises IndexTanked::IndexTankURLNotProvidedError do
          Configuration.url = nil
          companion = ClassCompanion.new
        end
      end

      should "raise an error if no index is provided" do
        assert_raises IndexTanked::IndexTankIndexNameNotProvidedError do
          Configuration.index = nil
          companion = ClassCompanion.new
        end
      end
    end

    context "A class companion object" do
      setup do
        @companion = ClassCompanion.new(:index => "text_index",
                                        :url   => "http://example.com")
      end

      should "have a doc_id method that defines how to derive a doc_id for an instance" do
        PretendInstance = Struct.new(:id)
        pretend_instance = PretendInstance.new(42)

        @companion.doc_id(proc { |instance| "BlogPost:#{instance.id}" })

        assert_equal "BlogPost:42", @companion.get_value_from(pretend_instance, @companion.doc_id_value)
      end

    end


  end

end