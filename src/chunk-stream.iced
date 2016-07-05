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

    remainder = chunk.length % @block_size
    if remainder isnt 0
      @extra = chunk.slice(chunk.length-remainder)
      chunk = chunk.slice(0, chunk.length-remainder)

    @push(@transform_func(chunk))
    cb()

  _flush : (cb) ->
    if @extra then @push(@transform_func(@extra))
    cb()


###
    # if we don't have enough data, push it all into extra and return
    if @extra and (@extra.length + chunk.length) < @block_size
      extra = Buffer.concat([@extra, chunk])
      cb()
      return

    # concatenate any extra
    if @extra
      chunk = Buffer.concat([@extra, chunk])
      @extra = null

    # calculate any remainder - guaranteed to be >= 0 since we wait for when len(chunk + extra) >= block_size
    if @exact_chunking
      remainder = chunk.length - @block_size
    else
      remainder = chunk.length % @block_size

    # mangle the buffer into either exactly block_size or a multiple of block_size
    if remainder isnt 0
      @extra = chunk[chunk.length-remainder...chunk.length]
      chunk = chunk[0...chunk.length-remainder]

    # do the transformation, and push out the chunk
    @push(@transform_func(chunk))
    cb()

  _flush : (cb) ->
    if @extra
      # if we're doing exact chunking, it's possible we will have to write multiple flush chunks
      if @exact_chunking
        console.log('exact chunking')
        loop
          push(@transform_func(@extra[0...@block_size]))
          @extra = @extra[@block_size...]
          break unless @extra.length == 0
      # if we're not, just write out the last chunk
      else
        console.log("flushing #{@extra}")
        @push(@transform_func(@extra))
    cb()
###
