require_relative "timesheet"

class TimeAnalyzer
  # This constructor accepts a TimeSheet, and nothing else... The
  # passed in TimeSheet will be the basis for all of the analysis that
  # the returned object can perform.
  def initialize(timesheet)
    raise "Expected TimeSheet, got #{}" unless timesheet.class == TimeSheet
    @timesheet = timesheet
  end

  # Takes a number of seconds, and divides the TimeSheet into
  # TimeEntries that are grouped together if they are that number of
  # seconds close to each other.
  #
  # Default margin is an hour
  def group_by_time(margin = (60 * 60))
    groups = []
    all = @timesheet.all
    current = [all.first]

    all.inject do |head, tail|
      if tail.created.to_time - head.created.to_time <= margin
        current.push tail
      else
        groups.push current
        current = []
      end

      tail
    end

    groups.push current
  end
end
