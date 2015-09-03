_ = require 'lodash'
mongoose = require 'mongoose'

auth = (require '../lib/auth') true
config = require '../config'

Category = mongoose.model 'Category'
router = do require 'koa-router'


router.get '/', (next)->
    q = Category.find {}
    docs = yield q.exec()
    @body = docs
    yield next


router.post '/', auth, (next)->
    cat = new Category @request.body
    try
        @body = yield cat.save()
        @status = 201
    catch err
        @body = err
        @status = 422

    yield next


router.get '/:id', (next)->
    doc = yield Category.findById @params.id
    if not doc
        @status = 404
        return
    @body = doc
    yield next


router.patch '/:id', auth, (next)->
    doc = yield Category.findById @params.id
    if not doc
        @status = 404
        return
    _.assign doc, @request.body
    try
        @body = yield doc.save()
        @status = 200
    catch err
        @body = err
        @status = 422
    yield next


router.delete '/:id', auth, (next)->
    yield Category.findByIdAndRemove @params.id
    @status = 204
    yield next

module.exports = router.routes()
