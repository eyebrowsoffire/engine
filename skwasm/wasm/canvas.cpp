#include <emscripten.h>
#include "export.h"
#include "wrappers.h"

using namespace Skwasm;

SKWASM_EXPORT void canvas_release(CanvasWrapper* wrapper) {
  delete wrapper;
}

SKWASM_EXPORT void canvas_drawCircle(CanvasWrapper* wrapper,
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
