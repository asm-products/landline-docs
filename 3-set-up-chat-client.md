---
layout: page
title:  "3. Set up your chat client"
---

Now that you've [created an account]({{ site.baseurl }}/1-get-started.html) and [set up your SSO endpoint]({{ site.baseurl }}/2-set-up-sso.html), you're ready to chat.

1. Simply include the following `<iframe>` where you'd like your chat to appear (the example below uses [ERB](http://ruby-doc.org/stdlib-2.2.1/libdoc/erb/rdoc/ERB.html); examples in other templating languages are coming soon):

    ```
    <!-- Minimally, you'll need to tell Landline your team name. -->
    <!-- It's recommended that you also tell Landline which room -->
    <!-- you'd like your users to start in (every team gets a    -->
    <!-- "general" room for free; other rooms can be created if  -->
    <!-- needed). -->

    <iframe width="100%"
            height="100%"
            src="<%= ENV['LANDLINE_HOST'] %>/chat?team=your_team_team&room=<%= your_chat_room_name %>
            style="border: none;">
    </iframe>
    ```
