koa = require 'koa'

cors = require 'koa-cors'
logger = require 'koa-logger'
responseTime = require 'koa-response-time'
bodyParser = require 'koa-bodyparser'
json = require 'koa-json'

config = require './config'

app = koa()
app
.use logger()
.use responseTime()
.use bodyParser()
# .use json
#     pretty: not config.prod

router = require('koa-router')
    prefix: config.basePath

router.use '/users', require './api/user'
router.use '/session', require './api/session'
router.use '/articles', require './api/article'

# router.post '*', (next)->
#     @body = @request.body
#     yield next

app
.use router.routes()
.use router.allowedMethods()


app.listen config.port
