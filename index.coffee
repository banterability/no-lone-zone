app = require('express')()
server = require('http').Server(app)
io = require('socket.io')(server)
events = require 'events'
fs = require 'fs'

app.use require('body-parser')()
app.use require('morgan')('dev')

class Switchboard
  constructor: ->
    @phones = {}

  addPhone: (number) ->
    phone = new Phone {number}
    @phones[number] = phone
    phone

  route: (phone, eventType) ->
    if target = @phones[phone]
      target.trigger eventType
    else
      console.log 'no such phone'

class Phone
  constructor: (options = {})->
    @number = options.number
    @events = new events.EventEmitter

  trigger: (eventType) ->
    console.log "phone #{@number} receieved", eventType
    @events.emit eventType

  onValidate: (cb) ->
    @events.on 'valid', cb

sb = new Switchboard

# Express
app.get '/', (req, res) ->
  fs.readFile 'index.html', encoding: 'utf-8', (err, data) ->
    return res.send 500 if err
    res.send data

app.post '/sms/callback', (req, res) ->
  number = parseInt(req.body.from, 10)
  sb.route number, 'valid'
  res.send 200

# Socket.IO

io.on 'connection', (socket) ->
  console.log "1) New browser client"
  socket.on 'registerPhone', (data) ->
    phoneNumber = parseInt(data.phone, 10)
    phone = sb.addPhone phoneNumber
    phone.onValidate ->
      socket.emit 'phoneValid'

port = process.env.PORT || 5678
server.listen port, ->
  console.log "#{app.get 'env'} server up on #{port}…"
