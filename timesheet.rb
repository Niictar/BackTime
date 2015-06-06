require_relative 'time'

# Adds a folder to the database's time records.
#
# If there is no path specified, it adds the current user's home
# folder.
def add_folder(path = Dir.home)
  Dir.glob "#{path}/**/*" do |filename|
    stat = File.stat filename

    TimeEntry.create(
      :name => File.absolute_path(filename),
      :type => "File",
      :created => stat.ctime,
      :modified => stat.mtime,
      :accessed => stat.atime,
      :recorded => Time.now
    ).save
  end
end

# Super-dangerous... Resets the database back to nothingness!
def reset_database
  DataMapper.auto_migrate!
end
