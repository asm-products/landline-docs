---
layout: "page"
title: "API - Rooms"
---

- [create](#rooms-create)
- [list all](#rooms-team-list)
- [update](#rooms-update)
- [list for user](#rooms-list)
- [show for user](#rooms-show)

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
