NWGUI= window.require 'nw.gui'

describe 'midnight',->
  window= null
  document= null

  beforeEach (resized)->
    nwwin= NWGUI.Window.get()
    nwwin.reload()
    nwwin.on 'document-end',->
      nwwin= NWGUI.Window.get()
      window= nwwin.window
      document= window.document
      window.addEventListener 'message',(event)->
        if event.data is 'midnight:resized'
          resized()

  it 'fullscreen width',->
    canvas= document.querySelector 'canvas'

    expect(canvas.width).toEqual(window.screen.width)

  it 'fullscreen height',->
    canvas= document.querySelector 'canvas'

    expect(canvas.height).toEqual(window.screen.height)
