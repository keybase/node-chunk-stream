stream = require('stream')
{make_esc} = require('iced-error')

exports.ChunkStream = class ChunkStream extends stream.Transform

  constructor : ({@transform_func, @block_size, @readableObjectMode}) ->
    @extra = null
    super({@readableObjectMode})

  _transform : (chunk, encoding, cb) ->
    esc = make_esc(cb, "ChunkStream::_transform")
    # prepend any extra
    if @extra?
      chunk = Buffer.concat([@extra, chunk])
      @extra = null

    # if we don't have a full block, dump everything into extra and skip this round
    if chunk.length < @block_size
      @extra = chunk
      return cb(null)

    blocks = []

    for i in [0...chunk.length] by @block_size
      block = chunk[i...i+@block_size]
      # this can only happen at the end
      if block.length < @block_size
        @extra = block
      else
        # transform_func must call back with (err, data) - err is caught by esc
        await @transform_func(block, esc(defer(data)))
        # if transform_func calls back with null, we skip this write
        if data?
          @push(data)

    return cb(null)

  # this is to be overridden by subclasses who want to output something else after the chunking is over
  flush_append : (cb) ->
    return cb(null)

  _flush : (cb) ->
    esc = make_esc(cb, "ChunkStream::_flush")

    # (potentially) write out a short final block (length guaranteed <= @block_size)
    if @extra?.length isnt 0
      await @transform_func(@extra, esc(defer(out_short)))
      @push(out_short)

    # allow subclasses to push something out at the very very end
    await @flush_append(esc(defer(out_flush)))
    if out_flush?
      @push(out_flush)

    return cb(null)
