stream = require('stream')
{make_esc} = require('iced-error')

exports.ChunkStream = class ChunkStream extends stream.Transform

  constructor : ({@transform_func, @block_size, @readableObjectMode}) ->
    @extra = null
    super({@readableObjectMode})

  _transform_chunk : (chunk, cb) ->
    blocks = []
    for i in [0...chunk.length] by @block_size
      block = chunk[i...i+@block_size]
      if block.length < @block_size
        @extra = block
      else
        await @transform_func(block, defer(err, out))
        blocks.push(out)
    ret = Buffer.concat(blocks)
    cb(err, ret)


  _transform : (chunk, encoding, cb) ->
    esc = make_esc(cb, "ChunkStream::_transform")
    # prepend any extra
    if @extra?
      chunk = Buffer.concat([@extra, chunk])
      @extra = null

    # if we don't have a full block, dump everything into extra and skip this round
    if chunk.length < @block_size
      @extra = chunk
      return cb(null, new Buffer(''))

    await @_transform_chunk(chunk, esc(defer(out)))
    cb(null, out)


  # this is to be overridden by subclasses who want to output something else after the chunking is over
  flush_append : (cb) ->
    return cb(null, null)

  _flush : (cb) ->
    esc = make_esc(cb, "ChunkStream::_flush")

    # either way, write out one final block (length guaranteed <= @block_size)
    if @extra?.length isnt 0
      await @transform_func(@extra, esc(defer(out_short)))
      @push(out_short)

    # allow subclasses to push something out at the very very end
    await @flush_append(esc(defer(out_flush)))
    if out_flush?
      @push(out_flush)

    return cb(null)
