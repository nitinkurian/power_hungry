namespace :db do
  desc "Drop and recreate database"
  task :redo do
    require 'lib/power_hungry/database'
    `psql -U postgres -c "drop database #{PowerHungry::Database::DB_NAME}"`
    `psql -U postgres -c "create database #{PowerHungry::Database::DB_NAME}"`
    PowerHungry::Database.connect
    PowerHungry::Database.migrate!
  end
end

namespace :power_hungry do
  desc "Run, with lots of debug output"
  task :debug do
    require 'power_hungry'
    power_hungry = PowerHungry.new
    power_hungry.debug
  end

  desc "Run the collector"
  task :run do
    require 'power_hungry'
    power_hungry = PowerHungry.new
    power_hungry.run
  end

  desc "Update sensor names"
  task :name_sensors do
    require 'power_hungry'
    [
      [1, "Media Center"]
    ].each do |address, name|
      if sensor = Sensor.first(:address => address)
        sensor.update!(:name => name) unless sensor.name == name
      else
        sensor.create!(:address => address, :name => name)
      end
    end
  end
end
