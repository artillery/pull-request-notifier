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

port = process.env.PORT or 8000

requireEnv = (name) ->
  value = process.env[name]
  if not value?
    console.error "Need to specify #{ name } env var"
    process.exit(1)
  return value

app = express()
app.set 'port', port
app.use express.logger('dev')
app.use express.json()
app.use app.router




http.createServer(app).listen port, ->
  console.log "Pull Request Notifier listening on http://localhost:#{ port }"
