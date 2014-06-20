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
    #   from: config.twilio.phoneNumber
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

module.exports = Phone
