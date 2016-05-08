_ = require 'lodash'
mongoose = require 'mongoose'

auth = require '../lib/auth'
config = require '../config'

Article = mongoose.model 'Article'
Category = mongoose.model 'Category'
News = mongoose.model 'News'

router = do require 'koa-router'

router.get '/', (next)->
    query = {}
    if not @user
        query.draft = false

    # fields =
    #     content_ja: false
    #     content_en: false
    fields = {}

    opt =
        sort: '-order created_at'

    q = Article.find query, fields, opt
    @body = yield q.exec()
    yield next


router.post '/', auth, (next)->
    article = new Article @request.body
    @body = yield article.save()
    yield next

    # NOTE: お知らせの自動追加
    # doc = yield Article.populate @body, path: 'category'
    # base = if doc.category then doc.category.slug else '-'
    # url = "/#{base}/#{doc.slug}"
    # news = new News
    #     message_ja: "記事「[#{doc.title_ja}](#{url})」を追加しました"
    #     message_en: "Add entry \"[#{doc.title_en}](#{url})\""
    # yield news.save()


router.get '/:id', (next)->
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
    _.assign doc, @request.body

    @body = yield doc.save()
    yield next

router.delete '/:id', auth, (next)->
    yield Article.findByIdAndRemove @params.id
    @status = 204
    yield next


module.exports = router.routes()
