require "spec_helper"

describe Mezu::Message do
  let!(:message) { create_message(:created_at => 50.days.ago) }
  let!(:private_message) { create_message(:messageable => message, :expires_at => nil,:created_at => 40.days.ago) }
  let!(:expired_message) { create_message(:expires_at => 1.day.ago, :created_at => 30.days.ago)}
  let!(:portuguese_message)  { create_message(:locale => "pt-BR") }
  let(:user) { User.create }

  it { should belong_to(:messageable) }

  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:body) }
  it { should allow_value(:en).for(:locale) }
  it { should_not allow_value(:ja).for(:locale) }

  it "should validate presence of expires_at for global message" do
    Mezu::Message.new.should validate_presence_of(:expires_at)
  end

  it "should not require expires_at for message with recipient" do
    Mezu::Message.new(:messageable => message).should_not validate_presence_of(:expires_at)
  end

  %w(error info warn).each do |valid_value|
    it { should allow_value(valid_value).for(:level)}
  end

  it { should_not allow_value("invalid").for(:level) }

  it "should list all available global messages" do
    Mezu::Message.global.last.should == message
  end

  it "should be global" do
    message.should be_global
    private_message.should_not be_global
  end

  it "should be expired" do
    expired_message.should be_expired
    message.should_not be_expired
    private_message.should_not be_expired
  end

  it "should list only avaliable messages" do
    Mezu::Message.all == [private_message, message, portuguese_message]
  end

  it "should list all messages" do
    Mezu::Message.with_expired.all == [portuguese_message, expired_message, private_message, message]
  end

  it "should list only expired messages" do
    Mezu::Message.expired.all == [expired_message]
  end

  it "should list only portuguese messages" do
    Mezu::Message.by_locale("pt-BR").all.should == [portuguese_message]
  end

  it "should list messages for some element" do
    Mezu::Message.for_messageable(message).should == [private_message]
  end

  it "should return empty for invalid messageable" do
    Mezu::Message.for_messageable(nil).should == []
  end

  context "with pagination" do
    before(:all) do
      silence_warnings { Mezu::Message::PER_PAGE = 2 }
    end

    it "should return list for first page" do
      Mezu::Message.for_page(1).all.should == [portuguese_message, private_message, message]
    end

    it "should return list for second page" do
      Mezu::Message.for_page(2).all.should == [message]
    end

    it "should return list for last page" do
      Mezu::Message.for_page(3).all.should == []
    end
  end
end
