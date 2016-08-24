crypto = require('crypto')
to_buf = require('../../lib/stream-to-buffer.js')
stream = require('../../lib/chunk-stream.js')

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

iterative_pass_test = (limit, skip, opts, T, cb) ->
  for i in [1..limit] by skip
    pass = new stream.ChunkStream(opts)
    stb = new to_buf.StreamToBuffer()
    pass.pipe(stb)

    await stream_random_data(pass, i, defer(expected))
    await
      stb.on('finish', defer())
      pass.end()

    T.equal(expected, stb.getBuffer(), 'Streaming failed!')
  cb()

noop = (x) -> x

# so that we go well above the highWaterMark
limit = 32768*8
# some random large-ish prime to make tests a bit faster
skip = 271

exports.test_inexact_streaming = (T, cb) ->
  start = new Date().getTime()
  await iterative_pass_test(limit, skip, {transform_func: noop, block_size : crypto.randomBytes(1)[0], exact_chunking : false, writableObjectMode : false, readableObjectMode : false}, T, defer())
  end = new Date().getTime()
  time = end - start
  console.log('Inexact time: ' + time)
  cb()

exports.test_exact_streaming = (T, cb) ->
  start = new Date().getTime()
  await iterative_pass_test(limit, skip, {transform_func: noop, block_size : crypto.randomBytes(1)[0], exact_chunking : true, writableObjectMode : false, readableObjectMode : false}, T, defer())
  end = new Date().getTime()
  time = end - start
  console.log('Exact time: ' + time)
  cb()

exports.test_writable_object_mode = (T, cb) ->
  start = new Date().getTime()
  await iterative_pass_test(limit, skip, {transform_func: noop, block_size : null, exact_chunking : null, writableObjectMode : true, readableObjectMode : false}, T, defer())
  end = new Date().getTime()
  time = end - start
  console.log('Writable object time: ' + time)
  cb()
