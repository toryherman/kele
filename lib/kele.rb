require 'httparty'
require 'json'
require 'roadmap'

class Kele
  include HTTParty
  include Roadmap

  base_uri 'https://www.bloc.io/api/v1'

  def initialize(email, password)
    @email = email

    response = self.class.post(
      '/sessions',
      body: { email: @email, password: password }
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
    if page.nil?
      response = self.class.get(
        '/message_threads',
        headers: { "authorization" => @auth_token },
      )
    else
      response = self.class.get(
        '/message_threads',
        body: { "page": page },
        headers: { "authorization" => @auth_token }
      )
    end

    JSON.parse(response.body)
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

  def create_submission(checkpoint_id, assignment_branch = nil, assignment_commit_link = nil, comment = nil)
    response = self.class.post(
      '/checkpoint_submissions',
      body: {
        "assignment_branch": assignment_branch,
        "assignment_commit_link": assignment_commit_link,
        "checkpoint_id": checkpoint_id,
        "comment": comment,
        "enrollment_id": self.get_me["id"]
      },
      headers: { "authorization" => @auth_token }
    )
  end
end
