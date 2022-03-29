#include <emscripten.h>
#include "wrappers.h"

using namespace Skwasm;

extern "C" EMSCRIPTEN_KEEPALIVE void canvas_release(CanvasWrapper* wrapper) {
  delete wrapper;
}

extern "C" EMSCRIPTEN_KEEPALIVE void canvas_drawCircle(CanvasWrapper* wrapper,
                                                       float x,
                                                       float y,
                                                       float radius) {
  makeCurrent(wrapper->context);

  SkPaint p;
  p.setColor(SK_ColorRED);
  p.setAntiAlias(true);
  p.setStyle(SkPaint::kFill_Style);
  p.setStrokeWidth(10);

  wrapper->canvas->drawCircle(x, y, radius, p);
}
