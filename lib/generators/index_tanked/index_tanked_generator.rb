require 'rails/generators/migration'
require 'rails/generators/active_record'

class IndexTankedGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  extend ActiveRecord::Generators::Migration
  source_root File.expand_path('../templates', __FILE__)

  def create_migration_file
    migration_template 'migration.rb', "db/migrate/create_index_tanked_documents.rb"
  end
end