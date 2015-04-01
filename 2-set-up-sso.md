---
layout: page
title:  "2. Set up SSO"
---

You're almost ready to chat. This is the trickiest part, but then you'll be home free.

1. Set up your routes.

    Remember how you had to give us a **single sign-on URL**? Here's its chance to shine. If you're using Ruby on Rails, for example, you'll want to add the following line like the following to your `config/routes.rb`:

    ```ruby
      # You'll want to point to your controller and
      # action on the right-hand side of the hash.
      # (You can use SingleSignOnController#sso if
      # you'd like. Really, we won't mind.

      get '/sso' => 'single_sign_on#sso'
    ```

2. Set up your controller.

    Here's an [example controller](examples/single_sign_on_controller.rb), which you're free to use &mdash; you'll just need to be sure to serialize `current_user` correctly after the redirects. (At Assembly, we pass around a unique token; Landline will wrap up any query params and send them back to your server securely in the redirect (you *are* using SSL, right?), so you can stash whatever you want up there.)

    Using something other than Rails? We're working on more examples, and we'd love [pull requests](https://github.com/asm-products/landline-docs).

3. What are you waiting for? [Set up your chat client](3-set-up-chat-client.html)!
