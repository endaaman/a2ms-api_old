
module.exports = (next)->
    if not @user or not @user.admin
        @throw 401
        return
    yield next
