#include "export.h"
#include "third_party/skia/include/core/SkPath.h"
#include <emscripten.h>

SKWASM_EXPORT SkPath *path_create()
{
    return new SkPath();
}

SKWASM_EXPORT void path_destroy(SkPath *path)
{
    delete path;
}

SKWASM_EXPORT void path_setFillType(SkPath *path, SkPathFillType fillType) {
    path->setFillType(fillType);
}

SKWASM_EXPORT void addArc(SkPath *path, SkRect *oval, SkScalar startAngle, SkScalar sweepAngle) {
    path->addArc(*oval, startAngle, sweepAngle);
}

SKWASM_EXPORT void addOval(SkPath *path, SkRect *oval, bool counterClockwise, unsigned startPointIndex) {
    path->addOval(*oval, counterClockwise ? SkPathDirection::kCCW : SkPathDirection::kCW, startPointIndex);
}

SKWASM_EXPORT void addPath(SkPath *path, SkPath *other, SkMatrix *matrix, bool extendPath) {
    path->addPath(*other, *matrix, extendPath ? SkPath::kExtend_AddPathMode : SkPath::kAppend_AddPathMode);
}
