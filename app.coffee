#!/usr/bin/env coffee
#
# Copyright 2013 Artillery Games, Inc.
# Licensed under the MIT license.
#
# Useful links:
# http://developer.github.com/v3/repos/hooks/
# https://www.hipchat.com/docs/api/method/rooms/message

express = require 'express'
request = require 'request'
http = require 'http'

port = process.env.PORT or 9090

requireEnv = (name) ->
  value = process.env[name]
  if not value?
    console.error "Need to specify #{ name } env var"
    process.exit(1)
  return value

app = express()
app.set 'port', port
app.use express.logger('dev')
app.use express.bodyParser()
app.use app.router

app.get '/', (req, res) ->
  res.redirect 'https://github.com/artillery/pull-request-notifier'

app.post '/', (req, res) ->
  #if req.param('secret') != requireEnv.SECRET_PARAM
  #  return res.send 400, 'bad secret'

  if req.headers['x-github-event'] != 'pull_request'
    return res.send 400, 'not a pull request'

  payload = JSON.parse req.body.payload

  #spawn = require('child_process').spawn
  #pbcopy = spawn 'pbcopy'
  #pbcopy.stdin.write JSON.stringify payload, null, '  '
  #pbcopy.stdin.end()

  {action, number} = payload
  title = payload.pull_request.title
  person = payload.sender.login
  repo = payload.repository.full_name
  url = payload.pull_request.html_url

  message = """
    #{ person } #{ action } a pull request: #{ title } ( #{ url } )
  """
  console.log message

  res.send 200

http.createServer(app).listen port, '0.0.0.0', ->
  console.log "Pull Request Notifier listening on http://localhost:#{ port }"
