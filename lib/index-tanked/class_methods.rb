module IndexTanked
  module ClassMethods
    attr_reader :index_tanked

    def index_tank(options={}, &block)
      @index_tanked ||= IndexTanked::ClassCompanion.new(options)
      @index_tanked.instance_exec &block
    end

    def search_index_tank(query, options={})
      SearchResult.new(index_tanked.add_fields_to_query(query), index_tanked.index, options)
    end

    def add_to_index_tank(doc_id, data, fallback=true)
      begin
        raise IndexTanked::IndexingDisabledError unless IndexTanked::Configuration.index_available?
        if IndexTanked::Configuration.timeout
          IndexTankedTimer.timeout(IndexTanked::Configuration.timeout, TimeoutExceededError) do
            sleep(IndexTanked::Configuration.timeout + 1) if $testing_index_tanked_timeout
            @index_tanked.index.document(doc_id).add(*data)
          end
        else
          @index_tanked.index.document(doc_id).add(*data)
        end
      rescue StandardError => e
        if fallback && IndexTanked::Configuration.add_to_index_fallback
          IndexTanked::Configuration.add_to_index_fallback.call({:class => self,
                                                                 :data => data,
                                                                 :doc_id => doc_id,
                                                                 :error => e})
        else
          raise
        end
      end
    end

    def add_to_index_tank_without_fallback(doc_id, data)
      add_to_index_tank(doc_id, data, false)
    end

    def delete_from_index_tank(doc_id, fallback=true)
      begin
        raise IndexTanked::IndexingDisabledError unless IndexTanked::Configuration.index_available?
        if IndexTanked::Configuration.timeout
          IndexTankedTimer.timeout(IndexTanked::Configuration.timeout, TimeoutExceededError) do
            sleep(IndexTanked::Configuration.timeout + 1) if $testing_index_tanked_timeout
            @index_tanked.index.document(doc_id).delete
          end
        else
          @index_tanked.index.document(doc_id).delete
        end
      rescue StandardError => e
        if fallback && IndexTanked::Configuration.delete_from_index_fallback
          IndexTanked::Configuration.delete_from_index_fallback.call({:class => self,
                                                                      :doc_id => doc_id,
                                                                      :error => e})
        else
          raise
        end
      end
    end

    def delete_from_index_tank_without_fallback(doc_id)
      delete_from_index_tank(doc_id, false)
    end
  end

end
