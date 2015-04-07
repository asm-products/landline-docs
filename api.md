---
layout: page
title:  "API"
---

- [Teams](#teams)
  - [create](#teams-create)
  - [show](#teams-show)
  - [login](#teams-login)
  - [update](#teams-update)
  - [authentication](#teams-authentication)
- [Users](#users)
- [Rooms](#rooms)
  - [create](#rooms-create)
  - [list all](#rooms-team-list)
  - [update](#rooms-update)
  - [list for user](#rooms-list)
  - [show for user](#rooms-show)

<a name="teams"></a>
### Teams

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


<a name="users"></a>
### Users

<a name="users-create"></a>
#### Create

Creating users happens as part of the single sign-on flow. After validating the signature that Landline has sent your server, you can wrap up the current user in the `payload` that your server sends as a response.

Required fields:
- email
- external_id (the user's ID in your service; used for deep integrations with your app)
- username

Optional fields:
- avatar_url
- profile_url
- real_name

Simply add the fields that you're using to the base 64-encoded `payload` as query string parameters &mdash; in pseudocode:

```
Base64.encode("nonce=#{nonce}&email=#{user.email}&external_id=#{user.id}&username=#{user.username}")
```

See [Building a Simple Site with Landline]({{ site.baseurl }}/simple-landline-site.html) for a more detailed overview of the SSO request/response cycle.


<a name="rooms"></a>
### Rooms

The endpoint for administrative (team-level) tasks relating to `rooms` is (memorably enough), `/teams/:team_name/rooms[/:room]`. Use this endpoint for creating, updating, and deleting rooms.

<a name="rooms-create"></a>
#### Create

Every room has a slug, a name (which defaults to the slug), and a topic. To create a room, simply `POST` these data to the `/teams/:team_name/rooms` endpoint:

```
curl https://api.landline.io/teams/:team_name/rooms \
     -X POST \
     -H "accept: application/json" \
     -H "content-type: application/json" \
     -u [your shared secret]: \
     -d '{ \
       "slug": "the room's slug", \
       "name": "the room's name", \
       "topic": "the room's topic" \
      }'
```

A successful response will contain a JSON-encoded dict of the room that's been created:

```
HTTP/1.1 201

Content-Type: application/json
'{
  "slug": "the room's slug",
  "name": "the room's name",
  "topic": "the room's topic"
}'
```

<a name="rooms-team-list"></a>
#### List

You can list all of the rooms created for your team:

```
curl https://api.landline.io/teams/:team_name/rooms \
     -H "accept: application/json" \
     -u [your shared secret]:
```

A successful response will contain a JSON-encoded dict of an array of rooms, which are in turn dicts of the form `{id, name, slug, topic}`:

```
HTTP/1.1 201

Content-Type: application/json
'{
  "rooms": rooms[]
}'
```


<a name="rooms-update"></a>
#### Update

Updating a room is much like creating one, except you specify the target room in the request (because you know it ahead of time), and issue a `PUT` request instead of a `POST`:


```
curl https://api.landline.io/teams/:team_name/rooms/:room_slug \
     -X POST \
     -H "accept: application/json" \
     -H "content-type: application/json" \
     # NB: The colon is significant
     -u [your shared secret]: \
     -d '{ \
       "slug": "the room's slug", \
       "name": "the room's name", \
       "topic": "the room's topic" \
      }'
```

A successful response will contain a JSON-encoded dict of the room that's been created:

```
HTTP/1.1 200

Content-Type: application/json
{
  "slug": "the room's slug",
  "name": "the room's name",
  "topic": "the room's topic"
}
```


User-related room actions (showing a particular room, listing rooms with subscriptions) are scoped to `/rooms`.

<a name="rooms-list"></a>
#### List

When a user requests a list of rooms, it's assumed that s/he also wants information about his/her room memberships and the initial unread state of the rooms.

```
curl https://api.landline.io/teams/:team_name/rooms \
     -H "accept: application/json" \
     -H "authorization: Bearer [user's JWT]"
```

A successful response will contain a JSON-encoded dict of rooms, memberships, and unread rooms, where `rooms` contains `{id, name, slug, topic}`, and `memberships` and `unread_rooms` are lists of room IDs:

```
HTTP/1.1 200

Content-Type: application/json
{
	"rooms":        rooms[],
	"memberships":  memberships[],
	"unread_rooms": unread[],
}
```

<a name="rooms-show"></a>
#### Show

Requesting a specific room will return the room object, along with its [Readraptor](https://github.com/asm-products/readraptor) pixel, which can be loaded in an `<img>` tag to mark the room as read.

```
curl https://api.landline.io/teams/:team_name/rooms/:room_slug \
     -H "accept: application/json" \
     -H "authorization: Bearer [user's JWT]"
```

And a successful response:

```
HTTP/1.1 200

Content-Type: application/json

{
  "room": room{},
  "pixel": pixel
}
```
