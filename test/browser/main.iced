mods =
  stream : require('../files/stream.iced')

v = Object.keys(mods)
v.sort()
for k in v
  console.log(k)

{BrowserRunner} = require('iced-test')

window.onload = () ->
  br = new BrowserRunner({log : 'log', rc : 'rc'})
  await br.run(mods, defer(rc))
