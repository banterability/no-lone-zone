express = require 'express'
fs = require 'fs'
http = require 'http'
socketIo = require 'socket.io'
Switchboard = require './lib/switchboard'

app = express()
server = http.Server app
io = socketIo server

app.use require('body-parser')()
app.use require('morgan')('dev')
app.use express.static "#{__dirname}/public"

sb = new Switchboard

# Express
app.get '/', (req, res) ->
  fs.readFile 'index.html', encoding: 'utf-8', (err, data) ->
    return res.send 500 if err
    res.send data

app.post '/sms/callback', (req, res) ->
  number = parseInt(req.body.From, 10)
  sb.route number, 'valid'
  res.send 200

# Socket.IO

io.on 'connection', (socket) ->
  socket.on 'registerPhone', (data) ->
    phoneNumber = parseInt(data.phone, 10)
    phone = sb.addPhone phoneNumber
    phone.afterValidationSent ->
      socket.emit 'validationSent'

    phone.validate()

    phone.afterValidated ->
      socket.emit 'phoneValid'

port = process.env.PORT || 5678
server.listen port, ->
  console.log "#{app.get 'env'} server up on #{port}…"
