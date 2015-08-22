_ = require 'lodash'
monk = require 'monk'

auth = require '../lib/auth'
config = require '../config'

db = monk config.db
articles = db.get 'articles'

router = do require 'koa-router'

###* Schema
    _id: ObjectID()
    slug: url
    title_ja: title in Japanese
    title_en: title in English
    content_ja: content in Japanese
    content_en: content in English
    tass: list of related tag ids

    created_at: Date when created
    updated_at: Date when updated

###


router.get '/', (next)->
    query = {}
    if @params.title
        query.title = @params.title
    docs = yield articles.find query,
        fields: ['-content_ja', '-content_en']
        sort:
            created_at: -1
    @body = docs
    yield next


router.post '/', auth, (next)->
    article = _.clone @request.body
    article.created_at = new Date
    article.updated_at = article.created_at
    doc = yield articles.insert article
    @body = doc
    @status = 201
    yield next


router.get '/:id', (next)->
    if /^[0-9a-fA-F]{24}$/.test @params.id
        doc = yield articles.findById @params.id
    else
        doc = yield articles.findOne slug: @params.id

    if not doc
        @status = 404
        return

    @body = doc
    yield next


router.put '/:id', auth, (next)->
    article = _.clone @request.body
    if article.created_at
        delete article.created_at
    article.updated_at = new Date
    yield articles.updateById @params.id, $set: article
    @body = article
    yield next


router.delete '/:id', auth, (next)->
    yield articles.remove _id: @params.id
    @status = 204
    yield next


module.exports = router.routes()
