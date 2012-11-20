module IndexTanked
  module ActiveRecordDefaults
    module Queue

      class Document < ActiveRecord::Base
        self.table_name = 'index_tanked_documents'

        def document
          Marshal.load(Base64.decode64(read_attribute(:document)))
        end

        def document=(doc)
          write_attribute(:document, Base64.encode64(Marshal.dump(doc)))
        end

        def inspect
          return super if read_attribute(:document).nil?
          super.sub(/document: \"[^\"\r\n]*\"/, %{document: #{document.inspect}})
        end

        def newest_record_with_this_docid?
          self.class.find_by_model_name_and_record_id(self.model_name, self.record_id, :order => 'created_at DESC', :limit => 1) == self
        end

        def self.clear_locks_by_identifier(identifier)
          locks_cleared = update_all(["locked_by = NULL, locked_at = NULL"],
                                     ["locked_by = ?", identifier])
          locks_cleared
        end

        def self.clear_expired_locks
          locks_cleared = update_all(["locked_at = NULL, locked_by = NULL"],
                                     ["age(clock_timestamp() at time zone 'UTC', locked_at) > interval '5 minutes'"])
          locks_cleared
        end

        def self.delete_outdated_locked_records_by_identifier(identifier)
          ids_to_delete = non_unique_docids_by_identifier(identifier).inject([]) do |ids, (model_name, record_id)|
            record = find_by_model_name_and_record_id_and_locked_by(model_name, record_id, identifier)
            ids << record.id unless record.newest_record_with_this_docid?
            ids
          end

          if ids_to_delete.any?
            delete_all(['id in (?)', ids_to_delete])
          else
            0
          end
        end

        def self.non_unique_docids_by_identifier(identifier)
          find_by_sql(['SELECT model_name, record_id FROM index_tanked_documents GROUP BY model_name, record_id HAVING count(*) > 1 INTERSECT SELECT model_name, record_id FROM index_tanked_documents WHERE locked_by = ?', identifier]).map do |partial_record|
            [partial_record.model_name, partial_record.record_id]
          end
        end

        def self.get_or_update_index_information(model_name)
          @model_list ||= {}
          @index_list ||= {}
          if @model_list[model_name]
            @model_list[model_name]
          else
            class_companion = model_name.constantize.index_tanked
            url = class_companion.index_tank_url
            index_name = class_companion.index_name
            companion_key = update_model_list(:model_name => model_name,
                                              :url => url,
                                              :index_name => index_name)
            update_index_list(companion_key, class_companion)

          end
          @model_list[model_name]
        end

        def self.index_tanked(companion_key)
          @index_list[companion_key]
        end

        def self.lock_records_for_batch(batch_size, identifier)
          update_all(["locked_by = ?, locked_at = clock_timestamp() at time zone 'UTC'", identifier],
                     ["locked_by IS NULL"], :limit => batch_size)
        end

        def self.partition_documents_by_companion_key(documents)
          documents.inject({}) do |partitioned_documents, document_record|
            companion_key = get_or_update_index_information(document_record.model_name)[:companion_key]
            partitioned_documents[companion_key] ||= []
            #document may be a hash or an array of hashes due for single table inheritence ancestors
            [document_record.document].flatten.each do |document_to_index|
              partitioned_documents[companion_key] << document_to_index
            end
            partitioned_documents
          end
        end

        def self.remove_duplicate_documents(documents)
          documents.inject([]) do |documents, document_record|
            duplicate_index = index_of_duplicate_document(documents, document_record)
            if duplicate_index
              if documents[duplicate_index].created_at < document_record.created_at
                documents[duplicate_index] = document_record
              end
            else
              documents << document_record
            end
            documents
          end
        end

        def self.index_of_duplicate_document(document_array, document_to_index)
          document_array.index do |doc|
            (doc.record_id == document_to_index.record_id) && (doc.model_name == document_to_index.model_name)
          end
        end

        def self.update_index_list(companion_key, class_companion)
          @index_list[companion_key] = class_companion unless @index_list[companion_key].present?
        end

        def self.update_model_list(options)
          @model_list[options[:model_name]] = { :index_tank_url => options[:url],
                                                :index_name => options[:index_name],
                                                :companion_key => "#{options[:url]} - #{options[:index_name]}" }
          @model_list[options[:model_name]][:companion_key]
        end

      end

    end
  end
end

IndexTanked::Document = IndexTanked::ActiveRecordDefaults::Queue::Document
