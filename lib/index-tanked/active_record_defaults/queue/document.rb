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
                                    :index_name => name)
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
            partitioned_documents[companion_key] << document_record.document
            partitioned_documents
          end
        end

        def self.send_batches_to_index_tank(partitioned_documents)
          partitioned_documents.keys.each do |companion_key|
            index_tanked(companion_key).index.batch_insert(partitioned_documents[companion_key])
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

        def self.work_off(batch_size, identifier)
          number_locked = lock_records_for_batch(batch_size, identifier)
          return if number_locked == 0
          begin
            documents = find_all_by_locked_by(identifier)
            partitioned_documents = partition_documents_by_companion_key(documents)
            send_batches_to_index_tank(partitioned_documents)
            delete_all(:locked_by => identifier)
          rescue StandardError, Timeout::Error => e
            handle_error(e)
          ensure
            update_all(["locked_by = NULL, locked_at = NULL"],
                       ["locked_by = ?", identifier])
          end
        end

        def self.handle_error(e)
          puts "something (#{e.class} - #{e.message}) got jacked, unlocking"
          puts e.backtrace
        end

      end

    end
  end
end

IndexTanked::Document = IndexTanked::ActiveRecordDefaults::Queue::Document
