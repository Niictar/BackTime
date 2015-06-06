require 'sqlite3'
require_relative 'time'

# Super-dangerous... Resets the database back to nothingness!
def reset_database
  DataMapper.auto_migrate!
end

# Adds a folder to the database's time records.
#
# If there is no path specified, it adds the current user's home
# folder.
def add_folder(path = Dir.home)
  Dir.glob "#{path}/**/*" do |filename|
    stat = File.stat filename

    TimeEntry.create(
      :name => File.absolute_path(filename),
      :path => File.basename(filename),
      :type => "File",
      :created => stat.ctime,
      :modified => stat.mtime,
      :accessed => stat.atime,
      :recorded => Time.now
    ).save
  end
end

# Adds a Firefox history file to the database's time records.
#
# This type of add will set the created, accessed, and modified dates
# to the date of visiting each site.
#
# The Firefox history file is an SQLite database called
# "places.sqlite" that should be in the root of your Firefox profile.
def add_firefox_history(history_file)
  SQLite3::Database.new history_file do |db|
    db.execute "SELECT * FROM moz_historyvisits" do |history_entry|
      place = db.execute("SELECT * FROM moz_places where id = ?", history_entry[2]).first
      visit_time = Time.at(history_entry[3] / 1000000)

      TimeEntry.create(
        :name => place[2],
        :path => place[1],
        :type => "Firefox History",
        :created => visit_time,
        :modified => visit_time,
        :accessed => visit_time,
        :recorded => Time.now
      ).save unless place.nil?
    end
  end
end

# Adds a Chrome history file to the database's time records.
#
# Like the Firefox import above, this type of add will set the
# created, access, and modified times to the visit time for each item
# in history.
#
# The Chrome history file called "History" is likely in the profile
# folder of your Chrome root. (So, often "Default/History")
def add_chrome_history(history_file)
  SQLite3::Database.new history_file do |db|
    db.execute "SELECT * FROM visits" do |history_entry|
      place = db.execute("SELECT * FROM urls where id = ?", history_entry[1]).first
      visit_time = Time.at(history_entry[3] / 1000000)

      TimeEntry.create(
        :name => place[2],
        :path => place[1],
        :type => "Google Chrome History",
        :created => visit_time,
        :modified => visit_time,
        :accessed => visit_time,
        :recorded => Time.now
      ).save unless place.nil?
    end
  end
end
