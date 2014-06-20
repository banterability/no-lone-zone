events = require 'events'
sms = require './sms'

class Phone
  constructor: (options = {})->
    @number = "+1" + options.number
    @events = new events.EventEmitter

  trigger: (eventType) ->
    console.log "phone #{@number} receieved", eventType
    @events.emit eventType

  validate: ->
    console.log 'sending validation...'
    sms.send {
      to: @number
      body: 'Respond to this message – really, say anything – to validate your phone. Ready, set... beeeeep:'
    }, (err, sms) ->
      @trigger 'validationRequested' unless err

  afterValidationSent: (cb) ->
    @events.on 'validationRequested', cb

  afterValidated: (cb) ->
    @events.on 'valid', cb

module.exports = Phone
