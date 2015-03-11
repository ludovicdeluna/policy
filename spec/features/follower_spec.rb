# encoding: utf-8

# The integration test for policy follower
describe Policy::Follower do

  before do

    Transaction = Class.new Struct.new(:sum)

    module Policies

      class Consistency < Policy.new(:debet, :credit)

        validates :debet, :credit, presence: true
        validates :sum, numericality: { equal_to: 0 }, allow_nil: true

        private

        def sum
          debet && credit && (credit.sum + debet.sum)
        end

      end # class Consistency

    end # module Policy

    # The follower class to be tested
    class Transfer < Struct.new(:withdrawal, :enrollment)
      include Policy::Follower

      use_policies Policies do
        follow_policy :Consistency, :withdrawal, :enrollment, as: :consistency
      end

    end # class Transfer

  end # before

  let(:withdrawal) { Transaction.new(-100) }
  subject { Transfer.new withdrawal, enrollment }

  describe "#follow_policies!" do

    context "when policy is met" do

      let(:enrollment) { Transaction.new(100) }

      it "passes if the policy is met" do
        expect { subject.follow_policies! }.not_to raise_error
      end

    end # context

    context "when policy is broken" do

      let(:enrollment) { Transaction.new(200) }

      it "fails if the policy is broken" do
        expect { subject.follow_policies! }.to raise_error
      end

    end # context

  end # describe #follow_policies!

  describe "#follow_policies?" do

    context "when policy is met" do

      let(:enrollment) { Transaction.new(100) }

      it "returns true if the policy is met" do
        expect(subject).to be_follow_policies
      end

    end # context

    context "when policy is broken" do

      let(:enrollment) { Transaction.new(200) }

      it "returns false if the policy is broken" do
        expect(subject).not_to be_follow_policies
      end

    end # context

  end # describe #follow_policies!

  after do
    %i(Transaction Transfer Policies)
      .each { |const| Object.__send__(:remove_const, const) }
  end

end # describe Policy::Follower
