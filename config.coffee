path = require 'path'

prod = process.env.NODE_ENV is 'production'

secret = ->
    if not process.env.SECRET
        console.warn 'secret was set dengerous key'
    process.env.SECRET or 'THIS_IS_DENGEROUS_SECRET'


module.exports =
    uploadDir: '/var/uploaded/a2ms'
    basePath: '/api'
    port: 3000
    portSeo: 3001
    secret: secret()
    db: 'mongodb://localhost:27017/a2ms'
