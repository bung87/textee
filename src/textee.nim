import std/[os]
import boxy, opengl, windy

const ProjectDir = currentSourcePath.parentDir
let window = newWindow("textee", ivec2(1280, 800))
window.size = (window.size.vec2 * window.contentScale).ivec2

makeContextCurrent(window)

loadExtensions()

let bxy = newBoxy()

var frame: int

let typeface = readTypeface( ProjectDir / "assets/DejaVuSansMono.ttf")
# let source = readFile(currentSourcePath)

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
    arrangement = typeset(@[newSpan(text, font)], bounds = vec2(1280, 800))
    globalBounds = arrangement.computeBounds(transform).snapToPixels()
  echo globalBounds
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
  var i = 0
  for line in currentSourcePath.lines:
    bxy.drawText(
      $i,
      translate(vec2(100, 100)),
      typeface,
      line,
      FontSize,
      TextColor
    )
    inc i

  # End this frame, flushing the draw commands.
  bxy.endFrame()
  # Swap buffers displaying the new Boxy frame.
  window.swapBuffers()
  inc frame

while not window.closeRequested:
  pollEvents()