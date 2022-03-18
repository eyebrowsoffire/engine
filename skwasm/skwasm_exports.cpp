#include "third_party/skia/include/core/SkSurface.h"
#include "third_party/skia/include/gpu/GrDirectContext.h"
#include "third_party/skia/include/gpu/gl/GrGLInterface.h"
#include "third_party/skia/include/gpu/gl/GrGLTypes.h"

#include <emscripten.h>
#include <emscripten/html5_webgl.h>

struct SurfaceWrapper {
    EMSCRIPTEN_WEBGL_CONTEXT_HANDLE context;
    sk_sp<SkSurface> surface;
};

extern "C" 
EMSCRIPTEN_KEEPALIVE 
SurfaceWrapper *createSurfaceFromCanvas(const char *canvasID) {
    EmscriptenWebGLContextAttributes attributes;
    emscripten_webgl_init_context_attributes(&attributes);

    // Todo: maybe fill out attributes here

    EMSCRIPTEN_WEBGL_CONTEXT_HANDLE context = emscripten_webgl_create_context(canvasID, &attributes);
    if (!context)
    {
        return nullptr;
    }

    emscripten_webgl_make_context_current(context);

    GrDirectContext::MakeGL(GrGLMakeNativeInterface());
    return nullptr;
}

extern "C"
EMSCRIPTEN_KEEPALIVE
void destroySurface(SurfaceWrapper *surface) {
    delete surface;
}
