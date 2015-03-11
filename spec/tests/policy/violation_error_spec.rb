# encoding: utf-8
require "ostruct"

describe Policy::ViolationError do

  # OpenStruct is used instead of double because it should be frozen
  let(:policy) { OpenStruct.new(messages: ["foo"])  }

  subject { described_class.new policy }

  describe ".new" do

    it "takes a policy" do
      expect { described_class.new }.to raise_error ArgumentError
      expect { subject }.not_to raise_error
    end

    it "is a RuntimeError" do
      expect(subject).to be_kind_of RuntimeError
    end

    it "is immutable" do
      expect(subject).to be_frozen
    end

  end # describe .new

  describe "#policy" do

    it "returns the policy" do
      expect(subject.policy).to eq policy
    end

    it "is immutable" do
      expect(subject.policy).to be_frozen
    end

    it "doesn't freeze the source policy object" do
      subject
      expect(policy).not_to be_frozen
    end

  end # describe #policy

  describe "#messages" do

    it "delegated to the policy" do
      expect(subject.messages).to eq subject.policy.messages
    end

    it "is immutable" do
      expect(subject.messages).to be_frozen
    end

  end # describe #messages

  describe "#inspect" do

    it "returns a proper text" do
      expect(subject.inspect)
        .to eq "#<Policy::ViolationError: #{ subject.message }>"
    end

  end # describe #inspect

  describe "#message" do

    it "returns a proper text" do
      expect(subject.message)
        .to eq "#{ policy.inspect } violated: #{ subject.messages }"
    end

  end # describe #message

end # describe Policy::ViolationError
