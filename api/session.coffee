_ = require 'lodash'
Q = require 'q'
bcrypt = require 'bcrypt'
jwt = require 'jsonwebtoken'
monk = require 'monk'

auth = require '../lib/auth'
config = require '../config'

db = monk config.db
users = db.get 'users'

router = do require 'koa-router'

bcryptCompare = Q.nbind bcrypt.compare, bcrypt
jwtVerify = Q.nbind jwt.verify, jwt


router.post '/', (next)->
    doc = yield users.findOne username: @request.body.username
    console.log doc
    if not doc
        @throw 401
        return

    if not doc.approved
        @throw 401
        return

    ok = yield bcryptCompare @request.body.password, doc.password
    if not ok
        @throw 401
        return

    user = _.pick doc, ['_id', 'username', 'approved']
    token = jwt.sign _.clone(user), config.secret
    @body =
        token: token
        user: user
    @status = 201
    yield next


router.get '/', auth, (next)->
    @body =
        user: @user
    yield next


module.exports = router.routes()
