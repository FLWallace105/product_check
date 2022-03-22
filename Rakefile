require 'dotenv'
require 'active_record'
require 'sinatra/activerecord/rake'

require_relative 'product_check'

#require 'active_record/railties/databases.rake'

Dotenv.load

include ActiveRecord::Tasks

root = File.expand_path '..', __FILE__
DatabaseTasks.env = ENV['RACK_ENV'] || 'development'
DatabaseTasks.database_configuration = YAML.load(File.read(File.join(root, 'config/database.yml')))
DatabaseTasks.db_dir = File.join root, 'db'
DatabaseTasks.migrations_paths = [File.join(root, 'db/migrate')]
DatabaseTasks.root = root

ActiveRecord::Base.configurations = YAML.load(File.read(File.join(root, 'config/database.yml')))
ActiveRecord::Base.establish_connection (ENV['RACK_ENV']|| 'development')&.to_sym

load 'active_record/railties/databases.rake'

namespace :product_check do

    desc 'Check Mix and Match Product Collections'
        task :check_mix_match_collection do |t|
            ProductMixMatch::ShopifyGetter.new.get_mix_match_collection_products
    end
    

    
end