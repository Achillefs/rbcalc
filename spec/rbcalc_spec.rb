require 'spec_helper'

describe Rbcalc do
  it 'can detect os' do # my dev machine
    Rbcalc.os.should eq(:macosx)
  end
  
  describe 'binary mode' do
    subject { Rbcalc.new(
      hands: 'S4Q93H6QD247QCQJ4,STHK49ADT63C785AT,S5KA2H38TDK8ACK96,S7J86H7J52D9J5C23', 
      trump: 2, leader: 0, 
      played: 'HQ HA HT H2 C5 CK C2 CQ S2 S6 S3 ST CA C9 C3 CJ CT C6 D5 C4') 
    }
    
    let(:output) { %[  N   3  5  2  7  3
  S   3  6  2  7  3
  E   5  1  6  1  1
  W   5  1  6  1  1] }
    
    it 'can run the binary' do
      subject.solve!
      #subject.solution.should_not eq([])
    end
  
    it 'can parse the binary output' do
      subject.send :parse_binout, output
      #subject.solution.should eq(ns: 2, ew: 6)
    end
  end
end