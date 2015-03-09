# encoding: utf-8

describe Policy::Follower do

  before { Test = Class.new.include described_class }
  after  { Object.send :remove_const, :Test         }

  let(:test_class)  { Test }
  subject { test_class.new }

  it "includes Policy::Validations" do
    expect(test_class).to include Policy::Validations
  end

  describe ".followed_policies" do

    let(:followed_policies) { Policy::Follower::FollowedPolicies }

    it "returns the AppiedPolicies object" do
      expect(test_class.followed_policies).to be_kind_of followed_policies
    end

  end # describe .followed_policies

  describe ".follow_policy" do

    let(:followed_policy) { Policy::Follower::FollowedPolicy }

    let(:policy)       { double name: :foo }
    let(:policy_class) { double }
    let(:name)         { double }
    let(:attributes)   { [double, double] }

    before { allow(followed_policy).to receive(:new) { policy } }

    context "by default" do

      after { test_class.follow_policy policy_class, *attributes }

      it "creates new followed policy" do
        expect(followed_policy)
          .to receive(:new)
          .with(test_class, policy_class, nil, *attributes)
      end

      it "adds new policy to .followed_policies" do
        expect(test_class.followed_policies).to receive(:add).with(policy)
      end

    end # context

    context "as: name" do

      after { test_class.follow_policy(policy_class, *attributes, as: name) }

      it "creates named followed policy" do
        expect(followed_policy)
          .to receive(:new)
          .with(test_class, policy_class, name, *attributes)
      end

    end # context

    context "inside #use_policies" do

      let(:namespace) { double }

      subject do
        test_class.use_policies namespace do
          follow_policy :foo, as: :bar
        end
      end

      it "sends the namespace to followed policy" do
        expect(followed_policy)
          .to receive(:new).with(namespace, :foo, :bar)
        subject
      end

      it "doesn't change default namespace" do
        subject
        expect(followed_policy)
          .to receive(:new).with(test_class, :foo, :bar)
        test_class.follow_policy :foo, as: :bar
      end

    end # context

  end # describe .follow_policy

  describe "#follow_policies!" do

    context "without names" do

      after { subject.follow_policies! }

      it "applies .followed_policies to itself" do
        expect(test_class.followed_policies)
          .to receive(:apply_to).with(subject)
      end

    end # context

    context "with names" do

      let(:names) { %i(foo bar baz) }
      after { subject.follow_policies!(*names) }

      it "applies .followed_policies to itself with names" do
        expect(test_class.followed_policies)
          .to receive(:apply_to).with(subject, *names)
      end

    end # context

    context "when a ViolationError is raised" do

      let(:error)    { Policy::ViolationError.allocate } # not frozen
      let(:messages) { %w(foo bar baz) }

      before do
        allow(error).to receive(:messages) { messages }
        allow(test_class.followed_policies).to receive(:apply_to) { fail error }
      end

      it "populates messages with errors" do
        expect { subject.follow_policies! rescue nil }
          .to change { subject.send(:errors).messages }
          .to(base: messages)
      end

      it "re-raises the exception" do
        expect { subject.follow_policies! }.to raise_error(error)
      end

    end # context

  end # describe #follow_policies!

  describe "#follow_policies?" do

    before { allow(subject).to receive(:follow_policies!) }

    it "calls #follow_policies! without names" do
      expect(subject).to receive(:follow_policies!)
      subject.follow_policies?
    end

    it "calls #follow_policies! with names" do
      names = %i(foo bar baz)

      expect(subject).to receive(:follow_policies!).with(*names)
      subject.follow_policies?(*names)
    end

    context "wheh #follow_policies! doesn't raise an error" do

      before { allow(subject).to receive(:follow_policies!) { nil } }

      it "returns true" do
        expect(subject.follow_policies?).to eq true
      end

    end # context

    context "wheh #folow_policies! raises ViolationError" do

      let(:error) { Policy::ViolationError.new "invalid" }
      before { allow(subject).to receive(:follow_policies!) { fail error } }

      it "returns false" do
        expect(subject.follow_policies?).to eq false
      end

    end # context

    context "wheh #follow_policies! raises RuntimeError" do

      let(:error) { StandardError.new "invalid" }
      before { allow(subject).to receive(:follow_policies!) { fail error } }

      it "fails" do
        expect { subject.follow_policies? }.to raise_error(error)
      end

    end # context

  end # describe #follow_policies?

  describe "#follow_policy!" do

    before { allow(subject).to receive(:follow_policies!) }

    it "is an alias for #follow_policies!" do
      expect(subject).to receive(:follow_policies!).with :foo
      subject.follow_policy! :foo
    end

    it "requires an argument" do
      expect(subject.method(:follow_policy!).arity).to eq 1
    end

  end # describe #follow_policy!

  describe "#follow_policy?" do

    before { allow(subject).to receive(:follow_policies?) }

    it "is an alias for #follow_policies?" do
      expect(subject).to receive(:follow_policies?).with :foo
      subject.follow_policy? :foo
    end

    it "requires an argument" do
      expect(subject.method(:follow_policy?).arity).to eq 1
    end

  end # describe #follow_policy?

end # describe Policy::Follower
