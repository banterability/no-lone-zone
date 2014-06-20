fs = require 'fs'

module.exports = (filename) ->
  JSON.parse fs.readFileSync filename, encoding: 'utf-8'
