stream = require('stream')
{make_esc} = require('iced-error')

exports.ChunkStream = class ChunkStream extends stream.Transform

  constructor : ({@transform_func, @block_size, @readableObjectMode}) ->
    @extra = null
    super({@readableObjectMode})

  # chunk must be guaranteed to be a multiple of the block size
  _transform_chunk : (chunk, cb) ->
    blocks = []
    count = 0
    for i in [0...chunk.length] by @block_size
      block = chunk[i...i+@block_size]
      await @transform_func(block, defer(err, blocks[count]))
      ++count
    blocks = Buffer.concat(blocks)
    cb(null, blocks)


  _transform : (chunk, encoding, cb) ->
    # prepend any extra
    if @extra?
      chunk = Buffer.concat([@extra, chunk])
      @extra = null

    # if we don't have a full block, dump everything into extra and skip this round
    if chunk.length < @block_size
      @extra = chunk
      return cb(null, new Buffer(''))

    # next, mangle the chunk so that it is an even multiple of the block size
    remainder = chunk.length % @block_size
    if remainder isnt 0
      @extra = chunk[chunk.length-remainder...]
      chunk = chunk[...chunk.length-remainder]

    # finally, process the chunk (guaranteed to be the correct length)
    esc = make_esc(cb, "Failed to transform the chunk")
    await @_transform_chunk(chunk, esc(defer(out)))
    cb(null, out)


  # this is to be overridden by subclasses who want to output something else after the chunking is over
  _flush_append : (cb) ->
    return cb(null, null)

  _flush : (cb) ->
    esc = make_esc(cb, "Failed to flush")

    # potentially deal with multiple flushed blocks
    if @extra?.length >= @block_size
      await @_transform_chunk(@extra, esc(defer(out_blocks)))
      if out_blocks?
        @push(out_blocks)

    # either way, write out one final block (length guaranteed <= @block_size)
    if @extra?.length isnt 0
      await @transform_func(@extra, esc(defer(out_short)))
      if out_short?
        @push(out_short)

    # allow subclasses to push something out at the very very end
    await @_flush_append(esc(defer(out_flush)))
    if out_flush?
      @push(out_flush)

    return cb(null)
