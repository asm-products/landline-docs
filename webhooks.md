---
layout: page
title:  "Webhooks"
---

In your [settings](https://landline.io/settings) (you'll need to be logged in), if you supply a **webhook URL**, Landline will `POST` every message it receives to that URL for further processing. This allows you to do custom things like email uses who are @-mentioned, analyze your chat inputs/frequency, etc.

The request data is a JSON payload that looks like

```javascript
{
  "webhook_type": "message",
  "message": [some message here]
}
```

We're working quickly to support a more flexible webhook implementation, and we'd love to hear your ideas/needs or to review your [pull requests](https://github.com/asm-products/landline-api/pulls).
