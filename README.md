# Pull Request Notifier

This app notifies one HipChat room when pull requests are updated (for engineers) and notifies another room when pull requests are merged (for everyone else).

Here's the world's most helpful screenshot:

[Imgur](http://i.imgur.com/R0Rj2vJ.png)

[@bhardin](https://github.com/bhardin) pointed out that this functionality [mostly already exists as a Hubot plugin](https://github.com/github/hubot-scripts/blob/master/src/scripts/github-pull-request-notifier.coffee). However, it's a pain to test, and I got it working, and I don't have time to convert things to Hubot plugins right now :)

## Getting Started

    $ npm install
    $ cp env-example .env
    $ npm run dev

## Testing

If testing locally, create a reverse proxy to a public address which GitHub can ping:

    $ ssh example.com -g -R *:9090:localhost:9090

(Note: This probably requires `GatewayPorts yes` in `sshd_config` on your host and possibly a firewall update.)

To get the hook working with pull requests you need to [craft a special request using an API key](https://gist.github.com/bjhess/2726012) -- using the web hooks interface in a project's settings won't work:

    $ curl -H "Authorization: token XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" \
      https://api.github.com/repos/USERNAME/PROJECTNAME/hooks \
      --data '{
        "name": "web",
        "active": true,
        "events": [ "pull_request" ],
        "config": { "url": "http://example.com:9090" }
      }'

Finally, create a dummy project to do the testing.

## Configuration

Environment variables:

* `HIPCHAT_API_KEY`: (required) HipChat API key
* `HIPCHAT_ANNOUNCE_ROOM`: (optional) HipChat room ID that gets merge announcements
* `HIPCHAT_DETAIL_ROOM`: (optional) HipChat room ID that gets open/close/merge announcements and PR URL
* `SECRET_PARAM`: (optional) Append `?secret=<this>` to the webhook URL.
