_ = require 'lodash'
mongoose = require 'mongoose'

auth = (require '../lib/auth') true
user = (require '../lib/auth') false
config = require '../config'

Article = mongoose.model 'Article'

router = do require 'koa-router'

router.get '/', user, (next)->
    query = {}
    if @query.tag
        query.tags = @query.tag

    if not @user?.approved
        query.draft = false

    if @query.category
        if @query.category is 'null'
            query.category = null
        else
            query.category = @query.category

    fields = '-content_ja -content_en'

    opt =
        created_at: -1

    if limit = Number @query.limit
        opt.limit = limit
    if skip = Number @query.skip
        opt.skip = skip

    q = Article.find query, fields, opt
    @body = yield q.exec()
    yield next


router.post '/', auth, (next)->
    article = new Article @request.body
    article.created_at = new Date
    article.updated_at = article.created_at
    try
        @body = yield article.save()
        @status = 201
    catch err
        @body = err
        @status = 422
    yield next


router.get '/:id', user, (next)->
    if /^[0-9a-fA-F]{24}$/.test @params.id
        doc = yield Article.findById @params.id
    else
        doc = yield Article.findOne slug: @params.id

    if not doc
        @status = 404
        return

    if doc.draft and not @user?.approved
        @status = 404
        return

    @body = doc
    yield next


router.patch '/:id', auth, (next)->
    doc = yield Article.findById @params.id
    if not doc
        @status = 404
        return
    base = _.clone @request.body
    delete base.created_at
    base.updated_at = new Date
    _.assign doc, base

    try
        @body = yield doc.save()
        @status = 200
    catch err
        @body = err
        @status = 422
    yield next


router.delete '/:id', auth, (next)->
    yield Article.findByIdAndRemove @params.id
    @status = 204
    yield next


module.exports = router.routes()
