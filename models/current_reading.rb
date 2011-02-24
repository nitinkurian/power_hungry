class CurrentReading
  include DataMapper::Resource

  property :id,            Serial
  property :amperage_data, Json
  property :voltage_data,  Json
  property :wattage_data,  Json

  property :created_at, DateTime, :default => lambda { DateTime.now }
  property :updated_at, DateTime, :default => lambda { DateTime.now }
end
