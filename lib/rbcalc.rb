require 'rbconfig'
require 'pathname'
require 'fileutils'
require 'inline'

class Rbcalc
  VERSION = "0.3.0"
  attr_accessor :hands, :trump_suit, :leader, :played
  attr_accessor :solver, :declarer, :ns_score, :ew_score
  
  def initialize params = {}
    params.map { |k,v| self.send(:"#{k}=",v) }
    if leader == nil && declarer != nil
      self.leader = declarer_to_leader(declarer.to_i)
    end
    unless hands.nil? || hands.empty? || leader.nil? || trump_suit.nil?
      self.solver = create_solver('LIN', hands.to_s, trump_suit, leader)
    end
  end
  
  def solution
    { ns: self.ns_score, ew: self.ew_score }
  end
  
  def solve!
    # fails if no solver exists
    raise StandardError, 'solver not initialized' unless solver.is_a?(Integer)
    # play given moves
    self.exec(played) unless played.nil?
    
    # N E S W
    tricks = (0..3).map { |k| tricks_taken(k) }
    self.ns_score = tricks[0] + tricks[2]
    self.ew_score = tricks[1] + tricks[3]
    
    case now_playing
    when 0,2
      self.ns_score+= tricks_to_take
      self.ew_score = 13 - self.ns_score
    when 1,3
      self.ew_score+= tricks_to_take
      self.ns_score = 13 - self.ew_score
    end
    
    true
  end
  
  def last_error; _last_error(solver); end
  def cards_left; _cards_left(solver); end
  def played_count; _played_count(solver); end
  def now_playing; _now_playing(solver); end
  def destroy; _destroy(solver); end
  def tricks_taken(direction); _tricks_taken(solver,direction); end
  def all_tricks_taken
    (0..3).map { |i| tricks_taken(i) }
  end
  def tricks_to_take; _tricks_to_take(solver); end
  def exec(cmd); _exec(solver, cmd); end
  def trump; _trump(solver); end
  
  inline do |b|
    b.add_compile_flags "-L#{Pathname(__FILE__).dirname.join('..','vendor','bcalc')} -l bcalcdds"
    b.include '<stdio.h>'
    b.include "<#{Pathname(__FILE__).dirname.join('..','vendor','bcalc')}/bcalcdds.h>"
    
    b.c %{int next_hand(int hand, int delta){
      return bcalc_nextHand(hand, delta);
    }}
    
    b.c %{int declarer_to_leader(int declarer){
      return bcalc_declarerToLeader(declarer);
    }}
    
    b.c %{int version(){
      return bcalc_runtimeVersion();
    }}
    
    b.c %{long create_solver(const char* format, const char* hands, int strain, int leader) {
      return bcalcDDS_new(format, hands, strain, leader);
    }}
    
    b.c %{int _trump(long solver){
      struct BCalcDDS* dds;
      dds = (struct BCalcDDS*)solver;
      return bcalcDDS_getTrump(dds);
    }}
    
    b.c %{void _exec(long solver, const char* cmds){
      struct BCalcDDS* dds;
      dds = (struct BCalcDDS*)solver;
      bcalcDDS_exec(dds,cmds);
    }}
    
    b.c %{int _tricks_to_take(long solver){
      struct BCalcDDS* dds;
      dds = (struct BCalcDDS*)solver;
      return bcalcDDS_getTricksToTake(dds);
    }}
    
    b.c %{int _tricks_taken(long solver, int direction){
      int result[4];
      struct BCalcDDS* dds;
      dds = (struct BCalcDDS*)solver;
      bcalcDDS_getTricksTaken(dds, result);
      return result[direction];
    }}
    
    b.c %{void _destroy(long solver){
      struct BCalcDDS* dds;
      dds = (struct BCalcDDS*)solver;
      bcalcDDS_delete(dds);
    }}
    
    b.c %{int _now_playing(long solver){
      struct BCalcDDS* dds;
      dds = (struct BCalcDDS*)solver;
      return bcalcDDS_getPlayerToPlay(dds);
    }}
    
    b.c %{int _played_count(long solver){
      struct BCalcDDS* dds;
      dds = (struct BCalcDDS*)solver;
      return bcalcDDS_getPlayedCardsCount(dds);
    }}
    
    b.c %{int _cards_left(long solver){
      struct BCalcDDS* dds;
      dds = (struct BCalcDDS*)solver;
      return bcalcDDS_getCardsLeftCount(dds);
    }}
    
    b.c %{int _last_error(long solver){
      struct BCalcDDS* dds;
      dds = (struct BCalcDDS*)solver;
      return bcalcDDS_getLastError(dds);
    }}
  end
  
  #### UTILITY METHODS ####
  def self.home
    Pathname.new(__FILE__).dirname
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
        raise Error::WebDriverError, "unknown os: #{host_os.inspect}"
      end
    )
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
