mongoose = require 'mongoose'

Schema = mongoose.Schema

module.exports = new Schema
    slug:
        type: String
        required: true
        index:
            unique: true
    draft:
        type: Boolean
        required: true
    order:
        type: Number
        required: true
        default: 0
    title_ja:
        type: String
        required: true
    title_en:
        type: String
        required: true
    image_url:
        type: String
        default: ''
    category:
        type: Schema.Types.ObjectId
        ref: 'Category'
        default: null
    content_ja:
        type: String
        default: ''
    content_en:
        type: String
        default: ''
    comment:
        type: String
        default: ''

    created_at:
        type: Date
        default: Date.now
    updated_at:
        type: Date
        default: Date.now

.pre 'validate', (next)->
    if @category is ''
        @category = null
    next()
