require 'spec_helper'

describe Rbcalc do
  it 'can detect os' do # my dev machine
    Rbcalc.os.should eq(:macosx)
  end
  subject { 
    Rbcalc.new(hands: 'S2579H38AD458QC26,S4H24569TJQKD9CJK,S36TQH7D23TKC379Q,SAKJ8HDAJ76CAT854', trump_suit: 2, leader: 0)
  }
  
  it { subject.next_hand(3,1).should eq(0) }
  it { subject.declarer_to_leader(0).should eq(3) }
  it { subject.version.should eq(14020) }

  it { subject.solver.should be_a(Fixnum) }
  it { subject.destroy.should eq(nil) }
  it { subject.trump_suit.should eq(2) }
  it { subject.tricks_to_take.should eq(1) }
  # noone has taken any tricks
  it { subject.tricks_taken(0).should eq(0) }
  it { subject.tricks_taken(1).should eq(0) }
  it { subject.tricks_taken(2).should eq(0) }
  it { subject.tricks_taken(3).should eq(0) }
  it { subject.played_count.should eq(0) }
  it { subject.cards_left.should eq(52) }
  
  it 'returns opposite tricks after playing 1 card' do
    subject.exec('3S')
    subject.tricks_to_take.should eq(12)
  end
  
  it 'returns same tricks after playing 2 cards' do
    subject.exec('3S AS')
    subject.tricks_to_take.should eq(1)
  end
  
  it 'knows how many cards have been played' do
    subject.exec('3S AS')
    subject.played_count.should eq(2)
    subject.cards_left.should eq(50)
  end
  
  it 'returns correct tricks taken after a single trick is taken' do
    subject.exec('3S AS 2S 4S')
    subject.tricks_taken(0).should eq(0)
    subject.tricks_taken(1).should eq(1)
    subject.tricks_taken(2).should eq(0)
    subject.tricks_taken(3).should eq(0)
  end
  
  it 'gets current player' do
    subject.exec('3S AS 2S 4S')
    subject.now_playing.should eq(1)
    subject.exec('KS')
    subject.now_playing.should eq(2)
    subject.exec('5S')
    subject.now_playing.should eq(3)
    subject.exec('2H') # he cuts with a heart
    subject.now_playing.should eq(0)
    subject.exec('6S')
    subject.now_playing.should eq(3)
  end
end