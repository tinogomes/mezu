require "spec_helper"

describe "Mezu" do
  it "should list all models as default" do
    Mezu.models.should == ["Post", "User"]
  end

  it "should list all models configured by user" do
    Mezu::Config.models = ["Post"]

    Mezu.models.should == ["Post"]
  end
end