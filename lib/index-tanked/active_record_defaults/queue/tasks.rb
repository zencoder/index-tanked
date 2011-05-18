namespace :indextanked do
  namespace :queue do
    desc "Start an index-tanked queue worker."
    task :process => :environment do
      IndexTanked::ActiveRecordDefaults::Queue::Worker.new.start(:batch_size => ENV['BATCH_SIZE'])
    end
  end
end
