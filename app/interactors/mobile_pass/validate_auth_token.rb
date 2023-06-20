module MobilePass
  class ValidateAuthToken
    include Interactor

    delegate :auth_token, to: :context

    def call
      context.agent = fetch_agent
    end

    private

    def fetch_agent
      agent_id = payload['agent_id']
      context.fail!(code: :invalid_token, message: "Invalid token - agent_id is missing") if agent_id.blank?

      agent = Agent.find_by(id: agent_id)
      context.fail!(code: :invalid_token, message: "Invalid token - no agent exists with agent_id") if agent.blank?

      agent
    end

    def payload
      JWT.decode(auth_token,
                 MobilePass.auth_token_secret,
                 MobilePass.auth_token_algorithm).first
    rescue JWT::ExpiredSignature
      context.fail!(code: :expired_token, message: "The token has expired")
    rescue StandardError => e
      context.fail!(code: :token_error, message: e.message)
    end
  end
end
