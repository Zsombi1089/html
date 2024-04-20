'use strict'

do -> # set window.requestAnimationFrame()
  w = window
  lastTime = 0
  vendors = ['webkit', 'moz']
  unless w.requestAnimationFrame
    for i in [0...vendors.length]
      w.requestAnimationFrame = w["#{vendors[i]}RequestAnimationFrame"]
      w.cancelAnimationFrame = w["#{vendors[i]}CancelAnimationFrame"] or
        w["#{vendors[i]}CancelRequestAnimationFrame"]
  unless w.requestAnimationFrame
    w.requestAnimationFrame = (callback, element) ->
      currTime = new Date().getTime()
      timeToCall = Math.max 0, 16 - (currTime - lastTime)
      id = w.setTimeout(->
        callback currTime + timeToCall
      , timeToCall)
      lastTime = currTime + timeToCall
      id
  unless w.cancelAnimationFrame
    w.cancelAnimationFrame = (id) ->
      clearTimeout id

canvas = document.getElementById('canvas')
ctx = canvas.getContext('2d')

canvas.getWindowSize = ->
  w = window
  d = document
  e = d.documentElement
  g =  d.getElementsByTagName('body')[0]
  @width = w.innerWidth or e.clientWidth or g.clientWidth
  @height = w.innerHeight or e.clientHeight or g.clientHeight
  @min = Math.min @width, @height
  @max = Math.max @width, @height

canvas.sizeCanvas = (w = canvas.width, h = canvas.height) ->
  @setAttribute 'width', w
  @setAttribute 'height', h
  @top    = -@height / 2
  @left   = -@width  / 2
  @right  =  @width  / 2
  @bottom =  @height / 2

  ctx.restore()
  ctx.translate w/2, h/2
  ctx.save()

canvas.getWindowSize()
canvas.sizeCanvas(canvas.width, canvas.height)

canvas.windowGotResized = ->
  ctx.save()
  ctx.translate -canvas.width/2, -canvas.height/2
  ow = canvas.width
  oh = canvas.height
  canvasCopy = document.createElement('canvas')
  contextCopy = canvasCopy.getContext('2d')
  canvasCopy.setAttribute 'width',  ow
  canvasCopy.setAttribute 'height', oh
  contextCopy.drawImage canvas, 0, 0
  #resize canvas
  canvas.getWindowSize()
  canvas.sizeCanvas canvas.width, canvas.height
  #paste copied canvas onto resized canvas
  ctx.drawImage canvasCopy,
                0, 0,
                ow, oh,
                canvas.left, canvas.top,
                canvas.width, canvas.height
  ctx.restore()

window.addEventListener 'resize', canvas.windowGotResized, false
window.addEventListener 'orientationchange', canvas.windowGotResized, false

ctx.imageSmoothing = (a = false) ->
  ctx.webkitImageSmoothingEnabled = a
  ctx.mozImageSmoothingEnabled    = a
  ctx.imageSmoothingEnabled       = a

Mouse =
  x      : 0
  y      : 0
  xs     : 0
  ys     : 0
  up     : true
  down   : false
  clicks : 0
  events : {}
  points : []
  smooth : []

Mouse.events.move = (e) ->
  if 'touches' of e
    e.preventDefault()
    e = e.touches[0]
  return if e.pageX is Mouse.x and e.pageY is Mouse.y
  Mouse.x = Math.round e.pageX - canvas.right
  Mouse.y = Math.round e.pageY - canvas.bottom
  Mouse.points.push(x: Mouse.x, y: Mouse.y)
  if Mouse.points.length > 2
    mpl = Mouse.points.length
    Mouse.smooth.push
      x: (Mouse.points[mpl-1].x + Mouse.points[mpl-2].x) * 0.5
      y: (Mouse.points[mpl-1].y + Mouse.points[mpl-2].y) * 0.5
    Mouse.xs = Mouse.smooth[Mouse.smooth.length-1].x
    Mouse.ys = Mouse.smooth[Mouse.smooth.length-1].y
    if Mouse.points.length > 50
      Mouse.points.shift()
      Mouse.smooth.shift()

Mouse.events.up = ->
  Mouse.up   = true
  Mouse.down = not Mouse.down

Mouse.events.down = ->
  Mouse.down = true
  Mouse.up   = not Mouse.down
  Mouse.clicks += 1

document.addEventListener 'mousemove',  Mouse.events.move, false
document.addEventListener 'touchmove',  Mouse.events.move, false
document.addEventListener 'mousedown',  Mouse.events.down, false
document.addEventListener 'touchstart', Mouse.events.down, false
document.addEventListener 'touchend',   Mouse.events.up,   false
document.addEventListener 'mouseup',    Mouse.events.up,   false

ctx.drawText = (string = "foo", x = 10, y = 10) ->
  ctx.strokeWidth = 200
  ctx.strokeStyle = "black"
  ctx.strokeText string, x, y
  ctx.fillStyle = "white"
  ctx.fillText string, x, y

ctx.clear = ->
  ctx.clearRect canvas.left, canvas.top, canvas.width, canvas.height

hsla = (h = 0, s = 100, l = 50, a = 1) ->
  "hsla(#{h}, #{s}%, #{l}%, #{a})"

Math.hyp = (a = 0, b = 0) ->
  return Math.sqrt a*a + b*b

Math.radToDeg = (rad) ->
  rad / (Math.PI/180)
Math.degToRad = (deg) ->
  deg * (Math.PI/180)

rotateTo = (rise = 0, run = 0) ->
  run     = 1 if run is 0
  slope   = (rise / run)
  tangent = Math.radToDeg Math.atan(slope)
  if run < 0
    rotation = Math.degToRad tangent - 180
  else
    rotation = Math.degToRad tangent
  return rotation

timeInc = (rate = 1) ->
  Date.now() * (1/rate)

class Square
  constructor: (@index, @x, @y) ->
  age : 0
  draw : ->
    i = @index

    size    = Math.hyp(canvas.height, canvas.width)/14
    # sizeHyp = Math.hyp @x/300, @y/300
    # height  = size * Math.sin(sizeHyp - timeInc(6400))
    # width   = height
    # x       = -width/2
    # y       = -height/2

    # circRotate1 = Math.radToDeg(rotateTo(@x/canvas.width, @y/canvas.height))
    # circRotate2 = circRotate1 - timeInc(6)%360
    # circRotate3 = circRotate2 - Math.hyp(@x, @y)*Math.sin(timeInc(6000))
    # circRotate = Math.degToRad circRotate3
    baseSize = size / Math.PI
    shrunkSize = Math.hyp Mouse.xs - @x, Mouse.ys - @y
    circSize =  Math.min baseSize, shrunkSize
    startAngle = Math.degToRad 0
    endAngle = Math.degToRad 180

    ctx.save()

    ctx.translate @x, @y

    # ctx.rotate -rotateTo @x - Mouse.xs, @y - Mouse.ys
    ctx.rotate -rotateTo Mouse.xs - @x, Mouse.ys - @y

    ctx.fillStyle = 'black'
    ctx.fillRect -circSize/4, circSize, circSize/2, -circSize

    ctx.fillStyle = 'green'
    ctx.beginPath()
    ctx.arc 0, 0, circSize/4, startAngle, endAngle, true
    ctx.closePath()
    ctx.fill()

    ctx.fillStyle = 'red'
    ctx.beginPath()
    ctx.arc 0, circSize, circSize/4, startAngle, endAngle, false
    ctx.closePath()
    ctx.fill()

    ctx.restore()

squares = []
squares.draw = ->
  for i in [0...squares.length] by 1
    squares[i].draw()

squares.counter = 0
squares.make = (x, y, limit = 180) ->
  @counter++
  index = @counter % limit
  @.push(new Square(index, x, y))
  while @.length >= limit
    @.shift()

squares.mouseDraw = (points, limit) ->
  p = points[points.length-1]
  squares.make p.x, p.y, limit

squares.makeGrid = ->
  squares.length = 0
  g = Math.floor(Math.hyp(canvas.height, canvas.width)) / 16
  inc = g * 0.75
  limit = Math.pow(canvas.max, 2) / g
  for i in [canvas.top..canvas.bottom + g] by inc
    for j in [canvas.left..canvas.right + g] by inc
      squares.make j,  i, limit
  return squares

ctx.drawLine = (points, color = 'green') ->
  p0 = points[0]
  ctx.strokeStyle = color
  ctx.beginPath()
  ctx.moveTo p0.x, p0.y
  for i in [1...points.length]
    p = points[i]
    ctx.lineTo p.x, p.y
  ctx.stroke()

ctx.decay = (hor = 0, ver = 0, spread = 0, r = 0) ->
  dx = canvas.left - spread / 2
  dy = canvas.top - spread / 2
  dw = canvas.width + spread
  dh = canvas.height + spread
  ctx.save()
  ctx.translate hor, ver
  ctx.rotate r
  ctx.drawImage canvas, dx, dy, dw, dh
  ctx.restore()

tilt = (a = 40)->
  n = Mouse.xs / canvas.width
  d = canvas.height / (Mouse.ys) * a
  n / d

ctx.imageSmoothing true

squares.makeGrid()
window.addEventListener 'resize', squares.makeGrid, false

animloop = ->
  window.requestAnimationFrame animloop
  ctx.clear()
  ctx.fillStyle = 'floralwhite'
  ctx.fillRect canvas.left, canvas.top, canvas.width, canvas.height
  # if Mouse.clicks % 3 is 0
  # else if Mouse.clicks % 3 is 1
    # ctx.decay -Mouse.xs/canvas.width, -Mouse.ys/canvas.height, 2.5, -tilt(120)
  squares.draw()
animloop()
