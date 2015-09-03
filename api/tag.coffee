_ = require 'lodash'
mongoose = require 'mongoose'

auth = (require '../lib/auth') true
config = require '../config'

Tag = mongoose.model 'Tag'

router = do require 'koa-router'


router.get '/', (next)->
    q = Tag.find {}
    docs = yield q.exec()
    @body = docs
    yield next


router.post '/', auth, (next)->
    tag = new Tag @request.body
    doc = yield tag.save()
    @body = doc
    yield next


router.get '/:id', (next)->
    doc = yield Tag.findById @params.id
    if not doc
        @status = 404
        return
    @body = doc
    yield next


router.patch '/:id', auth, (next)->
    doc = yield Tag.findById @params.id
    if not doc
        @status = 404
        return
    _.assign doc, @request.body
    @body = yield doc.save()
    yield next


router.delete '/:id', auth, (next)->
    yield Tag.findByIdAndRemove @params.id
    @status = 204
    yield next


module.exports = router.routes()
