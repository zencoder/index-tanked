module IndexTanked

  module ActiveRecordDefaults

    class Document < ActiveRecord::Base

    end

  end

end

IndexTanked::Document = IndexTanked::ActiveRecordDefaults::Document