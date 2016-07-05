# node-chunk-stream
===

A TransformStream implementation for applications where exact or exact-multiple chunk sizes are needed.

## Install

	npm install chunk-stream

## Use cases

This tool was created for situations where you, as a stream consumer, need to modify data on a chunk-by-chunk basis. This can be accomplished in two ways:
1) exact chunking: data will be processed in chunks of precisely one size
2) modulo chunking: data will be processed in multiples of the chunk size
Of course, the last chunk is usually smaller than the chunk size.

The two most obvious use cases are for ASCII armoring (which uses modulo chunking), and encryption/decryption (which, in [saltpack](https://saltpack.org)'s case uses exact chunking).

## API

This tool exposes a simple TransformStream implementation with some sugar. To create a ChunkStream that simply passes through data without modification in chunks of even length:

	cstream = require('keybase-chunk-stream')
	transform_func = (x) -> x
	cs = new cstream.ChunkStream(transform_func, 4, false)

Some notes here. First, `transform_func` must accept a buffer and return a buffer. The ChunkStream constructor's parameters, in order, are the transform function, the chunk size, and a boolean stating whether or not to use exact chunking (true for exact, false for modulo).
