path = require 'path'

prod = process.env.NODE_ENV is 'production'

basePath = ->
    '/api'

port = ->
    3000

uploadDir = ->
    '/var/uploaded/enda'

secret = ->
    if not process.env.SECRET
        console.warn 'secret was set dengerous key'
    process.env.SECRET or 'THIS_IS_DENGEROUS_SECRET'


module.exports =
    basePath: basePath()
    port: port()
    uploadDir: uploadDir()
    secret: secret()
    db: 'localhost:27017/a2ms'
