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
    incpath = Pathname('/usr/local/include')
    libpath = Pathname('/usr/local/lib')
    # prepare library for linking
    case Rbcalc.os
    when :macosx
      unless File.exists?(libpath.join('libbcalcdds.dylib'))
        FileUtils.ln_s(vpath.join('libbcalcdds.dylib'),libpath.join('libbcalcdds.dylib')) 
      end
      unless File.exists?(incpath.join('bcalcdds.h'))
        FileUtils.ln_s(vpath.join('bcalcdds.h'),incpath.join('bcalcdds.h')) 
      end
    when :linux
      unless File.exists?(libpath.join('libbcalcdds.so'))
        FileUtils.ln_s(vpath.join('libbcalcdds.so'),libpath.join('libbcalcdds.so')) 
      end
      unless File.exists?(incpath.join('bcalcdds.h'))
        FileUtils.ln_s(vpath.join('bcalcdds.h'),incpath.join('bcalcdds.h')) 
      end
    else
      raise Error::WebDriverError, "Rbcalc cannot currently run on #{Rbcalc.os}"
    end
  end
end

Rbcalc.init!

require "rbcalc/version"
require "rbcalc/engine"
