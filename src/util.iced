stream = require('stream')
crypto = require('crypto')
{make_esc} = require('iced-error')

exports.stream_random_data = (strm, len, cb) ->
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

exports.StreamToBuffer = class StreamToBuffer extends stream.Transform
  constructor : (options) ->
    @bufs = []
    super(options)

  _write : (chunk, encoding, cb) ->
    @bufs.push(chunk)
    cb()

  getBuffer : () ->
    return Buffer.concat(@bufs)
