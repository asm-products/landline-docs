---
layout: "page"
title: "Landline Single Sign-On"
---

Landline's single sign-on flow has borrowed heavily from [Discourse's implementation](https://meta.discourse.org/t/official-single-sign-on-for-discourse/13045), but we're a bit more opinionated about the contents of the `payload` hash. Let's quickly walk through the flow.

(Note: This walkthrough assumes you've already set up an account and shared secret on [landline.io](https://landline.io).)

1. https://api.landline.io/sessions/new?team=${your_team_slug}

    To initialize a new session, make a call to `https://api.landline.io/sessions/new?team=${your_team_slug}`. You can include additional query string parameters if you'd like; Landline will ignore them and pass them in its `payload` to your server. Note that a `room` parameter is viewed as significant by the Landline web client: it will initialize Landline chat, once your user has logged in, in the given room.

    Landline will respond with a `302 Found` redirect (provided your team exists) to your server's single sign-on endpoint. This redirect will contain a `payload` and a `sig` as query string parameters (in addition to the parameters that you provided).

    The `payload` is a Base64-encoded string containing a `nonce` and whatever parameters you provided in the initial call.

    The `nonce` is simply a string used to validate your server's response. It's valid for 10 minutes.

    The `sig` is a hex-encoded SHA256 HMAC of the `payload` signed with your shared secret.

2. Your single sign-on endpoint

    When your server receives the single sign-on request, you should first validate your version of the signed payload matches the provided signature &mdash; this prevents unauthorized access to your endpoint. In Ruby on Rails, you might implement a function like:

    ```ruby
    def sso
      return render nothing: true, status: 401 unless sign(params[:payload]) == params[:sig]

      ...
    end

    def sign(payload)
      digest = OpenSSL::Digest.new('sha256')
      OpenSSL::HMAC.hexdigest(digest, "YOUR_LANDLINE_SECRET", payload)
    end
    ```

    Next, you need to pull out the nonce. First, decode the payload into a hash of its params:

    ```ruby
    decoded_payload = Base64.decode64(params[:payload])
    payload_params = CGI.parse(decoded_payload)
    ```

    Then grab the nonce:

    ```
    nonce = payload_params["nonce"][0]
    ```

    You'll also need to find a way to determine the current user. You might do this with fancy header logic (keep in mind that the redirects restrict your options here) or by generating a token for the current user when the request cycle kicks off and including it in the query string params in step 1 (above).

    Once you've got your user, you'll want to create a new `payload` with the nonce and your user's data:

    ```ruby
    # `extract_user` is a placeholder for your implementation
    current_user = extract_user
    payload_user = Addressable::URI.new
    payload_user.query_values = {
      nonce: nonce,
      team: "YOUR LANDLINE TEAM'S SLUG",
      id: current_user.id,
      avatar_url: current_user.avatar.url.to_s,
      username: current_user.username,
      email: current_user.email,
      real_name: current_user.name,
      # using a Rails url-helper; do what works best for you
      profile_url: user_url(current_user)
    }

    # Base64-encode the user query params
    payload = Base64.encode64(user.query)

    # You can use the same `sign` method implemented above
    sig = sign(payload)
    ```

    Then put together your redirect URL:

    ```ruby
    url = "https://api.landline.io/sessions/sso?payload=#{URI.escape(payload)}&sig=#{sig}"
    ```

    And issue another `302` redirect:

    ```ruby
    redirect_to url
    ```

3. https://api.landline.io/sessions/sso?payload=#{URI.escape(payload)}&sig=#{sig}"

    At this point, Landline logs in your user (creating a new user record if necessary), and responds with a [JSON Web Token](http://jwt.io/) and its expiration:

    ```
    HTTP/1.1 200
    Content-Type: application/json

    {"token": token, "expiration": "expiration"}
    ```

    And your user is ready to chat.
