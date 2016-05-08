path = require 'path'
fs = require 'co-fs'
_ = require 'lodash'
Q = require 'q'
parse = require 'co-busboy'
cp = require 'fs-cp'
destroy = require 'destroy'

auth = require '../lib/auth'
config = require '../config'

router = do require 'koa-router'


readStats = (filenames)->
    results = []
    for filename in filenames
        if /^\./.test filename
            continue
        stat = yield fs.stat path.join config.uploadDir, filename
        if stat.isFile()
            results.push
                name: filename
                size: stat.size
                atime: stat.atime
                ctime: stat.ctime
                mtime: stat.mtime

    results


router.get '/', auth, (next)->
    filenames = yield fs.readdir config.uploadDir
    files = yield readStats filenames
    @body = yield readStats filenames

    yield next


router.post '/', auth, (next)->
    parts = parse this,
        autoFields: true
    filenames = []
    while part = yield parts
        # NOTE: transform filename to lower case
        filename = part.filename.toLowerCase()
        filenames.push filename
        yield cp part, path.join config.uploadDir, filename

    @body = yield readStats filenames
    yield next

router.delete '/:filename', auth, (next)->
    yield fs.unlink path.join config.uploadDir, @params.filename
    @status = 204
    yield next


router.post '/rename', auth, (next)->
    # NOTE: transform to lower case
    newName = @request.body.newName.toLowerCase()
    oldPath = path.join config.uploadDir, @request.body.oldName
    newPath = path.join config.uploadDir, newName
    yield fs.rename oldPath, newPath

    @body = (yield readStats [newName])[0]
    yield next


module.exports = router.routes()
