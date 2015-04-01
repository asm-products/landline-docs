# NB: See all those `ENV["THING"]` lookups? You'll need to make sure
#     that the correct values are available in your `ENV`.

class SingleSignOnController < ApplicationController
  after_filter :set_access_control_headers

  def sso
    return render nothing: true, status: 401 unless sign(params[:payload]) == params[:sig]
    return render nothing: true, status: 401 unless nonce = extract_nonce
    # HEY! LISTEN!
    # You'll need to implement your own user-finding logic
    # If you come up with something clever, let us know!
    return render nothing: true, status: 403 unless current_user = extract_user

    user = Addressable::URI.new
    user.query_values = {
      nonce: nonce,
      team: ENV["LANDLINE_TEAM"],
      id: current_user.id,
      avatar_url: current_user.avatar.url.to_s,
      username: current_user.username,
      email: current_user.email,
      real_name: current_user.name,
      profile_url: user_url(current_user)
    }

    payload = Base64.encode64(user.query)
    sig = sign(payload)
    url = "#{ENV["LANDLINE_URL"]}/sessions/sso?payload=#{URI.escape(payload)}&sig=#{sig}"

    redirect_to url
  end

  private

  def decode_payload
    payload = params[:payload]
    raw = Base64.decode64(payload)
    uri = CGI.parse(raw)
  end

  def extract_nonce
    decode_payload["nonce"][0]
  end

  def extract_user
    # You'll want to implement your own user-extraction
  end

  def sign(payload)
    digest = OpenSSL::Digest.new('sha256')
    OpenSSL::HMAC.hexdigest(digest, ENV["LANDLINE_SECRET"], payload)
  end

  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET, POST, DELETE'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept'
  end
end
