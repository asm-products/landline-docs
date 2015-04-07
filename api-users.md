---
layout: "page"
title: "API - Users"
---

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
