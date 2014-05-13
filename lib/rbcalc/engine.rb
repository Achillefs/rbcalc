require 'inline'
require 'pathname'

=begin rdoc
  require 'rbcalc'
  e = Rbcalc::Engine.new(
    hands: 'S2579H38AD458QC26,S4H24569TJQKD9CJK,S36TQH7D23TKC379Q,SAKJ8HDAJ76CAT854',
    played: 'e', leader: 0, trump_suit: 2
  )
=end
module Rbcalc
  class Engine
    attr_accessor :hands, :leader, :trump_suit, :played, :tricks_made
    
    def initialize params = {}
      params.map { |k,v| self.send(:"#{k}=",v) }
    end
    
    def parse!
      if hands.nil? || hands.empty? || leader.nil? || trump_suit.nil?
        raise ArgumentError, 'Rbcalc needs at least the hands, dealer direction and trump suit'
      end
      
      self.tricks_made = solve(hands, played.to_s, trump_suit, leader)
    end
    
    inline do |b|
      b.add_compile_flags "-L#{Pathname.new(__FILE__).dirname.join('..','..','vendor','bcalc')} -l bcalcdds"
      b.include '<stdio.h>'
      b.include '<bcalcdds.h>'
      b.c %{int solve(const char * hands, const char * played, int strain, int leader){
        int res;
        BCalcDDS* solver = bcalcDDS_new("LIN", hands, strain, leader);
        if (solver == 0) exit(1); //out of memory error
        bcalcDDS_exec(solver, played);
        res = bcalcDDS_getTricksToTake(solver);
        bcalcDDS_delete(solver);
        return res;
      }}
    end
  end
end