# encoding: utf-8

describe Policy::Interface do

  before { Test = Class.new.send :include, described_class }
  after  { Object.send :remove_const, :Test         }

  let(:test_class)  { Test }
  subject { test_class.new }

  it "includes Policy::Validations" do
    expect(test_class).to include Policy::Validations
  end

  describe "#apply" do

    context "when #valid? returns true" do

      before { allow(subject).to receive(:valid?).and_return true }

      it "doesn't raise error" do
        expect { subject.apply }.not_to raise_error
      end
    end

    context "when #valid? returns false" do

      before { allow(subject).to receive(:valid?).and_return false }

      it "raises ViolationError" do
        expect { subject.apply }.to raise_error(Policy::ViolationError)
      end

      it "adds the policy to Exception" do
        expect(Policy::ViolationError).to receive(:new).with(subject).once
        subject.apply rescue nil
      end
    end

  end # describe #apply

  describe "#messages" do

    context "when #errors are present" do

      let(:messages) { %w(foo bar) }
      let(:errors)   { double :errors, messages: { foo: messages } }

      it "extracts a plain array of error messages" do
        allow(subject).to receive(:errors) { errors }
        expect(subject.messages).to eq messages
      end

    end # context

    context "when #errors are absent" do

      it "returns an empty array" do
        expect(subject.messages).to eq []
      end

    end # context

  end # describe #messages

  describe ".apply" do

    let(:attributes) { %i(foo bar) }
    let(:follower)   { double apply: nil }

    it "creates a policy object with the attributes" do
      expect(test_class).to receive(:new).with(attributes) { follower }
      test_class.apply attributes
    end

    it "validates the policy object" do
      expect(test_class).to receive_message_chain :new, :apply
      test_class.apply attributes
    end

  end # describe .apply

end # describe Policy::Inteface
