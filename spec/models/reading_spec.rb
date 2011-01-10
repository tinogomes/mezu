require "spec_helper"

describe Mezu::Reading do
  let!(:user) { User.create! }
  let!(:private_message) { create_message(:messageable => user) }
  let!(:global_message) { create_message }

  it { should belong_to(:message) }
  it { should validate_presence_of(:message) }

  context "when reading messages" do
    it "should mark global message as read" do
      global_message.read_by!(user)
      global_message.should be_read_by(user)
    end

    it "should mark private message as read" do
      private_message.read_by!(user)
      private_message.should be_read_by(user)
    end
  end

  context "when listing" do
    let!(:another_user) { User.create! }
    let!(:reading) { global_message.read_by!(user) }
    let!(:another_reading) { global_message.read_by!(another_user) }

    it "should return unread messages" do
      Mezu::Message.list(user).unread_by(user).all.should == [private_message]
      Mezu::Message.list(another_user).unread_by(another_user).should be_empty
    end
  end
end
