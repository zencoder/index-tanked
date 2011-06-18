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

        context "#enqueue" do
          should "add a document to the table" do
            assert_equal Document.count, 0
            @hash = {:docid => 'Person:1', :fields => {:one => '1'}}
            @document = Document.enqueue(1, 'Person', @hash)
            assert_equal Document.count, 1
            assert_equal 1, @document.record_id
            assert_equal 'Person', @document.model_name
            assert_equal @hash, @document.document
          end

          context "when a document with the id to be added already exits" do
            setup do
              @document = Document.create({:record_id => 1, :model_name => 'Person', :document => {:docid => 'Person:1', :fields => {:one => '1'}}})
            end

            should "have one document" do
              assert_equal 1, Document.count
            end

            context "that is not locked" do
              should "replace that document" do
                assert_equal Document.count, 1
                @hash = {:docid => 'Person:1', :fields => {:one => '2'}}
                @new_document = Document.enqueue(1, 'Person', @hash)
                assert_equal Document.count, 1
                assert_equal Document.first, @new_document
              end
            end

            context "that is locked" do
              setup do
                @document.locked_at = Time.now
                @document.locked_by = 'locked-for-enqueue-test'
                @document.save
              end

              should "not replace that document" do
                assert_equal Document.count, 1
                @hash = {:docid => 'Person:1', :fields => {:one => '2'}}
                @new_document = Document.enqueue(1, 'Person', @hash)
                assert_equal Document.count, 2
                assert_equal Document.first, @document
                assert_equal Document.last, @new_document
              end
            end

          end

        end

        context "#inspect" do
          context "A document with a hash serialized in it's document field" do
            setup do
              @hash = {:docid => 'Person:1', :fields => {:one => '2'}}
              @document = Document.enqueue(1, 'Person', @hash)
            end

            should "show the inspected hash when inspected, not the marshaled hash" do
              assert @document.inspect.include? @hash.inspect
              assert !@document.inspect.include?(@document.read_attribute(:document))
            end
          end
        end

        context "#newest_record_with_this_docid?" do
          context "A document with a unique model_name / record_id combination" do
            setup do
              @hash = {:docid => 'Person:1', :fields => {:one => '2'}}
              @document = Document.enqueue(1, 'Person', @hash)
            end

            should "be the newest record with that combination" do
              assert_equal true, @document.newest_record_with_this_docid?
            end
          end

          context "Two document with the same model_name / record_id combination" do
            setup do
              @hash1 = {:docid => 'Person:1', :fields => {:one => '2'}}
              @first_document = Document.enqueue(1, 'Person', @hash1)

              @hash2 = {:docid => 'Person:1', :fields => {:one => '5'}}
              @second_document = Document.enqueue(1, 'Person', @hash2)
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
              @locked_person_old = Document.enqueue(1, 'Person', {})
              @locked_person_old.update_attributes(:locked_by => 'testing', :locked_at => Time.now)
              @unlocked_person_new = Document.enqueue(1, 'Person', {})
            end
            context "one with an unlocked model_name / record_id twin that is older than itself" do
              setup do
                @unlocked_robot_old = Document.enqueue(6, 'Robot', {})
                @locked_robot_new = Document.create(:record_id => 6,
                                                    :model_name =>  'Robot',
                                                    :document => {},
                                                    :locked_by => 'testing',
                                                    :locked_at => Time.now)
              end
              context "and one that is unique" do
                setup do
                  @beautiful_snowflake = Document.enqueue(3, 'Snowflake', {})
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