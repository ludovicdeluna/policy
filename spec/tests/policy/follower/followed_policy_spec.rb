# encoding: utf-8
require "ostruct"

describe Policy::Follower::FollowedPolicy do

  before { module Namespace; class Test; include Policy::Interface; end; end }
  after  { Object.send :remove_const, :Namespace                             }

  let(:namespace)    { Namespace       }
  let(:policy_class) { Namespace::Test }

  describe ".new" do

    subject { described_class.new nil, policy_class, :foo }

    it "creates the immutable object" do
      expect(subject).to be_frozen
    end

  end # describe .new

  describe "#name" do

    context "when name is set to nil" do

      subject { described_class.new nil, policy_class, nil }

      it "assigns uuid" do
        expect(subject.name.to_s).to match(/^\h{8}-(\h{4}-){3}\h{12}$/)
      end

      it "is a symbol" do
        expect(subject.name).to be_kind_of Symbol
      end

    end # context

    context "when name is set explicitly" do

      subject { described_class.new nil, policy_class, "foo" }

      it "returns the symbolized name" do
        expect(subject.name).to eq :foo
      end

    end # context

  end # describe #name

  describe "#policy" do

    let(:policy_name) { :Test }

    shared_examples "policy object class" do

      it "returns the constant" do
        expect(subject.policy).to eq policy_class
      end

    end # context

    it_behaves_like "policy object class" do
      subject { described_class.new :foo, policy_class, :foo }
    end

    it_behaves_like "policy object class" do
      subject { described_class.new namespace, policy_name, :foo }
    end

  end # describe #policy

  describe "#attributes" do

    let(:attributes) { %i(foo bar baz) }
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
