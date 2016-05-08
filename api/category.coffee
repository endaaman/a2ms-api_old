_ = require 'lodash'
mongoose = require 'mongoose'

auth = require '../lib/auth'

ObjectId = mongoose.Types.ObjectId
Category = mongoose.model 'Category'
Article = mongoose.model 'Article'

router = do require 'koa-router'

router.get '/', (next)->
    @body = yield Category.find {}, {}, sort: '-order _id'
    yield next


router.post '/', auth, (next)->
    article = new Category @request.body
    @body = yield article.save()
    yield next


router.patch '/:id', auth, (next)->
    doc = yield Category.findById @params.id
    if not doc
        @status = 404
        return
    _.assign doc, @request.body

    @body = yield doc.save()
    yield next

router.delete '/:id', auth, (next)->
    yield Article.update
        category: new ObjectId @params.id
    ,
        $set:
            category: null
    yield Category.findByIdAndRemove @params.id
    @status = 204
    yield next


module.exports = router.routes()
