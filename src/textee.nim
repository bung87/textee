import std/[os, enumerate]
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
const FontSize = 28

var font = newFont(typeface)
font.size = FontSize
font.paint = TextColor

var textBox = newTextBox(font, window.size.x, window.size.y)
let source = readFile(currentSourcePath)
textBox.text = source
textBox.fontSize = FontSize

window.onScroll = proc() =
  textBox.scrollBy(window.scrollDelta.y)
  # textBox.adjustScroll()

# Called when it is time to draw a new frame.
window.onFrame = proc() =
  # Clear the screen and begin a new frame.
  bxy.beginFrame(window.size)
  
  bxy.drawRect(rect(vec2(0, 0), window.size.vec2), BackgroundColor)
  
  let transform = translate(vec2(100, 100))
  let
    arrangement = textBox.layout(vec2(1280, 800) * 2)
    globalBounds = arrangement.computeBounds(transform).snapToPixels()
  let
    textImage = newImage(globalBounds.w.int, textBox.innerHeight)
    imageSpace = translate(-globalBounds.xy) * transform
  
  # textBox.setCursor(0)
  textImage.fillText(arrangement, imageSpace)
  let imageKey = "source"
  bxy.addImage(imageKey, textImage)
  bxy.drawImage(imageKey, vec2(0, textBox.scroll.y))
  
  # End this frame, flushing the draw commands.
  bxy.endFrame()
  # Swap buffers displaying the new Boxy frame.
  window.swapBuffers()
  inc frame

while not window.closeRequested:
  pollEvents()
