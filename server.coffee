Canvas = require('canvas')


WebSocketServer = require('websocket').server
socketServer = new WebSocketServer({
    httpServer : global.app,
    autoAcceptConnections : true,
    maxReceivedFrameSize: 0x1000000
});

global.blobArray = []

socketServer.on 'connect', (socket)->
  setInterval ->
    canvas = new Canvas(400, 400)
    c = canvas.getContext("2d")
    blob =
      x: 200
      y: 200
      xSpeed: (-10 + (Math.random() * 20))
      ySpeed: (-15 + (Math.random() * 20))
      color: "red"
      gravity: .4
      size: 5
      
    global.blobArray.push blob
    c.clearRect 0, 0, 400, 400
    i = 0
    while i < global.blobArray.length
      c.fillStyle = global.blobArray[i].color
      c.fillRect global.blobArray[i].x, global.blobArray[i].y, global.blobArray[i].size, global.blobArray[i].size
      global.blobArray[i].x = global.blobArray[i].x + global.blobArray[i].xSpeed
      global.blobArray[i].y = global.blobArray[i].y + global.blobArray[i].ySpeed
      global.blobArray[i].ySpeed = global.blobArray[i].ySpeed += global.blobArray[i].gravity
      global.blobArray[i].size = global.blobArray[i].size * .97
      i++
    
    # ここでbase64でemitしてもよい
    return socket.sendUTF(canvas.toDataURL())
    
    # さらにwebsocketのバイナリ転送を利用
    imagedata = c.getImageData(0, 0, 400, 400)
    bin = imagedata.data
    len = bin.length
    buff = new Buffer(len)
    for i in [0..(len-1)]
      buff[i] = bin[i]
    console.log(buff)
    socket.sendBytes(buff)
    
    # シンプルだがバイナリが破損するため上記方法で。。
    # b64 = canvas.toDataURL()
    # buff = new Buffer(b64, 'base64')
    # console.log(b64)
    # console.log(buff)
    # socket.sendBytes(buff)
    # socket.sendBytes(buff)
  , 1000
  # utfなら10ms程度でも問題ない(2,000byte/res)
  # ArrayBufferなら1000ms程度が限界(640,000byte/res)
  
  socket.on 'message', (val)->
    console.log(val)
    if val.type is 'binary'
      socket.sendBytes(val.binaryData);
  
  socket.on 'disconnect', (v) ->
    console.log(val)
  
  console.log("collected!!")
