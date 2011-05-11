module IndexTanked

  module ActiveRecordDefaults

    class Document < ActiveRecord::Base
      set_table_name 'index_tanked_documents'

    end

  end

end

IndexTanked::Document = IndexTanked::ActiveRecordDefaults::Document
