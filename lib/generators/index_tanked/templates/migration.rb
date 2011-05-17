class CreateIndexTankedDocuments < ActiveRecord::Migration
  def self.up
    create_table :index_tanked_documents, :force => true do |t|
      t.string   :docid                        # IndexTank docid of the document
      t.string   :model                        # Model so we can query it for indextank url / index name
      t.text     :document                     # document from #document_for_batch_addition
      t.datetime :locked_at                    # Set when a client is working on this object
      t.string   :locked_by                    # Who is working on this object (if locked)

      t.timestamps
    end
  end

  def self.down
    drop_table :index_tanked_documents
  end
end
