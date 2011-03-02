module IndexTanked

  class ActiveRecordSearchResult < SearchResult

    def initialize(search_string, index, model, options={})
      super(search_string, index, options)
      @model = model
    end

    def ids
      results.map { |result| id = result['docid'].match(/^#{@model.name}:(\d+)$/); id && id[1].to_i }.compact.uniq
    end

    def records
      @records ||= @model.find(*ids)
    end

  end

end