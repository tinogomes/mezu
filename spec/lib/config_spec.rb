require "spec_helper"

describe Mezu::Config do
  describe ".available_locales" do
    it "should default to I18n" do
      I18n.stub :available_locales => [:ja]
      subject.available_locales.should == [:ja]
    end

    it "should return set locales" do
      subject.available_locales = [:ja, :en]
      subject.available_locales.should == [:ja, :en]
    end
  end
end
