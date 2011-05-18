module IndexTanked
  module ActiveRecordDefaults
    module Queue
      class Worker
        SLEEP = 5

        def initialize(options={})
          @batch_size = options[:batch_size] || 100
          @identifier = "host:#{Socket.gethostname} pid:#{Process.pid}" rescue "pid:#{Process.pid}"
        end

        def start
          loop do
            count = Queue::Document.process_documents(@batch_size, @identifier)
            if count.zero?
              sleep(SLEEP)
            else
              puts "#{count} documents indexed"
            end
          end
        end
        
      end
    end
  end
end