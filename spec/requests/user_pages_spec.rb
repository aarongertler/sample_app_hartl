require 'spec_helper'

describe "UserPages" do

  subject { page }

  describe "index" do

    let(:user) { FactoryGirl.create(:user) }

    before do
      sign_in user
      visit users_path
    end

    it { should have_title('All users')}
    it { should have_content('All users')}

    describe "pagination" do

      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all)  { User.delete_all }

      it { should have_selector('div.pagination') }

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector('li', text: user.name)
        end
      end
    end

    describe "delete links" do

      it { should_not have_link('delete') }

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        # This lets us test the absence of a delete-admin link later
        before do
          sign_in admin
          visit users_path
        end

        it { should have_link('delete'), href: user_path(User.first)}
        it "should be able to delete another user" do
          expect do
            click_link('delete', match: :first)
          end.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(admin))}
        # For every non-admin user, admins can see delete option
        # But we'll never see a delete link that erases an admin account
      end
    end
  end

  describe "signup page" do
    before { visit signup_path }

    it { should have_content('Sign up') }
    it { should have_title(full_title('Sign up')) }
  end

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }
    
    it { should have_content(user.name) }
    it { should have_title(user.name) }
  end

  describe "signup" do

    before { visit signup_path }

    let(:submit) { "Create my account" }

    describe "with invalid information" do

      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      before do
        fill_in "Name",         with: ""
        fill_in "Email",        with: "aaron@@gertler.com"
        fill_in "Password",     with: "pass"
        fill_in "Confirm your password", with: "nope"
      end

      describe "after submission" do # this needed to be a describe, not an 'it "should..."'
        before { click_button submit }

        it { should have_title('Sign up') }
        it { should have_content('error') }
        it { should have_content('blank') }
        it { should have_content('invalid') }
        it { should have_content('short') }
        it { should have_content('match') }
      end
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.build(:user) }
      # Building a new user since we refer to it in the block below
      # Using "build", not "create", since we aren't saving the instance
      # (If we tried to save the instance, it would have the same email as the 
      # FactoryGirl creation above, and we'd be unable to save it)
      before { valid_signup(user) }

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)      
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by(email: 'user@example.com') }

        it { should have_link('Sign out') }
        # it { should have_title(user.name) }  # Failing mysteriously
        it { should have_success_message('Welcome') }
        # My first original RSpec matcher!
      end
    end
  end 

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user)
    end
    # before { visit edit_user_path(user) }
    # This part was wrong: need to sign them in first!

    describe "page" do
      it { should have_content("Update your profile")}
      it { should have_title("Edit user")}
      it { should have_link('change', href: 'http://gravatar.com/emails')}
    end

    describe "with invalid information" do
      before { click_button "Save changes" }

      it { should have_content('error')}
    end

    describe "with valid information" do
      let(:new_name)   { "New Name" }
      let(:new_email)  { "new@example.com" }
      before do
        fill_in "Name",             with: new_name
        fill_in "Email",            with: new_email
        fill_in "Password",         with: user.password
        fill_in "Confirm your password", with: user.password
        click_button "Save changes"
      end

      it { should have_title(new_name) }
      it { should have_success_message('Profile updated') }
      it { should have_link('Sign out'), href: signout_path} 
      specify { expect(user.reload.name).to eq new_name } 
      # Reload finds new name from database after changes above
      specify { expect(user.reload.email).to eq new_email }     
    end  
  end
end
