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
        
      end
    end
  end
end