import std/[os, enumerate]
import boxy, opengl, windy

const ProjectDir = currentSourcePath.parentDir
let window = newWindow("textee", ivec2(1280, 800))
window.size = (window.size.vec2 * window.contentScale).ivec2

# var PIXEL_STEP  = 10
var LINE_HEIGHT = 40
# var PAGE_HEIGHT = window.size.y
var scrollOffset = vec2(0, 0)
var gOffsetY: float32
var frame: int

window.onScroll = proc() =

  scrollOffset.y = window.scrollDelta.y * LINE_HEIGHT.float32

makeContextCurrent(window)

loadExtensions()

let bxy = newBoxy()



let typeface = readTypeface( ProjectDir / "assets/DejaVuSansMono.ttf")

proc drawText(
  bxy: Boxy,
  imageKey: string,
  transform: Mat3,
  typeface: Typeface,
  text: string,
  size: float32,
  color: Color
) =
  var font = newFont(typeface)
  font.size = size
  font.paint = color
  let
    arrangement = typeset(@[newSpan(text, font)], bounds = vec2(1280, 800) * 2)
    globalBounds = arrangement.computeBounds(transform).snapToPixels()
  let
    textImage = newImage(globalBounds.w.int, globalBounds.h.int)
    imageSpace = translate(-globalBounds.xy) * transform
  textImage.fillText(arrangement, imageSpace)

  bxy.addImage(imageKey, textImage)
  bxy.drawImage(imageKey, globalBounds.xy)

const BackgroundColor = color(1, 1, 1, 1)
const TextColor = color(0, 0, 0)
const FontSize = 28
# Called when it is time to draw a new frame.
window.onFrame = proc() =
  # Clear the screen and begin a new frame.
  bxy.beginFrame(window.size)
  bxy.drawRect(rect(vec2(0, 0), window.size.vec2), BackgroundColor)
  var yOffset: float32
  gOffsetY = gOffsetY + scrollOffset.y

  for i, line in enumerate(currentSourcePath.lines):
    if line.len == 0:
      continue
    yOffset = float32(FontSize * i) + scrollOffset.y

    bxy.drawText(
      $i,
      translate(vec2(100, yOffset)),
      typeface,
      line,
      FontSize,
      TextColor
    )
  # End this frame, flushing the draw commands.
  bxy.endFrame()
  # Swap buffers displaying the new Boxy frame.
  window.swapBuffers()
  inc frame

while not window.closeRequested:
  pollEvents()