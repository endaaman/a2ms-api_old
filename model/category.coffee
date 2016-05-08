mongoose = require 'mongoose'

Schema = mongoose.Schema

module.exports = new Schema
    slug:
        type: String
        required: true
        index:
            unique: true
    name_ja:
        type: String
        required: true
    name_en:
        type: String
        required: true
    order:
        type: Number
        required: true
        default: 0
    image_url:
        type: String
        default: ''
    desc_ja:
        type: String
    desc_en:
        type: String
