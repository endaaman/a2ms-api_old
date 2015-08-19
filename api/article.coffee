_ = require 'lodash'
monk = require 'monk'

auth = require '../lib/auth'
config = require '../config'

db = monk config.db
memos = db.get 'articles'

router = do require 'koa-router'

###* Schema
    _id: ObjectID()
    slug: url
    title_ja: title in Japanese
    title_en: title in English
    content_ja: content in Japanese
    content_en: content in English

    created_at: Date when created
    updated_at: Date when updated

###


router.get '/', (next)->
    docs = yield memos.find {},
        fields: ['-content_ja', '-content_en']
        sort:
            created_at: -1
    @body = docs
    yield next


router.post '/', auth, (next)->
    memo = _.clone @request.body
    memo.created_at = new Date
    memo.updated_at = memo.created_at
    doc = yield memos.insert memo
    @body = doc
    yield next


router.get '/:title', (next)->
    doc = yield memos.findOne title: @params.title
    if not doc
        @status = 404
        return

    @body = doc
    yield next


router.put '/:id', auth, (next)->
    memo = _.clone @request.body
    if memo.created_at
        delete memo.created_at
    memo.updated_at = new Date
    yield memos.updateById @params.id, $set: memo
    @body = memo
    yield next


router.delete '/:id', auth, (next)->
    yield memos.remove _id: @params.id
    @body = ''
    yield next


module.exports = router.routes()
