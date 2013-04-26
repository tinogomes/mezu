require "spec_helper"

describe Mezu::MessagesController do
  let(:expired_date) { (Date.today + 1).strftime("%Y-%m-%d")   }
  let!(:message) { create_message }
  let!(:expired_message) { create_message(:expires_at => 1.day.ago) }
  let(:blog_post) { Post.create(:title => "title") }

  context "GET :index" do
    it "should be success" do
      get :index

      response.should be_success
      assigns(:messages).should == [expired_message, message]
    end
  end

  context "GET :new" do
    it "should be success" do
      get :new

      response.should be_success
      response.should render_template("new")

      assigns(:message).should be_new_record
      assigns(:app_models).should == ["Post", "User"]
    end
  end

  context "POST :create" do
    it "should be success for global message" do
      expect {
        post :create, :message => {:title => "title", :body => "body", :expires_at => expired_date, :level => "info", :locale => "en"}
      }.to change(Mezu::Message, :count).by(1)

      flash[:notice].should == I18n.t("mezu.flash.created_successful")
      response.should redirect_to(mezu_messages_path)
    end

    it "should be success for private message" do
      expect {
        post :create, :message => {:title => "title", :body => "body", :level => "info", :messageable_type => "Post", :messageable_id => blog_post, :locale => "en"}
      }.to change(Mezu::Message, :count).by(1)

      flash[:notice].should == I18n.t("mezu.flash.created_successful")
      response.should redirect_to(mezu_messages_path)
    end

    it "should render new when something goes wrong" do
      post :create

      response.should be_success
      response.should render_template("new")

      message = assigns(:message)
      message.should_not be_valid
      message.should be_new_record
    end
  end

  context "GET :edit" do
    it "should be success" do
      get :edit, :id => message

      response.should be_success
      response.should render_template("edit")

      assigns(:message).should == message
    end

    it "should redirect to index for invalid message id" do
      get :edit, :id => 0

      response.should redirect_to(mezu_root_path)
      flash[:error].should == I18n.t("mezu.flash.record_not_found")
    end
  end

  context "PUT :update" do
    it "should be success" do
      put :update, :id => message, :message => {:title => "New title"}

      flash[:notice].should == I18n.t("mezu.flash.updated_successful")
      response.should redirect_to(mezu_messages_path)
    end

    it "should render edit when something goes wrong" do
      put :update, :id => message, :message => {:title => ""}

      response.should be_success
      response.should render_template("edit")
    end
  end

  context "GET :remove" do
    it "should be success" do
      get :remove, :id => message

      response.should be_success
      response.should render_template("remove")
    end
  end

  context "DELETE :destroy" do
    it "should be success" do
      expect{
        delete :destroy, :id => message
      }.to change(Mezu::Message, :count).by(-1)

      flash[:notice].should == I18n.t("mezu.flash.deleted_successful")
      response.should redirect_to(mezu_messages_path)
    end
  end
end
