loadConfig = require './config'
twilio = require 'twilio'

config = loadConfig 'config.json'

twilioClient = twilio config.twilio.accountSID, config.twilio.authToken

module.exports =
  send: (options, cb) ->
    twilioClient.sendMessage {
      to: options.to
      from: config.twilio.phoneNumber
      body: options.body
    }, cb
