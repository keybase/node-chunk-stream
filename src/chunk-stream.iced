stream = require('stream')
{make_esc} = require('iced-error')

exports.ChunkStream = class ChunkStream extends stream.Transform

  constructor : ({@transform_func, @block_size, @exact_chunking, @writableObjectMode, @readableObjectMode}) ->
    @extra = null
    super({@writableObjectMode, @readableObjectMode})

  _transform : (chunk, encoding, cb) ->
    # if we're processing objects, just go one at a time, ignoring everything else
    esc = make_esc(cb, "Error in transform function")

    if @writableObjectMode
      await @transform_func(chunk, esc(defer(out)))
      @push(out)
      return cb(null)

    else
      # prepend any extra
      if @extra?
        chunk = Buffer.concat([@extra, chunk])
        @extra = null

      # if we don't have a full block, dump everything into extra and skip this round
      if chunk.length < @block_size
        @extra = chunk
      else
        # if we have to, call the transform function multiple times until we have less than a block size remaining
        if @exact_chunking
          while chunk.length >= @block_size
            await @transform_func(chunk, esc(defer(out)))
            @push(out)
            chunk = chunk[@block_size...]
          @extra = chunk
          return cb(null)

        # if the transform function can accept chunks of length block_size*n for n \in N, just make one transform function call
        else
          remainder = chunk.length % @block_size
          # chop off extra
          if remainder isnt 0
            @extra = chunk[chunk.length-remainder...]
            chunk = chunk[...chunk.length-remainder]
          await @transform_func(chunk, esc(defer(out)))
          @push(out)
          return cb(null)

  # this is to be overridden by subclasses who want to output something else after the chunking is over
  _flush_append : (cb) ->
    return cb(null)

  _flush : (cb) ->
    esc = make_esc(cb, "Error in transform function")
    unless @writableObjectMode
      # if we're in exact chunking mode, handle potentially multiple blocks of data in @extra
      while @exact_chunking and @extra and @extra.length >= @block_size
        await @transform_func(@extra[...@block_size], esc(defer(out)))
        @push(out)
        @extra = @extra[@block_size...]

      # either way, write out one final block (length guaranteed <= @block_size)
      if @extra and @extra.length isnt 0
        await @transform_func(@extra, esc(defer(out)))
        @push(out)

    await @_flush_append(esc(defer(out)))
    if out? then @push(out)

    return cb(null)
