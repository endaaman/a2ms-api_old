mongoose = require 'mongoose'

Schema = mongoose.Schema

module.exports = new Schema
    message_ja:
        type: String
        required: true
    message_en:
        type: String
        required: true
    url:
        type: String
        default: ''
    date:
        type: Date
        default: Date.now
