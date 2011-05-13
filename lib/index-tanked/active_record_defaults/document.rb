module IndexTanked

  module ActiveRecordDefaults

    class Document < ActiveRecord::Base
      set_table_name 'index_tanked_documents'

      def self.enqueue(document_hash)
        docid = document_hash[:docid] || document_hash['docid']
        destroy_all(:docid => docid)
        create(:docid => docid, :document => document_hash)
      end

      def document
        Marshal.load(Base64.decode64(read_attribute(:document)))
      end

      def document=(doc)
        write_attribute(:document, Base64.encode64(Marshal.dump(doc)))
      end

      def inspect
        super.sub(/document: \"[^\"\r\n]*\"/, %{document: #{document.inspect}})
      end

    end

  end

end

IndexTanked::Document = IndexTanked::ActiveRecordDefaults::Document
