import std/[os, strutils]
import boxy, opengl, windy
import textboxes

const ProjectDir = currentSourcePath.parentDir
let window = newWindow("textee", ivec2(1280, 800))
window.size = (window.size.vec2 * window.contentScale).ivec2

var frame: int

makeContextCurrent(window)

loadExtensions()

let bxy = newBoxy()

let typeface = readTypeface( ProjectDir / "assets/DejaVuSansMono.ttf")

const BackgroundColor = color(1, 1, 1, 1)
const TextColor = color(0, 0, 0)
const FontSize = 24

var font = newFont(typeface)
font.size = FontSize
font.paint = TextColor

var textBox = newTextBox(font, window.size.x, window.size.y)
let source = readFile(currentSourcePath)
textBox.text = source
textBox.fontSize = FontSize
textBox.lineHeight = 1.6

var changed = true

window.onScroll = proc() =
  # textBox.scrollBy(window.scrollDelta.y)
  changed = true

window.onResize = proc () =
  changed = true

const Source = "source"
let lines = splitLines(source)

proc addAll() =
  let transform = translate(vec2(100, 100))
  let
    arrangement = textBox.layout(vec2(1280, 800) * 2)
    globalBounds = arrangement.computeBounds(transform).snapToPixels()
  let
    textImage = newImage(globalBounds.w.int, textBox.innerHeight)
    imageSpace = translate(-globalBounds.xy) * transform

  # textBox.setCursor(0)
  textImage.fillText(arrangement, imageSpace)
  
  bxy.addImage(Source, textImage)

# Called when it is time to draw a new frame.
window.onFrame = proc() =
  # Clear the screen and begin a new frame.

  if changed:
    changed = false

    bxy.beginFrame(window.size)

    bxy.drawRect(rect(vec2(0, 0), window.size.vec2), BackgroundColor)

    # bxy.drawImage(Source, vec2(0, textBox.scroll.y))
    let transform = translate(vec2(0, 0))
    let bounds = vec2(window.size.x.float32, textBox.fontSize * textBox.lineHeight)
    
    for i, line in lines:
      let y = i.float32 * textBox.fontSize * textBox.lineHeight
      let arrangement = typeset(@[newSpan(line, textBox.font)], bounds, vAlign = MiddleAlign)
      let globalBounds = arrangement.computeBounds(transform).snapToPixels()
      let
        textImage = newImage(bounds.x.int, bounds.y.int)
        imageSpace = translate(-globalBounds.xy) * transform

      textImage.fillText(arrangement, imageSpace)
      
      bxy.addImage($i, textImage)
      let finalY = y + textBox.scroll.y
      if finalY > window.size.y.float:
        break
      bxy.drawImage($i, vec2(0, finalY) )
    # End this frame, flushing the draw commands.
    bxy.endFrame()

    # Swap buffers displaying the new Boxy frame.
    window.swapBuffers()
    inc frame

  else:
    sleep(16)


while not window.closeRequested:
  pollEvents()