express = require 'express'

app = express()

app.use require('body-parser')()
app.use require('morgan')('dev')

app.set 'view engine', 'mustache'
app.set 'layout', 'layout'
app.engine 'mustache', require 'hogan-express'

app.get '/', (req, res) ->
  res.render 'index'

port = process.env.PORT || 5678
app.listen port, ->
  console.log "#{app.get 'env'} server up on #{port}…"
