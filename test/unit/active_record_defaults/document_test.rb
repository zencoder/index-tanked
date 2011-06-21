require 'test_helper'

module IndexTanked
  module ActiveRecordDefaults

    class DocumentTest < ActiveSupport::TestCase
      context "The Document table" do
        setup do
          Document.establish_connection :adapter => 'sqlite3', :database => ':memory:'
          Document.connection.create_table Document.table_name, :force => true do |t|
            t.integer  :record_id
            t.string   :model_name
            t.text     :document
            t.datetime :locked_at
            t.string   :locked_by

            t.timestamps
          end
        end

        context "#inspect" do
          context "A document with a hash serialized in it's document field" do
            setup do
              @hash = {:docid => 'Person:1', :fields => {:one => '2'}}
              @document = Document.create(:record_id => 1, :model_name => 'Person', :document => @hash)
            end

            should "show the inspected hash when inspected, not the marshaled hash" do
              assert @document.inspect.include? @hash.inspect
              assert !@document.inspect.include?(@document.read_attribute(:document))
            end
          end
        end

        context "duplicate document removal" do
          context "An array of documents for batch insertion" do
            setup do
              @documents = [{:fields=>{:timestamp=>1}, :docid=>"User:1"},
                            {:fields=>{:timestamp=>2}, :docid=>"User:2"},
                            {:fields=>{:timestamp=>3}, :docid=>"User:3"},
                            {:fields=>{:timestamp=>4}, :docid=>"User:4"},
                            {:fields=>{:timestamp=>5}, :docid=>"User:5"},
                            {:fields=>{:timestamp=>6}, :docid=>"User:4"},
                            {:fields=>{:timestamp=>7}, :docid=>"User:6"}]
            end

            should "return the index of a duplicate document" do
              assert_equal 1, Document.index_of_duplicate_document(@documents, {
                :fields=>{:timestamp=>8}, :docid=>"User:2"
              })
            end

            should "return nil if there is no duplicate document" do
              assert_equal nil, Document.index_of_duplicate_document(@documents, {
                :fields=>{:timestamp=>9}, :docid=>"User:7"
              })
            end

            should "remove duplicate's, keeping the newest" do
              assert_same_elements [{:fields=>{:timestamp=>1}, :docid=>"User:1"},
                                    {:fields=>{:timestamp=>2}, :docid=>"User:2"},
                                    {:fields=>{:timestamp=>3}, :docid=>"User:3"},
                                    {:fields=>{:timestamp=>5}, :docid=>"User:5"},
                                    {:fields=>{:timestamp=>6}, :docid=>"User:4"},
                                    {:fields=>{:timestamp=>7}, :docid=>"User:6"}],
                                    Document.remove_duplicate_documents(@documents)
            end

          end
        end


        context "#newest_record_with_this_docid?" do
          context "A document with a unique model_name / record_id combination" do
            setup do
              @hash = {:docid => 'Person:1', :fields => {:one => '2'}}
              @document = Document.create(:record_id => 1, :model_name => 'Person', :document => @hash)
            end

            should "be the newest record with that combination" do
              assert_equal true, @document.newest_record_with_this_docid?
            end
          end

          context "Two document with the same model_name / record_id combination" do
            setup do
              @hash1 = {:docid => 'Person:1', :fields => {:one => '2'}}
              @first_document = Document.create(:record_id => 1, :model_name => 'Person', :document => @hash1)

              @hash2 = {:docid => 'Person:1', :fields => {:one => '5'}}
              @second_document = Document.create(:record_id => 1, :model_name => 'Person', :document => @hash2)
            end

            context "the first document created" do
              should "not be the newest document with it's model / record_id combination" do
                assert_equal false, @first_document.newest_record_with_this_docid?
              end
            end

            context "the second document created" do
              should "be the newest record with that combination" do
                assert_equal true, @second_document.newest_record_with_this_docid?
              end
            end
          end
        end

        context "Three locked records" do
          context "one with an unlocked model_name / record_id twin that is newer than itself" do
            setup do
              @locked_person_old = Document.create(:record_id => 1, :model_name => 'Person', :document => {})
              @locked_person_old.update_attributes(:locked_by => 'testing', :locked_at => Time.now)
              @unlocked_person_new = Document.create(:record_id => 1, :model_name => 'Person', :document => {})
            end
            context "one with an unlocked model_name / record_id twin that is older than itself" do
              setup do
                @unlocked_robot_old = Document.create(:record_id => 6, :model_name => 'Robot', :document => {})
                @locked_robot_new = Document.create(:record_id => 6,
                                                    :model_name =>  'Robot',
                                                    :document => {},
                                                    :locked_by => 'testing',
                                                    :locked_at => Time.now)
              end
              context "and one that is unique" do
                setup do
                  @beautiful_snowflake = Document.create(:record_id => 3, :model_name => 'Snowflake', :document => {})
                  @beautiful_snowflake.update_attributes(:locked_by => 'testing', :locked_at => Time.now)
                end

                should "be able to find the non unique combinations records locked for testing" do
                  assert_same_elements [["Person", 1], ["Robot", 6]], Document.non_unique_docids_by_identifier('testing')
                end

                should "be able to delete the locked record that is outdated" do
                  person_old_id = @locked_person_old.id
                  assert_equal 1, Document.delete_outdated_locked_records_by_identifier('testing')
                  exception = assert_raises ActiveRecord::RecordNotFound do
                    @locked_person_old.reload
                  end
                  assert_equal "Couldn't find IndexTanked::ActiveRecordDefaults::Queue::Document with ID=#{person_old_id}", exception.message
                end

              end
            end
          end
        end
      end
    end
  end
end