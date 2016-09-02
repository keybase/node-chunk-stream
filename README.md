# node-chunk-stream

A TransformStream implementation for applications where exact or exact-multiple chunk sizes are needed.

## Install

	npm install keybase-chunk-stream

## Use cases

This tool was created for situations where you, as a stream consumer, need to modify data on a chunk-by-chunk basis, e.g. BaseX armoring or cryptography.

## API

This tool exposes a simple TransformStream implementation with some sugar. To create a ChunkStream that simply passes through data without modification in chunks of even length:

	cstream = require('keybase-chunk-stream')
	transform_func = (x, cb) -> cb(null, x)
	cs = new cstream.ChunkStream({transform_func, block_size :  2})
