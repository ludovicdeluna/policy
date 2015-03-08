# encoding: utf-8
require "ostruct"

describe Policy::Follower::FollowedPolicies do

  it "is a hash" do
    expect(subject).to be_kind_of Hash
  end

  describe "#add" do

    let(:policy) { double :policy, name: :foo }

    it "registers a policy" do
      expect { subject.add policy }.to change { subject }.to(foo: policy)
    end

  end # describe #add

  describe "#apply_to" do

    let(:follower) { double }

    before do
      %i(first second third).each do |item|
        subject.add double(name: item, apply_to: nil)
      end
    end

    shared_examples "applying policies" do |applied_policies = nil|

      before { applied_policies ||= subject.keys }
      let(:skipped_policies) { subject.keys - applied_policies }

      it "[applies policies]" do
        policies = applied_policies.map(&subject.method(:[]))

        policies.each do |policy|
          expect(policy).to receive(:apply_to).with(follower).ordered
        end
      end

      it "[skips policies]" do
        policies = skipped_policies.map(&subject.method(:[]))

        policies.each do |policy|
          expect(policy).not_to receive(:apply_to)
        end
      end

    end # shared examples

    context "by default" do

      after { subject.apply_to follower }

      it_behaves_like "applying policies"

    end # context

    context "with a list of names" do

      after { subject.apply_to follower, :third, :first }

      it_behaves_like "applying policies", %i(third first)

    end # context

    context "with a repetitive names" do

      after { subject.apply_to follower, :third, :third, :third }

      it_behaves_like "applying policies", %i(third third third)

    end # context

    context "with an array of names" do

      after { subject.apply_to follower, %w(third first forth) }

      it_behaves_like "applying policies", %i(third first)

    end # context

  end # describe #apply_to

end # describe Policy::Follower::FollowedPolicies
