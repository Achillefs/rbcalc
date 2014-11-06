require 'rbconfig'
require 'pathname'
require 'fileutils'

class RbcalcException < StandardError
end

class Rbcalc
  VERSION = "0.4.0"
  attr_accessor :leader, :trump, :hands, :played
  
  def initialize params = {}
    params.map { |k,v| self.send(:"#{k}=",v) }
    @tricks = []
  end
  
  def solve!
    cmd = [self.class.home.join('../bin/bcalconsole')]
    cmd << "-c #{hands}"
    cmd << "-d lin -t a -q"
    case leader
    when 0
      cmd << "-l n"
    when 1
      cmd << "-l e"
    when 2
      cmd << "-l s"
    when 3
      cmd << "-l w"
    end
    
    cmd << "-e '#{played} e'"
    
    puts cmd.join(' ')
    
    if resp = system(cmd.join(' '))
      parse_binout(resp)
    else
      raise RbcalcException, "Execution failed. OS not supported?"
    end
  end
  
  #### UTILITY METHODS ####
  def self.home
    Pathname.new(__FILE__).dirname
  end
  
  def solution
    @tricks
  end
  
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
        raise RbcalcException, "unknown os: #{host_os.inspect}"
      end
    )
  end
  
  def self.init!
    # prepare library for linking
    case Rbcalc.os
    when :linux, :macosx, :unix
      # ok
    else
      raise RbcalcException, "Rbcalc cannot currently run on #{Rbcalc.os}"
    end
  end
  
  private
  # we want to end up with a normalized array of scores per direction
  # that can easily match our Bridge gem format
  def parse_binout out
    # split output by line and then by spaces.
    # We end up with something like this:
    # [["N", "3", "5", "2", "7", "3"],
    # ["S", "3", "6", "2", "7", "3"],
    # ["E", "5", "1", "6", "1", "1"],
    # ["W", "5", "1", "6", "1", "1"]]
    out.split("\n").map { |l| l.split.map(&:strip) }.each do |row|
      dir = row.delete_at(0)
      idx = nil
      case dir
      when 'N'
        idx = 0
      when 'S'
        idx = 2
      when 'E'
        idx = 1
      when 'W'
        idx = 3
      end
      @tricks[idx] = row.map(&:to_i)
    end
    
    @tricks
  end
end

Rbcalc.init!
