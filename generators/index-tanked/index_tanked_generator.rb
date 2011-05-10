class IndexTankedGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template 'migration.rb', 'db/migrate', :migration_file_name => "create_index_tanked_documents"
    end
  end
end
