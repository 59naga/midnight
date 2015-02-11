NWGUI= window.require 'nw.gui'

config= require('./package.json').config
noiseSize= config.noiseSize
noiseVolume= config.noiseVolume

NWGUI.Window.get().on 'document-end',-> main()
main= ->
  nwgui= NWGUI.Window.get()

  window= nwgui.window
  document= window.document

  nwgui.enterFullscreen()
  nwgui.resizeTo window.screen.width,window.screen.height
  nwgui.show()

  targetContext= document.createElement('canvas').getContext('2d')
  targetContext.canvas.setAttribute 'class','animated fadeIn'
  document.body.appendChild targetContext.canvas

  exit_keys= ['Ctrl+w','Ctrl+q']# win/mac
  for key in exit_keys
    NWGUI.App.registerGlobalHotKey new NWGUI.Shortcut
      key: key
      active: ->
        T('perc',r:500,T('sin',freq:64,mul:noiseVolume*1.5),T('sin',freq:128,mul:noiseVolume*1.5))
        .on 'ended',->this.pause()
        .bang().play()
        
        targetContext.canvas.setAttribute 'class','shutdown'
        window.setTimeout ->
          nwgui= NWGUI.Window.get()
          nwgui.close(true)
        ,1000

  window.postMessage 'midnight:initialized','*'

  T= require './lib/timbre.nw.js'
  T('noise').set('mul',noiseVolume).play()

  context= document.createElement('canvas').getContext('2d')
  window.requestAnimationFrame -> noise()
  noise= ->
    if targetContext.canvas.width isnt window.screen.width or targetContext.canvas.height isnt window.screen.height
      targetContext.canvas.width= window.screen.width
      targetContext.canvas.height= window.screen.height
      targetContext.webkitImageSmoothingEnabled= false
      context.canvas.width= window.screen.width/noiseSize
      context.canvas.height= window.screen.height/noiseSize

      window.postMessage 'midnight:resized','*'

    image= context.createImageData context.canvas.width,context.canvas.height
    i= 0
    for x in [0...context.canvas.width]
      for y in [0...context.canvas.height]
        value= parseInt(30+225*Math.random()*.5)
        image.data[i]= value
        image.data[i+1]= value
        image.data[i+2]= value
        image.data[i+3]= 255
        i+= 4

    context.putImageData(image,0,0)
    targetContext.drawImage(context.canvas,0,0,window.screen.width,window.screen.height)

    window.requestAnimationFrame -> noise()