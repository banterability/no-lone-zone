events = require 'events'
express = require 'express'
fs = require 'fs'
http = require 'http'
socketIo = require 'socket.io'
twilio = require 'twilio'

app = express()
server = http.Server(app)
io = socketIo(server)

app.use require('body-parser')()
app.use require('morgan')('dev')
app.use express.static "#{__dirname}/public"

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
    @number = "+1" + options.number
    @events = new events.EventEmitter

  trigger: (eventType) ->
    console.log "phone #{@number} receieved", eventType
    @events.emit eventType

  validate: ->
    # twilioClient.sendMessage({
    #   to: @number
    #   from: "TKTKTK"
    #   body: 'Respond to this message – really, say anything – to validate your phone. Ready, set... beeeeep:'
    # }, (err, sms) =>
    #   console.log 'twilio err', err
    #   console.log 'twilio sms', sms
    #   @trigger 'validationRequested' unless err
    # )
    console.log 'sending validation... (stubbed)'
    err = null
    @trigger 'validationRequested' unless err

  afterValidationSent: (cb) ->
    @events.on 'validationRequested', cb

  afterValidated: (cb) ->
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
    phone.afterValidationSent ->
      socket.emit 'validationSent'

    phone.validate()

    phone.afterValidated ->
      socket.emit 'phoneValid'

port = process.env.PORT || 5678
server.listen port, ->
  console.log "#{app.get 'env'} server up on #{port}…"
