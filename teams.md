---
layout: "page"
title: "Teams"
---

- [create](#teams-create)
- [show](#teams-show)
- [login](#teams-login)
- [update](#teams-update)
- [authentication](#teams-authentication)

<a name="teams-create"></a>
#### Create

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

A successful response will be a JSON-encoded dict containing a [JSON Web Token](http://jwt.io/) and its expiration:

```
HTTP/1.1 201
Content-Type: application/json

{ "token": [your JWT], "expiration": [your JWT's expiration in Unix time] }
```



<a name="teams-show"></a>
#### Show

You can then get information about your team by hitting its endpoint:

```
curl https://api.landline.io/teams/:team_name \
     -H "accept: application/json" \
     -H "authorization: Bearer [your JWT from above]"
```

A successful response will be JSON-encoded dict containing everything but your password:

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



<a name="teams-login"></a>
#### Login

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



<a name="teams-update"></a>
#### Update

You can update you team's email, shared secret, single sign-on URL, webhook URL, and name. In accordance with the [W3 spec](http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html), you **must** pass the entire representation of your team in the request body; you can, of course, modify any part of it.

```
curl https://api.landline.io/teams/:team_name \
     -X PUT \
     -H "accept: application/json" \
     -H "content-type: application/json" \
     -H "authorization: Bearer [your JWT]"
     -d '{ \
       "email": "email@email.com", \
       "secret": "single sign-on secret", \
       "url": "single sign-on url", \
       "name": "team name", \
       "webhook_url": "optional url for receiving webhooks" \
      }'
```

A successful response will be a JSON-encoded dict of your team (omitting the password):

```
HTTP/1.1 200
Content-Type: application/json

{
  "email": "email@email.com", \
  "secret": "single sign-on secret", \
  "url": "single sign-on url", \
  "name": "team name", \
  "webhook_url": "optional url for receiving webhooks" \
}
```


<a name="teams-authentication"></a>
#### Authenticating as a team

As mentioned above, you'll generally want to use the JWT that Landline provides. However, Landline also allows you to make server-to-server calls using your shared secret. The shared secret acts as a private key that you control; it's essential that you keep it secure and that you change it if you suspect it's been compromised.

Instead of using the Bearer Authorization scheme as you would with the JWT, shared secret-based authentication uses HTTP Basic Authentication; an update request would look like

```
curl https://api.landline.io/teams/:team_name \
     -X PUT \
     -H "accept: application/json" \
     -H "content-type: application/json" \
     # NB: The colon is significant
     -u [your shared secret]: \
     -d '{ \
       "email": "email@email.com", \
       "secret": "single sign-on secret", \
       "url": "single sign-on url", \
       "name": "team name", \
       "webhook_url": "optional url for receiving webhooks" \
      }'
```

And that's it. Obviously if you're not using `curl` you'll want to set the header in your language of choice, but you get the idea.
