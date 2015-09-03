_ = require 'lodash'
Q = require 'q'
bcrypt = require 'bcrypt'
jwt = require 'jsonwebtoken'
mongoose = require 'mongoose'

config = require '../config'
auth = (require '../lib/auth') true

User = mongoose.model 'User'

router = do require 'koa-router'

bcryptGenSalt = Q.nbind bcrypt.genSalt, bcrypt
bcryptHash = Q.nbind bcrypt.hash, bcrypt


router.post '/', (next)->
    valid = @request.body.username and @request.body.password
    if not valid
        @throw 400

    doc = yield User.findOne username: @request.body.username
    if doc
        @throw 400

    salt = yield bcryptGenSalt 10
    password = yield bcryptHash @request.body.password, salt

    user = new User
        username: @request.body.username
        password: password
        approved: false
        salt: salt

    yield user.save()
    @status = 204
    yield next


router.get '/', auth, (next)->
    q = User.find {}
    docs = yield q.select '_id username approved'
    @body = docs
    yield next


router.get '/:id', auth, (next)->
    q = User.findById @params.id
    doc = yield q.select '_id username approved'
    if not doc
        @status = 404
        return
    @body = doc
    yield next


router.post '/:id/approval', auth, (next)->
    q = User.findByIdAndUpdate @params.id, $set: approved: true
    ok = yield q.exec()
    @status = if ok then 200 else 400
    @body =
        approved: true
    yield next


router.delete '/:id/approval', auth, (next)->
    if @user._id is @params.id
        @status = 403
        @body =
            message: 'Do not delete approval youself'
        return

    q = User.findByIdAndUpdate @params.id, $set: approved: false
    ok = yield q.exec()
    @body =
        approved: false
    yield next


router.delete '/:id', auth, (next)->
    if @user._id is @params.id
        @status = 403
        @body =
            message: 'Do not delete youself'
        return
    q = User.findByIdAndRemove @params.id
    yield q.exec()
    @status = 204
    yield next


module.exports = router.routes()
