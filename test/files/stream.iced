crypto = require('crypto')
stream = require('../..')
to_buf = stream.util
{make_esc} = require('iced-error')

stream_random_data = (strm, len, cb) ->
  esc = make_esc(cb, "Error in stream writing")
  written = 0
  expected_results = []
  while written < len
    # generate random length
    await crypto.randomBytes(1, esc(defer(index)))
    amt = (index[0] + 1)*16

    # generate random bytes of length amt
    await crypto.randomBytes(amt, esc(defer(buf)))
    written += buf.length
    expected_results.push(buf)

    # write the buffer
    await strm.write(buf, 'utf-8', esc(defer()))

  cb(null, Buffer.concat(expected_results))

iterative_pass_test = (T, {limit, skip, transform_func, block_size, exact_chunking, writableObjectMode, readableObjectMode}, cb) ->
  for i in [1..limit] by skip
    esc = make_esc(cb, "Error in pass test #{i}")
    pass = new stream.ChunkStream({transform_func, block_size, exact_chunking, writableObjectMode, readableObjectMode})
    stb = new to_buf.StreamToBuffer()
    pass.pipe(stb)

    await stream_random_data(pass, i, esc(defer(expected)))
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
