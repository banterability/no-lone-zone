Phone = require './phone'

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

module.exports = Switchboard
