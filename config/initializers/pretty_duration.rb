# Taken from http://stackoverflow.com/a/28892071/7306145
# Only works for integer values less than 24 hours

class Integer
  def pretty_duration
    parse_string = self < 3600 ? '%M:%S' : '%H:%M:%S'
    Time.at(self).utc.strftime(parse_string)
  end
end
