app = require('express')()
server = require('http').Server(app)
io = require('socket.io')(server)
events = require 'events'

app.use require('body-parser')()
app.use require('morgan')('dev')

app.set 'view engine', 'mustache'
app.engine 'mustache', require 'hogan-express'

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
  res.render 'index'

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
