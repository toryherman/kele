class Kele
  include HTTParty
  require 'json'
  base_uri 'https://www.bloc.io/api/v1'

  def initialize(email, password)
    @email = email
    @password = password
    @auth_token = self.class.post(
      '/sessions',
      { query: { email: @email, password: @password } }
    )["auth_token"]
  end

  def get_me
    response = self.class.get(
      '/users/me',
      headers: { "authorization" => @auth_token }
    )

    JSON.parse(response.body)
  end
end
