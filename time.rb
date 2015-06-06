require 'data_mapper'

DataMapper::Logger.new $stdout, :debug
DataMapper.setup :default, 'sqlite:time.db'

# Basic time type for storing various records of tim
class TimeEntry
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :type, String
  property :created, DateTime
  property :modified, DateTime
  property :accessed, DateTime
  property :recorded, DateTime
end

DataMapper.finalize
DataMapper.auto_upgrade!
