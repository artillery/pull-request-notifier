#!/usr/bin/env coffee
#
# Copyright 2013 Artillery Games, Inc.
# Licensed under the MIT license.
#
# Useful links:
# http://developer.github.com/v3/repos/hooks/
# https://www.hipchat.com/docs/api/method/rooms/message

express = require 'express'
https = require 'https'
http = require 'http'
querystring = require 'querystring'

port = process.env.PORT or 9090

app = express()
app.set 'port', port
app.use express.logger('dev')
app.use express.bodyParser()
app.use app.router

if not process.env.HIPCHAT_API_KEY
  console.error "Missing HIPCHAT_API_KEY env var"
  process.exit 1

sendHipChatMessage = (roomID, text) ->
  qs = querystring.stringify
    auth_token: process.env.HIPCHAT_API_KEY
    room_id: roomID
    from: 'GitHub'
    message: text
    message_format: 'text'
    notify: 1
    color: 'yellow'
  path = "/v1/rooms/message?#{ qs }"

  req = https.get { host: 'api.hipchat.com', path: path }, (res) ->
    console.log "Sent '#{ text }' to room #{ roomID }, HTTP code #{ res.statusCode }"
    console.log "Path was: #{ path }"

  req.on 'error', (err) ->
    console.log "Unable to send to room #{ roomID }: #{ err }"

  req.end()

app.get '/', (req, res) ->
  res.redirect 'https://github.com/artillery/pull-request-notifier'

app.post '/', (req, res) ->
  secret = process.env.SECRET_PARAM
  if secret and req.param('secret') != secret
    return res.send 400, 'Bad secret'

  if req.headers['x-github-event'] != 'pull_request'
    return res.send 400, 'Not a pull request'

  payload = JSON.parse req.body.payload
  number = payload.number
  person = payload.pull_request.user.login
  action = payload.action
  title = payload.pull_request.title
  url = payload.pull_request.html_url
  isMerged = payload.pull_request.merged

  if action is 'synchronized'
    return res.send 200, 'ignored'

  roomID = process.env.HIPCHAT_DETAIL_ROOM
  if roomID
    message = "PR #{ number } #{ action }: #{ title } (#{ person }) - #{ url }"
    sendHipChatMessage roomID, message

  roomID = process.env.HIPCHAT_ANNOUNCE_ROOM
  if roomID and isMerged
    message = "Pull request by #{ person } merged: #{ title }"
    sendHipChatMessage roomID, message

  res.send 200, 'ok'

http.createServer(app).listen port, ->
  console.log "Pull Request Notifier listening on http://localhost:#{ port }"
