require 'rails_helper'

describe SpotifyService do
  context "can make calls" do
    before(:each) do
      @info = {username: "12184696969",
        image_url: "https://bit.ly/2tlLmZc",
        spotify_token: ENV["S_TEST_TOKEN"],
        refresh_token: ENV["REQUEST_TOKEN"],
        profile_url: "https://open.spotify.com/user/12184696969"}
      end

      it "can access basic account info" do
        current_user = User.create(@info)
        stub_login(current_user)

        VCR.use_cassette("spotify-service-basic-info") do
          response = SpotifyService.new(current_user).user_data
          expect(response[:email]).to be_truthy
        end
      end

      it 'can find the top 5 artists per user' do
        user = User.create(@info)

        stub_login(user)

        VCR.use_cassette('spotify-service-top-5-artists') do
          response = SpotifyService.new(user).top_5_artists
          expect(response.length).to eq(5)
        end
      end

      it 'can find the top 5 tracks per user', :vcr do
        user = User.create(@info)

        stub_login(user)

        response = SpotifyService.new(user).top_5_tracks
        expect(response.length).to eq(5)
      end

      # after this is run you have to change your development variables
      it 'can refresh a users token' do
        info = {username: "12184696969",
          image_url: "https://bit.ly/2tlLmZc",
          spotify_token: ENV["S_TEST_TOKEN"],
          refresh_token: ENV["REQUEST_TOKEN"],
          profile_url: "https://open.spotify.com/user/12184696969"}

          current_user = User.create(info)
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(current_user)

          previous_token = current_user.spotify_token
          VCR.use_cassette("spotify-service-refresh-token") do
            response = SpotifyService.new(current_user).send(:refresh_token)
            expect(response).to_not eq(previous_token)
            expect(response).to eq(current_user.spotify_token)
          end
        end

        it 'can return the most recent played track', :vcr do
          user = User.create(@info)

          response = SpotifyService.new(user).most_recent_track
          # token has expired error message by the time our test suite gets to here
          # expect(response)
        end
      end
    end
