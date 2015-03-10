# encoding: utf-8

describe Policy do

  describe ".new" do

    subject { described_class.new :debet, :credit }

    it "builds the Struct" do
      expect(subject.ancestors).to include Struct
    end

    it "adds required attributes" do
      methods = subject.instance_methods

      %i(debet debet= credit credit=).each do |method|
        expect(methods).to include method
      end
    end

    it "includes Policy::Interface" do
      expect(subject).to include(Policy::Interface)
    end

  end # describe .new

end # describe Policy
