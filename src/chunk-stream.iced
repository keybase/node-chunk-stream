stream = require('stream')

exports.ChunkStream = class ChunkStream extends stream.Transform

  # transform_func: accepts a buffer, returns a buffer. Used in the _trasform() method.
  # block_size: the chunk size
  # exact_chunking: boolean, specifies whether to pass chunks of exactly block_size or any multiple of block_size to transform_func
  constructor : (@transform_func, @block_size, @exact_chunking) ->
    @extra = null
    # ensure that using exact_chunking doesn't result in an unnecessarily huge buffer
    highWaterMark = if @exact_chunking then @block_size else null
    super({highWaterMark})

  _transform : (chunk, encoding, cb) ->
    if @extra
      chunk = Buffer.concat([@extra, chunk])
      @extra = null

    # skip a write if we don't have at least a full block
    if chunk.length < @block_size
      @extra = chunk
      cb()
      return

    # calculate any remainder - guaranteed to be >= 0 since we wait for when len(chunk + extra) >= block_size
    if @exact_chunking
      remainder = chunk.length - @block_size
    else
      remainder = chunk.length % @block_size

    # mangle the chunk into the proper length
    if remainder isnt 0
      @extra = chunk.slice(chunk.length-remainder)
      chunk = chunk.slice(0, chunk.length-remainder)

    @push(@transform_func(chunk))
    cb()

  _flush : (cb) ->
    # if we're doing exact chunking, it's possible we will have to write multiple flush chunks
    while @exact_chunking and @extra and (@extra.length >= @block_size)
      @push(@transform_func(@extra[...@block_size]))
      @extra = @extra[@block_size...]

    # push the very last (probably incomplete) chunk
    if @extra then @push(@transform_func(@extra))
    cb()
