module IndexTanked
  module ActiveRecordDefaults
    module Queue

      class Document < ActiveRecord::Base
        set_table_name 'index_tanked_documents'

        def document
          Marshal.load(Base64.decode64(read_attribute(:document)))
        end

        def document=(doc)
          write_attribute(:document, Base64.encode64(Marshal.dump(doc)))
        end

        def inspect
          super.sub(/document: \"[^\"\r\n]*\"/, %{document: #{document.inspect}})
        end

        def self.enqueue(record_id, model_name, document_hash)
          destroy_all(:record_id => record_id, :model_name => model_name)
          create(:record_id => record_id, :model_name => model_name, :document => document_hash)
        end

        def self.get_or_update_index_information(model_name)
          @index_list ||= {}
          @companion_list ||= {}
          if @index_list[model_name]
            @index_list[model_name]
          else
            class_companion = model_name.constantize.index_tanked
            index = "#{class_companion.index_tank_url} - #{class_companion.index_name}"
            @index_list[model_name] = index
            @companion_list[index] ||= class_companion
          end
          @index_list[model_name]
        end

        def self.index_tanked(url_and_index_name)
          @companion_list[url_and_index_name]
        end

        def self.lock_records_for_batch(batch_size, identifier)
          update_all(["locked_by = ?, locked_at = clock_timestamp() at time zone 'UTC'", identifier],
                     ["locked_by IS NULL"], :limit => batch_size)
        end

        def self.partition_documents_by_index_and_url(documents)
          documents.inject({}) do |hash, doc|
            index = get_or_update_index_information(doc.model_name)
            hash[index] ||= []
            hash[index] << doc.document
            hash
          end
        end

        def self.send_batches_to_index_tank(partitioned_documents)
          partitioned_documents.keys.each do |url_and_index_name|
            index_tanked(url_and_index_name).index.batch_insert(partitioned_documents[url_and_index_name])
          end
        end

        def self.work_off(batch_size, identifier)
          number_locked = lock_records_for_batch(batch_size, identifier)
          if number_locked > 0
            documents = find_all_by_locked_by(identifier)
            begin
              partitioned_documents = partition_documents_by_index_and_url(documents)
              send_batches_to_index_tank(partitioned_documents)
              destroy_all(:locked_by => identifier)
            rescue StandardError => e
              puts "something (#{e.class} - #{e.message}) got jacked, unlocking"
              puts e.backtrace
              update_all(["locked_by = NULL, locked_at = NULL"],
                         ["locked_by = ?", identifier])
            end
          end

        end
      end

    end
  end
end

IndexTanked::Document = IndexTanked::ActiveRecordDefaults::Queue::Document
