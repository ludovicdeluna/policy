# encoding: utf-8

describe Policy::Validations do

  let(:validations) { ActiveModel::Validations }
  let(:methods)     { validations.public_instance_methods }
  let(:test_class)  { Class.new.include described_class }

  it "includes ActiveModel::Validatons" do
    expect(test_class).to include validations
  end

end
