mongoose = require 'mongoose'

koa = require 'koa'

cors = require 'koa-cors'
logger = require 'koa-logger'
responseTime = require 'koa-response-time'
bodyParser = require 'koa-bodyparser'
json = require 'koa-json'

config = require './config'


mongoose.model 'User', require './model/user'
mongoose.model 'Tag', require './model/tag'
mongoose.model 'Category', require './model/category'
mongoose.model 'Article', require './model/article'
mongoose.connect config.db



app = koa()
app
.use logger()
.use responseTime()
.use bodyParser()
.use json
    pretty: not config.prod

api = require('koa-router')
    prefix: config.basePath

api.use '/users', require './api/user'
api.use '/session', require './api/session'
api.use '/articles', require './api/article'
api.use '/tags', require './api/tag'
api.use '/categories', require './api/category'
api.use '/files', require './api/file'

# API server
app
.use api.routes()
.use api.allowedMethods()
.listen config.port

# SEO server
http  = require 'http'
spaseo = require 'spaseo.js'
http.createServer spaseo
    verbose: not config.prod
.listen config.portSeo
