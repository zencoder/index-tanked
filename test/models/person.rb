class Person < ActiveRecord::Base
  def self.reset!
    establish_connection :adapter => 'sqlite3', :database => ':memory:'
    connection.create_table table_name, :force => true do |t|
      t.string :name
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  reset!
end
