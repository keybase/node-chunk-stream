stream = require('stream')

exports.ChunkStream = class ChunkStream extends stream.Transform

  constructor : (@transform_func, {@block_size, @exact_chunking, @writableObjectMode, @readableObjectMode}) ->
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
      # calculate remainder
      if @exact_chunking
        # guaranteed to be nonnegative
        remainder = chunk.length - @block_size
      else
        remainder = chunk.length % @block_size

      # chop off extra
      if remainder isnt 0
        @extra = chunk[chunk.length-remainder..]
        chunk = chunk[0...chunk.length-remainder]

      # finally, process
      @push(@transform_func(chunk))

    cb()

  _flush : (cb) ->
    unless @writableObjectMode
      while @exact_chunking and @extra and @extra.length > @block_size
        @push(@transform_func(@extra[...@block_size]))
        @extra = @extra[@block_size...]
      if @extra and @extra.length isnt 0 then @push(@transform_func(@extra))
    cb()
