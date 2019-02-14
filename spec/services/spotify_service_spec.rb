require 'rails_helper'

describe SpotifyService do
  context "can make calls" do
    it "can access basic account info" do
      info = {username: "12184696969", 
              image_url: "https://bit.ly/2tlLmZc", 
              spotify_token: ENV["S_TEST_TOKEN"], 
              profile_url: "https://open.spotify.com/user/12184696969"}

      current_user = User.create(info)
      response = SpotifyService.user_data(current_user)
      
      expect(response[:email]).to be_truthy 
    end
  end
end
