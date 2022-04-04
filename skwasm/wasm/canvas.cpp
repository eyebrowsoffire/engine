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
                                     float radius,
                                     SkPaint* paint) {
  makeCurrent(wrapper->context);

  wrapper->canvas->drawCircle(x, y, radius, *paint);
}

SKWASM_EXPORT void canvas_drawPath(CanvasWrapper* wrapper,
                                   SkPath* path,
                                   SkPaint* paint) {
  makeCurrent(wrapper->context);

  wrapper->canvas->drawPath(*path, *paint);
}
