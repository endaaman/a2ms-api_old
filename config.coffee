path = require 'path'
crypto = require 'crypto'

prod = process.env.NODE_ENV is 'production'

mongoPath = ->
    host = process.env.MONGO_HOST or 'localhost:27017'
    "mongodb://#{host}/a2ms"

secret = ->
    if prod
        crypto.randomBytes(48).toString 'hex'
    else
        process.env.SECRET or (console.warn 'you are using degerous secret key') or 'DENGEROUS_SECRET'


module.exports =
    prod: prod
    basePath: '/api'
    uploadDir: '/var/uploaded/a2ms'
    port: 3000
    secret: secret()
    db: mongoPath()
