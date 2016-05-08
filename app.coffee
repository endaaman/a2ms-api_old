path = require 'path'

koa = require 'koa'
logger = require 'koa-logger'
responseTime = require 'koa-response-time'
bodyParser = require 'koa-bodyparser'
json = require 'koa-json'
serve = require 'koa-static'
mongoose = require 'mongoose'

config = require './config'


mongoose.model 'User', require './model/user'
mongoose.model 'Category', require './model/category'
mongoose.model 'Article', require './model/article'
mongoose.model 'News', require './model/news'
mongoose.connect config.db


app = koa()
if not config.prod
    app
    .use logger()

app
.use responseTime()
.use bodyParser()
.use json
    pretty: not config.prod
.use require './lib/user'
.use (next)->
    try
        yield next
    catch e
        if e.code is 11000
            field = e.message.split('.$')[1]
            field = field.split(' dup key')[0]
            field = field.substring 0, field.lastIndexOf('_')
            @status = 422
            @body = {}
            @body[field] =
                message: "Path `#{field}` is required."
                name: 'Duplicated'
                path: field
            return

        if e instanceof mongoose.Error.ValidationError
            @status = 422
            @body = e.errors
            return
        else
            throw e

root = do require 'koa-router'
api = require('koa-router')
    prefix: config.basePath

api.use '/users', require './api/user'
api.use '/session', require './api/session'
api.use '/articles', require './api/article'
api.use '/categories', require './api/category'
api.use '/newss', require './api/news'
api.use '/files', require './api/file'

# serve static files sa stub
if not config.prod
    root.get '/static/*', (next)->
        parts = @path.split '/'
        parts.splice 1, 1
        @path = parts.join '/'
        yield next
    , serve config.uploadDir

root.use api.routes()

app
.use root.routes()
.use root.allowedMethods()
.listen config.port, ->
    console.info "Started a2ms-api server(mode: #{if config.prod then 'prod' else 'dev'})"
