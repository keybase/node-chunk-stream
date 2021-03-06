// Generated by IcedCoffeeScript 108.0.11
(function() {
  var ChunkStream, iced, make_esc, stream, __iced_k, __iced_k_noop,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  iced = require('iced-runtime');
  __iced_k = __iced_k_noop = function() {};

  stream = require('stream');

  make_esc = require('iced-error').make_esc;

  exports.ChunkStream = ChunkStream = (function(_super) {
    __extends(ChunkStream, _super);

    function ChunkStream(_arg) {
      this.transform_func = _arg.transform_func, this.block_size = _arg.block_size, this.readableObjectMode = _arg.readableObjectMode;
      this.extra = null;
      ChunkStream.__super__.constructor.call(this, {
        readableObjectMode: this.readableObjectMode
      });
    }

    ChunkStream.prototype._transform = function(chunk, encoding, cb) {
      var block, blocks, data, esc, i, ___iced_passed_deferral, __iced_deferrals, __iced_k;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      esc = make_esc(cb, "ChunkStream::_transform");
      if (this.extra != null) {
        chunk = Buffer.concat([this.extra, chunk]);
        this.extra = null;
      }
      if (chunk.length < this.block_size) {
        this.extra = chunk;
        return cb(null);
      }
      blocks = [];
      (function(_this) {
        return (function(__iced_k) {
          var _begin, _end, _i, _positive, _results, _step, _while;
          i = 0;
          _begin = 0;
          _end = chunk.length;
          _step = _this.block_size;
          _positive = _step > 0;
          _while = function(__iced_k) {
            var _break, _continue, _next;
            _break = __iced_k;
            _continue = function() {
              return iced.trampoline(function() {
                i += _step;
                return _while(__iced_k);
              });
            };
            _next = _continue;
            if (!!((_positive === true && i >= chunk.length) || (_positive === false && i <= chunk.length))) {
              return _break();
            } else {

              block = chunk.slice(i, i + _this.block_size);
              (function(__iced_k) {
                if (block.length < _this.block_size) {
                  return __iced_k(_this.extra = block);
                } else {
                  (function(__iced_k) {
                    __iced_deferrals = new iced.Deferrals(__iced_k, {
                      parent: ___iced_passed_deferral,
                      filename: "/home/mpcsh/keybase/node-chunk-stream/src/chunk-stream.iced",
                      funcname: "ChunkStream._transform"
                    });
                    _this.transform_func(block, esc(__iced_deferrals.defer({
                      assign_fn: (function() {
                        return function() {
                          return data = arguments[0];
                        };
                      })(),
                      lineno: 30
                    })));
                    __iced_deferrals._fulfill();
                  })(function() {
                    return __iced_k(typeof data !== "undefined" && data !== null ? _this.push(data) : void 0);
                  });
                }
              })(_next);
            }
          };
          _while(__iced_k);
        });
      })(this)((function(_this) {
        return function() {
          return cb(null);
        };
      })(this));
    };

    ChunkStream.prototype.flush_append = function(cb) {
      return cb(null);
    };

    ChunkStream.prototype._flush = function(cb) {
      var esc, out_flush, out_short, ___iced_passed_deferral, __iced_deferrals, __iced_k;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      esc = make_esc(cb, "ChunkStream::_flush");
      (function(_this) {
        return (function(__iced_k) {
          var _ref;
          if (((_ref = _this.extra) != null ? _ref.length : void 0) !== 0) {
            (function(__iced_k) {
              __iced_deferrals = new iced.Deferrals(__iced_k, {
                parent: ___iced_passed_deferral,
                filename: "/home/mpcsh/keybase/node-chunk-stream/src/chunk-stream.iced",
                funcname: "ChunkStream._flush"
              });
              _this.transform_func(_this.extra, esc(__iced_deferrals.defer({
                assign_fn: (function() {
                  return function() {
                    return out_short = arguments[0];
                  };
                })(),
                lineno: 46
              })));
              __iced_deferrals._fulfill();
            })(function() {
              return __iced_k(_this.push(out_short));
            });
          } else {
            return __iced_k();
          }
        });
      })(this)((function(_this) {
        return function() {
          (function(__iced_k) {
            __iced_deferrals = new iced.Deferrals(__iced_k, {
              parent: ___iced_passed_deferral,
              filename: "/home/mpcsh/keybase/node-chunk-stream/src/chunk-stream.iced",
              funcname: "ChunkStream._flush"
            });
            _this.flush_append(esc(__iced_deferrals.defer({
              assign_fn: (function() {
                return function() {
                  return out_flush = arguments[0];
                };
              })(),
              lineno: 50
            })));
            __iced_deferrals._fulfill();
          })(function() {
            if (typeof out_flush !== "undefined" && out_flush !== null) {
              _this.push(out_flush);
            }
            return cb(null);
          });
        };
      })(this));
    };

    return ChunkStream;

  })(stream.Transform);

}).call(this);
