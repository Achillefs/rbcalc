require 'rbconfig'
require 'pathname'
require 'fileutils'

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
  
  def self.home
    Pathname.new(__FILE__).dirname
  end
  
  def self.init!
    vpath = self.home.join('..','vendor','bcalc')
    # prepare library for linking
    case Rbcalc.os
    when :macosx
      # assign a new ID to the library os that xtools can get to id
      `/usr/bin/install_name_tool -id #{vpath}/libbcalcdds.dylib #{vpath}/libbcalcdds.dylib`
    when :linux
      # ok
    else
      raise Error::WebDriverError, "Rbcalc cannot currently run on #{Rbcalc.os}"
    end
  end
end

Rbcalc.init!

require "rbcalc/version"
require "rbcalc/engine"
