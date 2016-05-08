_ = require 'lodash'
Q = require 'q'
bcrypt = require 'bcrypt'
jwt = require 'jsonwebtoken'
mongoose = require 'mongoose'

config = require '../config'
auth = require '../lib/auth'
admin = require '../lib/admin'

User = mongoose.model 'User'

router = do require 'koa-router'

bcryptGenSalt = Q.nbind bcrypt.genSalt, bcrypt
bcryptHash = Q.nbind bcrypt.hash, bcrypt


router.post '/', (next)->
    user = new User
        username: @request.body.username
        password: @request.body.password
        approved: false

    yield user.save()
    @status = 204
    yield next


router.get '/', admin, (next)->
    q = User.find {}
    @body = yield q.select '_id username approved'
    yield next

router.post '/:id/approval', admin, (next)->
    q = User.findByIdAndUpdate @params.id, $set: approved: true
    ok = yield q.exec()
    @status = if ok then 200 else 400
    @body =
        approved: true
    yield next


router.delete '/:id/approval', admin, (next)->
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


router.delete '/:id', admin, (next)->
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
