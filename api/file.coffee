path = require 'path'
fs = require 'co-fs'
_ = require 'lodash'
Q = require 'q'
parse = require 'co-busboy'
cp = require 'fs-cp'
destroy = require 'destroy'

auth = (require '../lib/auth') true
config = require '../config'

router = do require 'koa-router'


router.get '/', (next)->
    files = yield fs.readdir config.uploadDir
    @body = files
    yield next


router.post '/', auth, (next)->
    parts = parse this,
        autoFields: true
    while part = yield parts
        filepath = path.join config.uploadDir, part.filename
        yield cp part, filepath

    @status = 204
    yield next

router.delete '/:filename', auth, (next)->
    yield fs.unlink path.join config.uploadDir, @params.filename
    @status = 204
    yield next


router.post '/rename', auth, (next)->
    oldPath = path.join config.uploadDir, @request.body.filename
    newPath = path.join config.uploadDir, @request.body.new_filename
    yield fs.rename oldPath, newPath
    @status = 204
    yield next


module.exports = router.routes()
