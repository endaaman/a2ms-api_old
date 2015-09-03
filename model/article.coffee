mongoose = require 'mongoose'
relationship = require 'mongoose-relationship'

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
    title_ja:
        type: String
        required: true
    title_en:
        type: String
        required: true
    content_ja:
        type: String
    content_en:
        type: String
    category:
        type: Schema.Types.ObjectId
        ref: 'Category'
        childPath: 'articles'
    tags: [
        type: Schema.Types.ObjectId
        ref: 'Tag'
        childPath: 'articles'
    ]

    created_at: Date
    updated_at: Date

.plugin relationship, relationshipPathName: ['category', 'tags']
