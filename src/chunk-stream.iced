stream = require('stream')

exports.ChunkStream = class ChunkStream extends stream.Transform

  constructor : ({@transform_func, @block_size, @exact_chunking, @writableObjectMode, @readableObjectMode}) ->
    @extra = null
    super({@writableObjectMode, @readableObjectMode})

  _transform : (chunk, encoding, cb) ->
    # if we're processing objects, just go one at a time, ignoring everything else
    if @writableObjectMode
      @push(@transform_func(chunk))
      return cb()

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
          @push(@transform_func(chunk[...@block_size]))
          chunk = chunk[@block_size...]
        @extra = chunk
      # if the transform function can accept chunks of length block_size*n for n \in N, just make one transform function call
      else
        remainder = chunk.length % @block_size
        # chop off extra
        if remainder isnt 0
          @extra = chunk[chunk.length-remainder...]
          chunk = chunk[...chunk.length-remainder]
        @push(@transform_func(chunk))

    cb()

  _flush : (cb) ->
    unless @writableObjectMode
      while @exact_chunking and @extra and @extra.length >= @block_size
        @push(@transform_func(@extra[...@block_size]))
        @extra = @extra[@block_size...]
      if @extra and @extra.length isnt 0 then @push(@transform_func(@extra))
    cb()
