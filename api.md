---
layout: page
title:  "API"
---

<a name="teams"></a>
### Teams

- Create

    You can create an account directly on [landline.io](https://landline.io),
    or you can `POST` your details to the `/teams` endpoint:

    ```
    curl https://api.landline.io/teams \
         -X POST \
         -H "content-type: application/json" \
         -H "accept: application/json" \
         -d '{ \
            "email": "email@email.com", \
            "password": "password", \
            "secret": "single sign-on secret", \
            "url": "single sign-on url", \
            "name": "team name", \
            "webhook_url": "optional url for receiving webhooks" \
          }'
    ```

    A successful response will be a JSON-encoded hash containing a [JSON Web Toke](http://jwt.io/) and its expiration:

    ```
    HTTP/1.1 200
    Content-Type: application/json

    { "token": [your JWT], "expiration": [your JWT's expiration in Unix time] }
    ```

- Read

    You can then get information about your team by hitting its endpoint:

    ```
    curl https://api.landline.io/teams/:team_name \
         -H "accept: application/json" \
         -H "authorization: [your JWT from above]"
    ```

    A successful response will be JSON-encoded hash containing everything but your password:

    ```
    HTTP/1.1 200
    Content-Type: application/json

    {
  		"email":       "email",
  		"url":         "url",
  		"name":        "name",
  		"secret":      "shared secret",
  		"webhook_url": "webhook url",
  	}
    ```

- Login

    If your JWT has expired, you can generate a new one by logging in:

    ```
    curl https://api.landline.io/teams/:team_name \
         -X POST \
         -H "accept: application/json" \
         -H "content-type: application/json" \
         -d '{ "password": [your password] }'
    ```

    A successful response will contain a new JWT, its expiration, and your team's name:

    ```
    HTTP/1.1 200
    Content-Type: application/json

    {
      "token":      [your JWT],
      "expiration": [your JWT's expiration in Unix time],
      "name":       [your team name]
    }
    ```
