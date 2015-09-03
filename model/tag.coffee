mongoose = require 'mongoose'
relationship = require 'mongoose-relationship'

Schema = mongoose.Schema

module.exports = new Schema
    name_ja:
        type: String
        required: true
    name_en:
        type: String
        required: true
    articles: [
        type: Schema.Types.ObjectId
        ref: 'Article'
    ]

# .plugin relationship, relationshipPathName: 'articles'
