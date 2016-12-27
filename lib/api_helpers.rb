require_relative './role_tokens'

module ApiHelpers

  def valid?
    not @access_token.nil? and @access_token.is_a?(String)
  end

  def authenticate!
    @access_token = request.env["HTTP_ACCESS_TOKEN"]

    @role = "manager" if RoleTokens::TOKENS[:manager].include?(@access_token)
    @role = "driver" if RoleTokens::TOKENS[:driver].include?(@access_token)

    if not valid? or not @role
      halt 403, { message: "You don't have a valid token. Access forbidden!" }.to_json
    else

    end
  end

end