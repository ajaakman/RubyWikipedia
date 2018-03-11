require "#{File.dirname(__FILE__)}/wiki"
require "rack/test"

set :environment, :test

describe 'Wiki app' do
    include Rack::Test::Methods
    def app
      Sinatra::Application 
    end

  it  "should load the home page" do
          get '/'
          expect(last_response).to be_ok
  end
  
  it "should include the phrase 'Hello there!'" do
          get '/'
          expect(last_response.body).to include('App')
  end

  it "should include the title of the About page" do
          get '/about'
          expect(last_response.body).to include('About us')
  end

  it "should use reverse method to correctly reverse user's firstname and lastname" do
          get '/reverse'
          expect(last_response).to be_redirect
          follow_redirect!
          expect(last_response.body).to include($myinfo.reverse)
  end

end

describe User do
    before :each do
        @user = User.new(:username => "testadmin", :password => "testadmin")
    end
    it "should be an instance of User" do
        expect(@user).to be_an_instance_of User
    end
    it "returns the correct username" do
        expect(@user.username).to eql "testadmin"
    end
end

describe "reverse name and surname" do
    it 'should reverse the string you provide' do
        expect(reverse("Course Coordinator")).to eql "rotanidrooC esruoC"
    end
end