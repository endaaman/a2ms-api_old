_ = require 'lodash'
monk = require 'monk'

auth = require '../lib/auth'
config = require '../config'

db = monk config.db
tags = db.get 'tags'

router = do require 'koa-router'

###* Schema
    _id: ObjectID()
    name_ja: name in Japanese
    name_en: name in English
    articles: list of related article ids
###


router.get '/', (next)->
    docs = yield tags.find {}
    @body = docs
    yield next


router.post '/', auth, (next)->
    tag = _.clone @request.body
    doc = yield tags.insert tag
    @body = doc
    yield next


router.get '/:title', (next)->
    doc = yield tags.findOne title: @params.title
    if not doc
        @status = 404
        return

    @body = doc
    yield next


router.put '/:id', auth, (next)->
    tag = _.clone @request.body
    if tag.created_at
        delete tag.created_at
    tag.updated_at = new Date
    yield tags.updateById @params.id, $set: tag
    @body = tag
    yield next


router.delete '/:id', auth, (next)->
    yield tags.remove _id: @params.id
    @body = ''
    yield next


module.exports = router.routes()
