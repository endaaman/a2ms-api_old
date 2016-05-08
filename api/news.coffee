_ = require 'lodash'
mongoose = require 'mongoose'

auth = require '../lib/auth'
config = require '../config'

News = mongoose.model 'News'

router = do require 'koa-router'

router.get '/', (next)->
    opt =
        sort: '-date'

    q = News.find {}, {}, opt
    @body = yield q.exec()
    yield next


router.post '/', auth, (next)->
    news = new News @request.body
    @body = yield news.save()
    yield next


router.patch '/:id', auth, (next)->
    doc = yield News.findById @params.id
    if not doc
        @status = 404
        return
    _.assign doc, @request.body

    @body = yield doc.save()
    yield next


router.delete '/:id', auth, (next)->
    yield News.findByIdAndRemove @params.id
    @status = 204
    yield next


module.exports = router.routes()
