class CreateIndexTankedDocuments < ActiveRecord::Migration
  def self.up
    create_table :index_tanked_documents, :force => true do |t|
      t.integer  :record_id                    # id of the record being indexed
      t.string   :model_name                   # Activerecord Model name
      t.text     :document                     # document from #document_for_batch_addition
      t.datetime :locked_at                    # Set when a client is working on this object
      t.string   :locked_by                    # Who is working on this object (if locked)
      t.timestamps
    end

    add_index :index_tanked_documents, :locked_at
  end

  def self.down
    remove_index :index_tanked_documents, :locked_at
    drop_table :index_tanked_documents
  end
end
