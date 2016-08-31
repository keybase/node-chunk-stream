crypto = require('crypto')
stream = require('../..')
util = stream.util
{make_esc} = require('iced-error')

iterative_pass_test = (T, {limit, skip, transform_func, block_size, exact_chunking, writableObjectMode, readableObjectMode}, cb) ->
  for i in [1..limit] by skip
    esc = make_esc(cb, "Error in pass test #{i}")
    pass = new stream.ChunkStream({transform_func, block_size, exact_chunking, writableObjectMode, readableObjectMode})
    stb = new util.StreamToBuffer()
    pass.pipe(stb)

    await util.stream_random_data(pass, i, esc(defer(expected)))
    await
      stb.on('finish', defer())
      pass.end()

    T.equal(expected, stb.getBuffer(), 'Streaming failed!')
  cb(null)

noop = (x, cb) ->
  cb(null, x)

timed_test = (T, {readableObjectMode}, cb) ->
  esc = make_esc(cb, "Unknown error")
  start = new Date().getTime()

  await iterative_pass_test(T, {
    limit : 32768*8,
    skip : 1987,
    transform_func : noop,
    block_size : crypto.randomBytes(1)[0],
    readableObjectMode : false
  }, esc(defer()))

  end = new Date().getTime()
  time = end - start
  console.log('Time: ' + time)
  cb(null)

exports.test_byte_streaming = (T, cb) ->
  await timed_test(T, {readableObjectMode : false}, defer(err))
  cb(err)

exports.test_readable_object_mode = (T, cb) ->
  await timed_test(T, {readableObjectMode : true}, defer(err))
  cb(err)
