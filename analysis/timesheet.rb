require 'sqlite3'
require 'nokogiri'
require 'csv'

# A TimeSheet class that encapsulates the logic of reading in time
# data of vrious types and storing it into a database.
class TimeSheet
  attr_reader :database_url, :table

  # Basic time type for storing various records of time
  class TimeEntry
    attr_accessor :id, :name, :path, :type, :created, :modified, :accessed, :recorded

    # TimeEntry constructor, accepts a number of key arguments to
    # populate the resulting TimeEntry's fields.
    #
    # Accepted arguments include:
    # :id => The ID of the TimeEntry in the database.
    # :name => The name of the place visited.
    # :path => The path or address of the place visited.
    # :type => The type of history this is.
    # :created => The time the entry was created.
    # :modified => The last time the entry was modified.
    # :accessed => The last time the entry was accessed.
    # :recorded => The time the entry was recorded into the database.
    def initialize(values = {})
      @id = values[:id]
      @name = values[:name]
      @path = values[:path]
      @type = values[:type]
      @created = values[:created]
      @modified = values[:modified]
      @accessed = values[:accessed]
      @recorded = values[:recorded] || Time.now
    end

    # Converts this object into an array.
    def to_a
      [id, name, path, type, created, modified, accessed, recorded]
    end

    # Creates any number of TimeEntries from the an SQLite ResultSet
    #
    # This method will convert the three date columns (created,
    # accessed, modified, and recorded) into DateTime objects.
    def self.from_resultset(rs)
      rs.map do |row|
        new :id => row[0],
            :name => row[1],
            :path => row[2],
            :type => row[3],
            :created => DateTime.parse(row[4]),
            :modified => DateTime.parse(row[5]),
            :accessed => DateTime.parse(row[6]),
            :recorded => DateTime.parse(row[7])
      end
    end
  end

  # The constructor Accepts a path to a database file to play with, as
  # well as a boolean argument about whether or not we should output
  # the SQL this class runs to the console.
  def initialize(database_file)
    @db = SQLite3::Database.new database_file
    @table = "time_entries"
    create_database unless check_table @table
  end

  # Creates database structure
  def create_database
    @db.execute <<-SQL
      CREATE TABLE "#{@table}" (
        "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        "name" VARCHAR,
        "path" VARCHAR,
        "type" VARCHAR,
        "created" TIMESTAMP,
        "modified" TIMESTAMP,
        "accessed" TIMESTAMP,
        "recorded" TIMESTAMP
      )
    SQL
  end

  # Super-dangerous... Resets the database back to nothingness!
  def reset_database
    @db.execute "DELETE FROM '#{@table}'"
  end

  # Adds a folder to the database's time records.
  #
  # If there is no path specified, it adds the current user's home
  # folder.
  def add_folder(path = Dir.home)
    files = []

    Dir.glob "#{path}/**/*" do |filename|
      stat = File.stat filename

      files << TimeEntry.new(
        :name => File.absolute_path(filename),
        :path => File.basename(filename),
        :type => "File",
        :created => stat.ctime,
        :modified => stat.mtime,
        :accessed => stat.atime,
        :recorded => Time.now
      )
    end

    add_entries files
  end

  # Adds a Firefox history file to the database's time records.
  #
  # This type of add will set the created, accessed, and modified dates
  # to the date of visiting each site.
  #
  # The Firefox history file is an SQLite database called
  # "places.sqlite" that should be in the root of your Firefox profile.
  def add_firefox_history(history_file)
    history = []

    SQLite3::Database.new history_file do |db|
      db.execute "SELECT * FROM moz_historyvisits" do |history_entry|
        place = db.execute("SELECT * FROM moz_places where id = ?", history_entry[2]).first
        visit_time = Time.at(history_entry[3] / 1000000)

        history << TimeEntry.new(
          :name => place[2],
          :path => place[1],
          :type => "Firefox History",
          :created => visit_time,
          :modified => visit_time,
          :accessed => visit_time,
          :recorded => Time.now
        ) unless place.nil?
      end
    end

    add_entries history
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
    history = []

    SQLite3::Database.new history_file do |db|
      db.execute "SELECT * FROM visits" do |history_entry|
        place = db.execute("SELECT * FROM urls where id = ?", history_entry[1]).first
        # Time is number of 100 msecs from January 1, 1601.
        visit_time = (Time.new(1601, 1, 1) + history_entry[2] / 1000000)

        history << TimeEntry.new(
          :name => place[2],
          :path => place[1],
          :type => "Google Chrome History",
          :created => visit_time,
          :modified => visit_time,
          :accessed => visit_time,
          :recorded => Time.now
        ) unless place.nil?
      end
    end

    add_entries history
  end

  # Adds an Internet Explorer History Viewer XML file to the database
  def add_iehv_xml(xml_file)
    history = []

    Nokogiri::XML(File.open(xml_file)).css("visited_links_list item").each do |entry|
      visit_time = DateTime.strptime entry.css('modified_date').inner_text, "%m/%d/%Y %I:%M:%S %p"
      history << TimeEntry.new(
        :name => entry.css('title').inner_text,
        :path => entry.css('url').inner_text,
        :type => "Internet Explorer History Viewer Entry",
        :created => visit_time,
        :modified => visit_time,
        :accessed => visit_time,
        :recorded => Time.now
      )
    end

    add_entries history
  end

  # Returns all Time entries from the database.
  def all
    TimeEntry.from_resultset @db.query "SELECT * from '#{@table}' ORDER BY date(created) ASC"
  end

  # Converts this TimeSheet into a CSV string. (Often REALLY BIG)
  def to_csv
    CSV.generate do |csv|
      all.each { |entry| csv << entry.to_a[1..-1] }
    end
  end

  private
  # Checks to see if a table exists in the current database.
  def check_table(table)
    @db.query("SELECT name FROM sqlite_master WHERE type='table' AND name=?", [table]).any?
  end

  # Adds an individual TimeEntry to the base.
  def add_entry(time_entry)
    @db.execute <<-SQL, *time_entry.to_a[1..-1]
      INSERT INTO "#{@table}"
       ("name", "path", "type", "created", "modified", "accessed", "recorded")
      VALUES
       (?, ?, ?, ?, ?, ?, ?)
    SQL
  end

  # Mass-inserts TimeEntries into the database. With really large
  # arrays, this function will split the input into sets of 500 in
  # order to play nice with SQLite
  #
  # Accepts one paramater, an array of TimeEntries you wish to insert
  # into the database simultaneously.
  def add_entries(time_entries)
    until time_entries.empty?
      transaction = time_entries.shift 500

      statement = @db.prepare <<-SQL
        INSERT INTO "#{@table}"
         ("name", "path", "type", "created", "modified", "accessed", "recorded")
        VALUES
         #{transaction.map do '(?, ?, ?, ?, ?, ?, ?)' end.join ','}
      SQL

      statement.execute(
        *transaction.inject([]) do |acc, item|
          acc + item.to_a[1..-1].map {|column| column.to_s}
        end)
    end
  end
end
