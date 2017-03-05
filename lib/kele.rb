require 'httparty'
require 'json'
require 'roadmap'

class Kele
  include HTTParty
  include Roadmap

  base_uri 'https://www.bloc.io/api/v1'

  def initialize(email, password)
    @email = email
    @password = password

    response = self.class.post(
      '/sessions',
      { query: { email: @email, password: @password } }
    )

    if response["auth_token"].nil?
      raise response["message"]
    else
      @auth_token = response["auth_token"]
    end
  end

  def get_me
    response = self.class.get(
      '/users/me',
      headers: { "authorization" => @auth_token }
    )

    JSON.parse(response.body)
  end

  def get_mentor_availability(id)
    response = self.class.get(
      '/mentors/' + id.to_s + '/student_availability',
      headers: { "authorization" => @auth_token }
    )

    JSON.parse(response.body)
  end

  def get_messages(page = nil)
    response = self.class.get(
      '/message_threads',
      headers: { "authorization" => @auth_token }
    )

    body = JSON.parse(response.body)

    unless page.nil?
      i = (10 * page) - 10
      messages = []
      10.times do
        if body["items"][i]
          messages << body["items"][i]
          i += 1
        else
          break
        end
      end
      messages
    else
      body
    end
  end

  def create_message(recipient_id, message, subject = nil, thread_token = nil)
    response = self.class.post(
      '/messages',
      body: {
        "sender": @email,
        "recipient_id": recipient_id,
        "token": thread_token,
        "subject": subject,
        "stripped-text": message
      },
      headers: { "authorization" => @auth_token }
    )
  end
end
