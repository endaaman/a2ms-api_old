mongoose = require 'mongoose'

Schema = mongoose.Schema

module.exports = new Schema
    username:
        type: String
        required: true
        index:
            unique: true
    password:
        type: String
        required: true
    approved:
        type: Boolean
        required: true
    salt:
        type: String
        required: true
