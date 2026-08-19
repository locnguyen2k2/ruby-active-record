# spec/requests/cors_spec.rb
require 'rails_helper'

RSpec.describe 'CORS Middleware', type: :request do
  describe 'OPTIONS /users' do
    it 'allows cross-origin requests from configured origin' do
      process :options, '/users', headers: {
        'Origin' => 'http://localhost:3000',
        'Access-Control-Request-Method' => 'POST'

      }

      expect(response.headers['Access-Control-Allow-Origin']).to eq('http://localhost:3000')
      expect(response.headers['Access-Control-Allow-Methods']).to include('POST')
      expect(response.status).to eq(200)
    end

    it 'blocks disallowed HTTP methods' do
      process :options, '/users', headers: {
        'Origin' => 'http://localhost:3000',
        'Access-Control-Request-Method' => 'GET'
      }

      puts "Headers: ", response.headers
      expect(response.headers['Access-Control-Allow-Methods']).to eq(nil)
    end
  end
end
