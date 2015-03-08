# encoding: utf-8

describe Policy::Follower::Names do

  describe ".from" do

    shared_examples "normalizing from" do |*source|

      subject { described_class.from(*source) }
      it      { is_expected.to eq %i(foo bar baz foo) }

    end # shared examples

    it_behaves_like "normalizing from", %w(foo bar baz foo)
    it_behaves_like "normalizing from", *%w(foo bar baz foo)

  end # describe .from

end # describe Policy::Follower::Names
