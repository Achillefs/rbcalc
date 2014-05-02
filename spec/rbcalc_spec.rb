require 'spec_helper'

describe Rbcalc do
  it 'can detect os' do # my dev machine
    Rbcalc.os.should eq(:macosx)
  end
end

describe Rbcalc::Engine do
  it 'raises error is an invalid parse is requested' do
    expect { subject.parse! }.to raise_error
    subject.hands = 'S2579H38AD458QC26,S4H24569TJQKD9CJK,S36TQH7D23TKC379Q,SAKJ8HDAJ76CAT854'
    expect { subject.parse! }.to raise_error
    subject.leader = 0
    expect { subject.parse! }.to raise_error
    subject.trump_suit = 2
    expect { subject.parse! }.to_not raise_error
  end
  
  context 'with valid game' do
    subject { 
      Rbcalc::Engine.new(
        hands: 'S2579H38AD458QC26,S4H24569TJQKD9CJK,S36TQH7D23TKC379Q,SAKJ8HDAJ76CAT854',
        leader: 0, trump_suit: 2
      )
    }
    
    it 'solves a game' do
      subject.parse!
      t1 = subject.tricks_made
      subject.tricks_made.should be_a(Integer)
    
      # if we swap leaders, tricks should be inversed
      subject.leader = 1
      subject.parse!
      (t1 + subject.tricks_made).should eq(13)
    
      subject.leader = 0
      subject.trump_suit = 2
      subject.parse!
      t1 = subject.tricks_made
      subject.tricks_made.should be_a(Integer)
    
      subject.leader = 1
      subject.parse!
      (t1 + subject.tricks_made).should eq(13)
    end
  end
end