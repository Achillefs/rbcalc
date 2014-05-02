require "rbcalc/version"
require "rbcalc/engine"
require 'rbconfig'

module Rbcalc
  def self.os
    @os ||= (
      host_os = RbConfig::CONFIG['host_os']
      case host_os
      when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
        :windows
      when /darwin|mac os/
        :macosx
      when /linux/
        :linux
      when /solaris|bsd/
        :unix
      else
        raise Error::WebDriverError, "unknown os: #{host_os.inspect}"
      end
    )
  end
end

case Rbcalc.os
when :macosx, :linux
  # good to go
else
  raise Error::WebDriverError, "Rbcalc cannot currently run on #{Rbcalc.os}"
end
