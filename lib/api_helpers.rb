require_relative './role_tokens'

module ApiHelpers

  def valid?
    not @access_token.nil? and @access_token.is_a?(String)
  end

  def authenticate
    @access_token = request.env["HTTP_ACCESS_TOKEN"]

    @role = "manager" if RoleTokens::TOKENS[:manager].include?(@access_token)
    @role = "driver" if RoleTokens::TOKENS[:driver].include?(@access_token)

    if not valid? or not @role
      halt 403, { message: "You don't have a valid token. Access forbidden!" }.to_json
    else

    end
  end

  def manager_only_permissions(msg)
    halt 403, { message: "You don't have permissions. #{msg}" }.to_json if @role != "manager"
  end

  def driver_only_permissions(msg)
    halt 403, { message: "You don't have permissions. #{msg}" }.to_json if @role != "driver"
  end

  def json_params
    begin
      JSON.parse(request.body.read)
    rescue
      halt 400, { message: 'Invalid JSON' }.to_json
    end
  end

end