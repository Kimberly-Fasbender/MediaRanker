require "test_helper"

describe UsersController do
  let(:kim) { users(:kim) }
  let(:aj) { useres(:aj) }

  describe "index" do
    it "can get index" do
      get users_path

      must_respond_with :success
    end
  end

  describe "show" do
    it "can show an existing valid user" do
      valid_id = kim.id

      get user_path(valid_id)

      must_respond_with :success
    end

    it "redirects to the root path for an invalid user id" do
      invalid_id = -1

      get user_path(invalid_id)

      must_respond_with :redirect
      must_redirect_to root_path
      expect(flash[:failure]).must_equal "User Not Found."
    end
  end

  describe "login form" do
    it "can get the login form" do
      get login_path

      must_respond_with :success
    end
  end

  describe "login" do
    it "can login an existing user" do
      logged_in_user = perform_login

      expect(flash[:success]).must_equal "Successfully logged in as existing user #{kim.username}!"
      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "can create and login a new user" do
      login_data = {
        user: {
          username: "Brand New User",
        },
      }

      expect {
        post login_path, params: login_data
      }.must_change "User.count", 1

      user = User.find_by(username: login_data[:user][:username])

      expect(flash[:success]).must_equal "Successfully created new user #{user.username} with ID #{user.id}!"
      expect(session[:user_id]).must_equal user.id
      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "responds accordingly when a user can't be logged in" do
      login_data = {
        user: {
          username: "",
        },
      }

      expect {
        post login_path, params: login_data
      }.wont_change "User.count"

      must_respond_with :bad_request
    end
  end

  describe "logout" do
    it "can logout a user" do
      logged_in_user = perform_login

      post logout_path

      expect(session[:user_id]).must_equal nil
      expect(flash[:notice]).must_equal "Succesfully logged out"
      must_redirect_to root_path
    end
  end
end
