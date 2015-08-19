_ = require 'lodash'
Q = require 'q'
bcrypt = require 'bcrypt'
jwt = require 'jsonwebtoken'
monk = require('monk')

config = require '../config'
auth = require '../lib/auth'

db = monk config.db

users = db.get 'users'
router = do require 'koa-router'

bcryptGenSalt = Q.nbind bcrypt.genSalt, bcrypt
bcryptHash = Q.nbind bcrypt.hash, bcrypt


router.post '/', (next)->
    valid = @request.body.username and @request.body.password
    if not valid
        @throw 400

    doc = yield users.findOne username: @request.body.username
    if doc
        @throw 400

    salt = yield bcryptGenSalt 10
    password = yield bcryptHash @request.body.password, salt

    user =
        username: @request.body.username
        password: password
        approved: false
        salt: salt

    yield users.insert user
    @status = 204
    yield next


router.get '/', auth, (next)->
    docs = yield users.find {}, ['_id', 'username']
    @body = docs
    yield next


router.get '/:id/approval', auth, (next)->
    doc = yield users.findById @params.id
    if not doc
        @status = 404
        return
    @body =
        approved: doc.approved
    yield next

router.post '/:id/approval', auth, (next)->
    ok = yield users.updateById @params.id, $set: approved: true
    @status = if ok then 200 else 400
    @body =
        approved: true
    yield next


router.delete '/:id/approval', auth, (next)->
    ok = yield users.updateById @params.id, $set: approved: false
    @status = if ok then 200 else 400
    @body =
        approved: false
    yield next


module.exports = router.routes()
