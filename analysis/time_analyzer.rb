require_relative "timesheet"

class TimeAnalyzer
  # This constructor accepts a TimeSheet, and nothing else... The
  # passed in TimeSheet will be the basis for all of the analysis that
  # the returned object can perform.
  def initialize(timesheet)
    raise "Expected TimeSheet, got #{timesheet.class}" unless timesheet.class == TimeSheet
    @timesheet = timesheet
  end

  # Takes a number of seconds, and divides the TimeSheet into
  # TimeEntries that are grouped together if they are that number of
  # seconds close to each other.
  #
  # Default margin is an hour
  #
  # On top of that, if a block is provided, the TimeSheet is passed to
  # it, and whatever the return value of the block is the value that
  # will be processed. That means you can perform filtering at this
  # level too.
  def group_by_time(margin = (60 * 60))
    groups = []
    all = block_given? ? yield(@timesheet) : @timesheet.all.select {|entry| not entry.created.nil?}
    current = [all.first]

    all.inject do |head, tail|
      if tail.created.to_time - head.created.to_time <= margin
        current.push tail
      else
        groups.push current
        current = [tail]
      end

      tail
    end

    groups.push current
  end

  # Takes a number of seconds and creates a summary of the contiguous
  # time showing the starting time and date, as well as the duration.
  # Default if no argument is provided is to use 60 minutes as a
  # margin.
  def time_summary(margin = (60 * 60))
    grouped = group_by_time(margin)
    if grouped.first.first.nil?
      ["There are no entires to summarize! Try to import some data first."]
    else
      grouped.map do |entry|
        time = ((entry.first.created.to_time - entry.last.created.to_time) / 60).abs.round
        formatted = entry.first.created.strftime '%A, %d %b %Y at %I:%M%p'
        "#{time.zero? ? 'A few' : time} minute#{time == 1 ? '' : 's'} starting from #{formatted}"
      end
    end
  end
end
