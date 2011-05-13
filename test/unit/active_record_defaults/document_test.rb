require 'test_helper'

module IndexTanked
  module ActiveRecordDefaults

    class DocumentTest < ActiveSupport::TestCase
      context "The Document table" do
        setup do
          Document.establish_connection :adapter => 'sqlite3', :database => ':memory:'
          Document.connection.create_table Document.table_name, :force => true do |t|
            t.string   :docid
            t.text     :document
            t.datetime :locked_at
            t.string   :locked_by

            t.timestamps
          end
        end

        context "#enqueue" do
          should "add a document to the table" do
            assert_equal Document.count, 0
            @hash = {:docid => '1', :fields => {:one => '1'}}
            @document = Document.enqueue(@hash)
            assert_equal Document.count, 1
            assert_equal '1', @document.docid
            assert_equal @hash, @document.document
          end

          context "when a document with the id to be added already exits" do
            setup do
              @document = Document.create({:docid => '1', :document => {:docid => '1', :fields => {:one => '1'}}})
            end

            should "have one document" do
              assert_equal 1, Document.count
            end

            should "replace that document" do
              assert_equal Document.count, 1
              @hash = {:docid => '1', :fields => {:one => '2'}}
              @new_document = Document.enqueue(@hash)
              assert_equal Document.count, 1
              assert_equal Document.first, @new_document
            end

          end

        end

      end


    end
  end
end