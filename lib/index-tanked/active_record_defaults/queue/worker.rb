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

          trap('TERM') { log 'Exiting...'; $exit = true }
          trap('INT')  { log 'Exiting...'; $exit = true }
          trap('QUIT') { log 'Exiting...'; $exit = true }

          loop do
            count = process_documents(@batch_size)

            break if $exit

            if count.zero?
              (SLEEP * 2).times{ sleep(0.5) unless $exit }
            end

            break if $exit
          end
        end

        def process_documents(batch_size)
          Queue::Document.clear_expired_locks
          number_locked = Queue::Document.lock_records_for_batch(batch_size, @identifier)
          log("#{number_locked} records locked.")
          return number_locked if number_locked.zero?
          begin
            documents = Queue::Document.find_all_by_locked_by(@identifier)
            partitioned_documents = Queue::Document.partition_documents_by_companion_key(documents)
            send_batches_to_indextank(partitioned_documents)
            documents_deleted = Queue::Document.delete_all(:locked_by => @identifier)
            log("#{documents_deleted} completed documents removed from queue.")
            documents_deleted
          rescue StandardError, Timeout::Error => e
            handle_error(e)
            locks_cleared = Queue::Document.clear_locks_by_identifier(@identifier)
            log("#{locks_cleard} locks cleared")
            0 # return 0 so it sleeps
          end
        end

        def send_batches_to_indextank(partitioned_documents)
          partitioned_documents.keys.each do |companion_key|
            index_name = companion_key.split(' - ').last
            record_count = partitioned_documents[companion_key].size
            log("#{record_count} document(s) prepared for #{index_name}.")
            Queue::Document.index_tanked(companion_key).index.batch_insert(partitioned_documents[companion_key])
          end
        end

        def handle_error(e)
          log("something (#{e.class} - #{e.message}) got jacked, unlocking")
          log e.backtrace
        end

        def log(message)
          message = "[Index Tanked Worker: #{@identifier}] - #{message}"
          puts message
          RAILS_DEFAULT_LOGGER.info(message)
        end

      end
    end
  end
end