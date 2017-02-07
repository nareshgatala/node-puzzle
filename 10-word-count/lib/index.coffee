through2 = require 'through2'


module.exports = ->
  words = 0
  lines = 1
  transform = (chunk, encoding, cb) ->

    # Check if it is a new line and count
    if chunk.match(/\n/mg)
      noOfLines = chunk.match(/\n/mg).length

    filteredInput = findQuotedWords (chunk)
    chunk = filteredInput.remainingWords

    words = []
    if chunk.length > 0
      
      chunk = chunk.replace(/([a-z])([A-Z])/g, '$1 $2').replace(/(\n|\s)$/, '')

      
      words = chunk.replace(/((\s)+|(\n)+)/g,' ').replace( /\n/g, " ").split(' ')

      words = words.length

    if(filteredInput.quotedWords)
      totalWords  = filteredInput.quotedWords.concat words
      words = totalWords.length

    return cb()

  flush = (cb) ->
    this.push {words, lines}
    this.push null
    return cb()


  findQuotedWords = (input) ->
    output = false
    quotedWords = input.match(/".*?"/g)
    if(quotedWords && quotedWords.length > 0)
      output = quotedWords.map((v, i) ->
        input = input.replace(v,'')
        v.replace (/\"/mg), ''
      )
    quotedWords : output, remainingWords : input
  return through2.obj transform, flush