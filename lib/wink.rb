require 'httparty'

class Wink
  include HTTParty
  base_uri 'winkapi.quirky.com'
  OAUTH_SECRET = 'CHANGE_ME'
  OAUTH_CLIENT_ID = 'CHANGE_ME'

  def initialize(email, password)
    body = {
      password: password,
      username: email,
      grant_type: "password",
      client_secret: OAUTH_SECRET,
      client_id: OAUTH_CLIENT_ID
    }
    response = HTTParty.post('https://winkapi.quirky.com/oauth2/token', body: body.to_json, headers: {'Content-Type' => 'application/json'})
    @access_token = response['data']['access_token']
    @refresh_token = response['data']['refresh_token']
    @token_type = response['data']['token_type']
  end

  def auth_header
    {"Authorization" => "#{@token_type} #{@access_token}"}
  end
  def user
    self.class.get('/users/me', headers: auth_header)['data']
  end
  def devices
    self.class.get('/users/me/wink_devices', headers: auth_header)['data']
  end
  def temperature
    devices.inject({}) do |devices, device|
      devices[device['sensor_pod_id']] = {
          'temperature' => device['last_reading']['temperature'],
          'updated_at' => Time.at(device['last_reading']['temperature_updated_at'])
        }
        devices
    end
  end
end
