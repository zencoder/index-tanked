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

        def self.index_tanked(options)
          @index_list ||= {}
          @companion_list ||= {}
          if options[:model_name]
            model_name = options[:model_name]
            if @index_list[model_name]
              @index_list[model_name]
            else
              class_companion = model_name.constantize.index_tanked
              index = "#{class_companion.index_tank_url} - #{class_companion.index_name}"
              @index_list[model_name] = index
              @companion_list[index] ||= class_companion
            end
            @index_list[model_name]
          elsif options[:index]
            @companion_list[options[:index]]
          end
        end

        def self.work_off(batch_size, identifier)
          puts "Locking"
          locked = update_all(["locked_by = ?, locked_at = clock_timestamp() at time zone 'UTC'", identifier],
                               ["locked_by IS NULL"], :limit => batch_size)
          puts "#{locked} locked."
          if locked > 0
            puts "Getting documents"
            documents = find_all_by_locked_by(identifier)
            begin
              puts "sending to indextank"
              indexes = documents.inject({}) do |hash, doc|
                index = index_tanked(:model_name => doc.model_name)
                hash[index] ||= []
                hash[index] << doc.document
                hash
              end

              indexes.keys.each do |index|
                index_tanked(:index => index).index.batch_insert(indexes[index])
              end

              puts "destroying"
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
