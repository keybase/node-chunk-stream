crypto = require('crypto')
to_buf = require('../../src/stream-to-buffer.iced')
stream = require('../../src/chunk-stream.iced')

stream_random_data = (strm, len, cb) ->
  written = 0
  expected_results = []
  while written < len
    # generate random length
    await crypto.randomBytes(1, defer(err, index))
    if err then throw err
    amt = (index[0] + 1)*16

    # generate random bytes of length amt
    await crypto.randomBytes(amt, defer(err, buf))
    if err then throw err
    written += buf.length
    expected_results.push(buf)

    # write the buffer
    await strm.write(buf, defer(err))
    if err then throw err

  cb(Buffer.concat(expected_results))

iterative_pass_test = (limit, skip, f, opts, T, cb) ->
  for i in [1..limit] by skip
    pass = new stream.ChunkStream(f, opts)
    stb = new to_buf.StreamToBuffer()
    pass.pipe(stb)

    await stream_random_data(pass, i, defer(expected))
    await
      pass.on('finish', defer())
      pass.end()

    T.equal(expected, stb.getBuffer(), 'Streaming failed!')
  cb()

noop = (x) -> x

# so that we go well above the highWaterMark
limit = 32768
# some random large-ish prime to make tests a bit faster
skip = 271

exports.test_inexact_streaming = (T, cb) ->
  await iterative_pass_test(limit, skip, noop, {block_size : crypto.prng(1)[0], exact_chunking : false, writableObjectMode : false, readableObjectMode : false}, T, defer())
  cb()

exports.test_exact_streaming = (T, cb) ->
  await iterative_pass_test(limit, skip, noop, {block_size : crypto.prng(1)[0], exact_chunking : true, writableObjectMode : false, readableObjectMode : false}, T, defer())
  cb()

exports.test_writable_object_mode = (T, cb) ->
  await iterative_pass_test(limit, skip, noop, {block_size : null, exact_chunking : null, writableObjectMode : true, readableObjectMode : false}, T, defer())
  cb()
