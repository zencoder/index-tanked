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

        def self.enqueue(document_hash)
          docid = document_hash[:docid] || document_hash['docid']
          destroy_all(:docid => docid)
          create(:docid => docid, :document => document_hash)
        end

        def self.index_tanked
          @index_tanked ||= IndexTanked::ClassCompanion.new
        end

        def self.work_off(batch_size, identifier)
          puts "Locking"
          locked = update_all(["locked_by = ?, locked_at = clock_timestamp() at time zone 'UTC'", identifier],
                               ["locked_by IS NULL"], :limit => batch_size)
          puts "#{locked} locked."
          if locked > 0
            puts "Getting documents"
            documents = get_documents_by_identifier(identifier)
            begin
              puts "sending to indextanked"
              index_tanked.index.batch_insert(documents)
              puts "destroying"
              destroy_all(:locked_by => identifier)
            rescue StandardError => e
              puts "something (#{e.class} - #{e.message}) got jacked, unlocking"
              update_all(["locked_by = NULL, locked_at = NULL"],
                         ["locked_by = ?", identifier])
            end
          end

        end

        def self.get_documents_by_identifier(identifier)
          find_all_by_locked_by(identifier, :select => 'document').map(&:document)
        end

      end

    end
  end
end

IndexTanked::Document = IndexTanked::ActiveRecordDefaults::Queue::Document
