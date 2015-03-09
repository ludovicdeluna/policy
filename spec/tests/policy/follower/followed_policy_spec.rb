# encoding: utf-8
require "ostruct"

describe Policy::Follower::FollowedPolicy do

  before { module Namespace; class Policy < ::Policy.new(:foo, :bar); end; end }
  after  { Object.send :remove_const, :Namespace                               }

  let(:namespace)    { Namespace       }
  let(:policy_class) { Namespace::Policy }

  describe ".new" do

    shared_examples "refusing wrong number of attributes" do |*list|

      subject { described_class.new nil, policy_class, :policy, *list }

      it "raises ArgumentError" do
        expect { subject }.to raise_error(ArgumentError)
      end

      it "sets a proper message for the exception" do
        begin
          subject
        rescue => err
          expect(err.message).to eq(
            "#{ policy_class } requires 2 attribute(s)." \
            " #{ list } cannot be assigned."
          )
        end
      end

    end # shared examples

    it_behaves_like "refusing wrong number of attributes", :foo
    it_behaves_like "refusing wrong number of attributes", :foo, :bar, :baz

    it "creates the immutable object" do
      subject = described_class.new nil, policy_class, :policy, :foo, :bar

      expect(subject).to be_frozen
    end

  end # describe .new

  describe "#name" do

    context "when name is set to nil" do

      subject { described_class.new nil, policy_class, nil, :foo, :bar }

      it "assigns uuid" do
        expect(subject.name.to_s).to match(/^\h{8}-(\h{4}-){3}\h{12}$/)
      end

      it "is a symbol" do
        expect(subject.name).to be_kind_of Symbol
      end

    end # context

    context "when name is set explicitly" do

      subject { described_class.new nil, policy_class, "policy", :foo, :bar }

      it "returns the symbolized name" do
        expect(subject.name).to eq :policy
      end

    end # context

  end # describe #name

  describe "#policy" do

    let(:policy_name) { :Policy }

    shared_examples "policy object class" do

      it "returns the constant" do
        expect(subject.policy).to eq policy_class
      end

    end # context

    it_behaves_like "policy object class" do
      subject { described_class.new :foo, policy_class, :foo, :bar, :baz }
    end

    it_behaves_like "policy object class" do
      subject { described_class.new namespace, policy_name, :foo, :bar, :baz }
    end

  end # describe #policy

  describe "#attributes" do

    let(:attributes) { %i(foo bar) }
    subject { described_class.new nil, policy_class, :foo, *attributes }

    it "is set by the initializer" do
      expect(subject.attributes).to eq attributes
    end

  end # describe #attributes

  describe "#apply_to" do

    let(:attributes) { { foo: :bar, bar: :baz }   }
    let(:follower)   { OpenStruct.new(attributes) }

    subject do
      described_class.new nil, policy_class, nil, *attributes.keys
    end

    it "calls policy_class validation with follower attributes" do
      expect(policy_class).to receive(:apply).with(*attributes.values)
      subject.apply_to(follower)
    end

  end # describe #apply_to

end # describe Policy::Follower::Policy
