_ = require 'lodash'
Q = require 'q'
jwt = require 'jsonwebtoken'

config = require '../config'

jwtVerify = Q.nbind jwt.verify, jwt

module.exports = (next)->
    # Header style
    #   Authorization: Bearer TOKEN_STRING

    authStyle = 'Bearer'

    @token = {}

    if not @request.header.authorization?
        @throw 401
        return

    parts = @request.header.authorization.split ' '
    validTokenStyle = parts.length is 2 and parts[0] is authStyle

    if not validTokenStyle
        @throw 401
        return

    token = parts[1]

    decoded = yield jwtVerify token, config.secret
    .fail (e)=>
        @throw 401
        return


    if not decoded.approved
        @throw 401
        return

    @user =  (_.pick decoded, ['_id', 'username', 'approved'])

    yield next
