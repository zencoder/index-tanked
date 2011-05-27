namespace :index_tanked do
  namespace :queue do
    desc "Start an index-tanked queue worker."
    task :process => :environment do
      IndexTanked::ActiveRecordDefaults::Queue::Worker.new(:batch_size => ENV['BATCH_SIZE']).start
    end
  end
end
