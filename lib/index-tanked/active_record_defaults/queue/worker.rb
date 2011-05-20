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
          log "Starting IndexTanked Queue"

          trap('TERM') { say 'Exiting...'; $exit = true }
          trap('INT')  { say 'Exiting...'; $exit = true }

          loop do
            count = Queue::Document.process_documents(@batch_size, @identifier)

            break if $exit

            if count.zero?
              sleep(SLEEP)
            else
              puts "#{count} documents indexed"
            end

            break if $exit
          end

        ensure
          Queue::Document.clear_locks(@identifier)
        end

        def log(message)
          RAILS_DEFAULT_LOGGER.info("[#{@identifier}] - #{message}")
        end

      end
    end
  end
end