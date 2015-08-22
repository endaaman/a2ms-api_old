_ = require 'lodash'
monk = require 'monk'

auth = require '../lib/auth'
config = require '../config'

db = monk config.db
newss = db.get 'newss'

router = do require 'koa-router'

###* Schema
    _id: ObjectID()
    title_ja: name in Japanese
    title_en: name in English

    content_ja: content in Japanese
    content_en: content in English

    type: 'article', 'news'
    articles: list of related article ids
###


router.get '/', (next)->
    docs = yield newss.find {}
    @body = docs
    yield next


router.post '/', auth, (next)->
    news = _.clone @request.body
    doc = yield newss.insert news
    @body = doc
    yield next


router.get '/:title', (next)->
    doc = yield newss.findOne title: @params.title
    if not doc
        @status = 404
        return

    @body = doc
    yield next


router.put '/:id', auth, (next)->
    news = _.clone @request.body
    if news.created_at
        delete news.created_at
    news.updated_at = new Date
    yield newss.updateById @params.id, $set: news
    @body = news
    yield next


router.delete '/:id', auth, (next)->
    yield newss.remove _id: @params.id
    @body = ''
    yield next


module.exports = router.routes()
