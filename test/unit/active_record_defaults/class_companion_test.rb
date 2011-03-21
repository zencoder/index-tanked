require 'test_helper'

module IndexTanked
  module ActiveRecordDefaults

    class ClassCompanionTest < Test::Unit::TestCase
      context "An activerecord class" do
        context "Initializing a class companion" do
          setup do
            Configuration.index_availability = true
          end

          teardown do
            Configuration.index_availability = nil
          end

          should "raise an error if no url is provided" do
            assert_raises IndexTanked::URLNotProvidedError do
              companion = ClassCompanion.new(Person, :index => "test-index")
            end
          end

          should "raise an error if no index is provided" do
            assert_raises IndexTanked::IndexNameNotProvidedError do
              companion = ClassCompanion.new(Person, :url => "http://example.com")
            end
          end
        end

        context "A class companion object" do
          setup do
            @companion = ClassCompanion.new(Person, :index => "text_index",
                                                    :url   => "http://example.com")
          end

          should "know which model it belongs to" do
            assert_equal Person, @companion.model
          end

          should "raise if doc_id method is called" do
            @person = Person.create! :name => 'Adam'
            assert_raises CustomDocIdNotSupportedError do
              @companion.doc_id
            end
          end

          should "have default to model:id format for the doc_id" do
            @person = Person.create! :name => 'Bill'
            assert_equal "Person:#{@person.id}", @companion.get_value_from(@person, @companion.doc_id_value)
          end

          context "the field method" do
            context "when provided with one argument" do
              setup do
                @companion.field :id
              end

              should "add an array to the field list" do
                assert_equal 1, @companion.fields.size
                assert @companion.fields.first.is_a? Array
              end

              context "the array" do
                setup do
                  @array = @companion.fields.first
                end

                should "have 3 elements" do
                  assert_equal 3, @array.size
                end

                should "consist the name of the field to be indexed, the method to call, and an empty options hash" do
                  assert_equal :id, @array[0]
                  assert_equal :id, @array[1]
                  assert_equal({}, @array[2])
                end
              end
            end

            context "when provided with two arguments" do
              context "where the second argument is not a hash" do
                setup do
                  @id_lambda = lambda { |instance| instance.index_id }
                  @companion.field :id, @id_lambda, :depends_on => :id
                end

                should "add an array to the field list" do
                  assert_equal 1, @companion.fields.size
                  assert @companion.fields.first.is_a? Array
                end

                context "the array" do
                  setup do
                    @array = @companion.fields.first
                  end

                  should "have 3 elements" do
                    assert_equal 3, @array.size
                  end

                  should "consist the name of the field to be indexed, the method to call, and an empty options hash" do
                    assert_equal :id, @array[0]
                    assert_equal @id_lambda, @array[1]
                    assert_equal({:depends_on => :id}, @array[2])
                  end
                end
              end

              context "where the second argument is a hash" do
                setup do
                  @companion.field :id, :text => nil
                end

                should "add an array to the field list" do
                  assert_equal 1, @companion.fields.size
                  assert @companion.fields.first.is_a? Array
                end

                context "the array" do
                  setup do
                    @array = @companion.fields.first
                  end

                  should "have 3 elements" do
                    assert_equal 3, @array.size
                  end

                  should "consist the name of the field to be indexed, the method to call, and the hash provided" do
                    assert_equal :id, @array[0]
                    assert_equal :id, @array[1]
                    assert_equal({:text => nil}, @array[2])
                  end
                end
              end
            end

            context "when provided with three arguments" do
              setup do
                @id_lambda = lambda { |instance| instance.index_id }
                @companion.field :id, @id_lambda, :text => nil, :depends_on => :id
              end

              should "add an array to the field list" do
                assert_equal 1, @companion.fields.size
                assert @companion.fields.first.is_a? Array
              end

              context "the array" do
                setup do
                  @array = @companion.fields.first
                end

                should "have 3 elements" do
                  assert_equal 3, @array.size
                end

                should "consist the name of the field to be indexed, the method to call, and the hash provided" do
                  assert_equal :id, @array[0]
                  assert_equal @id_lambda, @array[1]
                  assert_equal({:text => nil, :depends_on => :id}, @array[2])
                end
              end
            end

            context "when the field name doesn't match the column name" do
              setup do
                class ::Person
                  def slug
                    "Person:#{id}:#{name}"
                  end
                end
              end

              should "raise a MissingFieldDependencyError when the method doesn't match the column and a depends_on was not provided" do
                assert_raises IndexTanked::MissingFieldDependencyError do
                  @companion.field(:slug)
                end
              end

              should "not raise a MissingFieldDependencyError when the method doesn't match the column and a depends_on was provided" do
                assert_nothing_raised do
                  @companion.field(:slug, :depends_on => [:id, :name])
                end
              end
            end
          end

          context "the text method" do
            should "add it's argument to the @texts array" do
              @companion.text :herp
              assert_equal 1, @companion.texts.size
              assert_equal :herp, @companion.texts[0]

              @companion.text :derp
              assert_equal 2, @companion.texts.size
              assert_equal :derp, @companion.texts[1]
            end
          end

          context "the var method" do
            setup do
              @companion.var 0, :var_0_value
            end

            should "add an array to the variables list" do
              assert_equal 1, @companion.variables.size
              assert @companion.variables.first.is_a? Array
            end

            context "the array" do
              setup do
                @array = @companion.variables.first
              end

              should "have 2 elements" do
                assert_equal 2, @array.size
              end

              should "consist the variable number and the method to get its value" do
                assert_equal 0, @array[0]
                assert_equal :var_0_value, @array[1]
              end
            end
          end

          context "the index method" do
            setup do
              @index = @companion.index
            end

            should "return an IndexTank::Index" do
              assert @index.is_a? IndexTank::Index
            end
          end

          context "the api_client method" do
            setup do
              @client = @companion.api_client
            end

            should "return an IndexTank::Client" do
              assert @client.is_a? IndexTank::Client
            end
          end

          context "the get_value_from method" do
            setup do
              Struct.new("TestObject", :value) unless defined?(Struct::TestObject)
              @test_object = Struct::TestObject.new("this is a value!")
            end

            should "call the method if a symbol is provided" do
              assert_equal "this is a value!", @companion.get_value_from(@test_object, :value)
            end

            should "call the proc if a proc is provided" do
              assert_equal "this is a value!", @companion.get_value_from(@test_object, lambda { |test| test.value })
            end

            should "return the provided value if anything else is provided" do
              assert_equal "blerg", @companion.get_value_from(@test_object, "blerg")
            end
          end

          context "#add_fields_to_query" do
            should "add fields to the query, including model information" do
              assert_equal "name:adam email:adam@zencoder.com model:Person",
                           @companion.add_fields_to_query("name:adam", :fields => {:email => "adam@zencoder.com"})
            end
          end

          context "the dependent_fields_for_select method" do
            setup do
              class ::Person
                def slug
                  "Person:#{id}:#{name}"
                end
              end

              @companion.field(:name)
              @companion.field(:slug, :depends_on => [:id, :name])
            end

            context "when no additional fields are passed" do
              should "return all dependencies" do
                assert_same_elements %w{name id created_at}, @companion.dependent_fields_for_select
              end
            end

            context "when additional fields are passed" do
              should "return the dependencies plus whatever else is passed" do
                assert_same_elements %w{name id created_at your_mom}, @companion.dependent_fields_for_select("your_mom")
              end
            end
          end

          context "the dependent_fields_as_strings method" do
            setup do
              class ::Person
                def slug
                  "Person:#{id}:#{name}"
                end
              end

              @companion.field(:name)
              @companion.field(:slug, :depends_on => [:id, :name])
            end

            should "return the dependencies as strings" do
              assert_same_elements %w{name id created_at}, @companion.dependent_fields_as_strings
            end
          end

          context "the dependent_fields method" do
            setup do
              class ::Person
                def slug
                  "Person:#{id}:#{name}"
                end
              end

              @companion.field(:name)
              @companion.field(:slug, :depends_on => [:id, :name])
            end

            should "return the dependent fields as symbols" do
              assert_same_elements [:name, :id, :created_at], @companion.dependent_fields
            end
          end

        end

      end
    end
  end
end
