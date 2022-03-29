#include <GLES2/gl2.h>
#include <GLES2/gl2ext.h>
#include <emscripten.h>
#include <emscripten/html5_webgl.h>
#include <webgl/webgl1.h>
#include "third_party/skia/include/gpu/GrDirectContext.h"
#include "third_party/skia/include/gpu/gl/GrGLInterface.h"
#include "third_party/skia/include/gpu/gl/GrGLTypes.h"
#include "wrappers.h"

using namespace Skwasm;

extern "C" EMSCRIPTEN_KEEPALIVE SurfaceWrapper*
createSurfaceFromCanvas(const char* canvasID, int width, int height) {
  EmscriptenWebGLContextAttributes attributes;
  emscripten_webgl_init_context_attributes(&attributes);

  // Todo: maybe fill out attributes here
  attributes.alpha = true;
  attributes.depth = true;
  attributes.stencil = true;
  attributes.antialias = false;
  attributes.premultipliedAlpha = true;
  attributes.preserveDrawingBuffer = 0;
  attributes.powerPreference = EM_WEBGL_POWER_PREFERENCE_DEFAULT;
  attributes.failIfMajorPerformanceCaveat = false;
  attributes.enableExtensionsByDefault = true;
  attributes.explicitSwapControl = false;
  attributes.renderViaOffscreenBackBuffer = false;
  attributes.majorVersion = 2;

  EMSCRIPTEN_WEBGL_CONTEXT_HANDLE context =
      emscripten_webgl_create_context(canvasID, &attributes);
  if (!context) {
    return nullptr;
  }

  makeCurrent(context);

  sk_sp<GrDirectContext> grContext =
      GrDirectContext::MakeGL(GrGLMakeNativeInterface());

  // WebGL should already be clearing the color and stencil buffers, but do it
  // again here to ensure Skia receives them in the expected state.
  emscripten_glBindFramebuffer(GL_FRAMEBUFFER, 0);
  emscripten_glClearColor(0, 0, 0, 0);
  emscripten_glClearStencil(0);
  emscripten_glClear(GL_COLOR_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
  grContext->resetContext(kRenderTarget_GrGLBackendState |
                          kMisc_GrGLBackendState);

  // The on-screen canvas is FBO 0. Wrap it in a Skia render target so Skia can
  // render to it.
  GrGLFramebufferInfo info;
  info.fFBOID = 0;
  info.fFormat = GL_RGBA8_OES;

  GrGLint sampleCnt;
  emscripten_glGetIntegerv(GL_SAMPLES, &sampleCnt);

  GrGLint stencil;
  emscripten_glGetIntegerv(GL_STENCIL_BITS, &stencil);

  GrBackendRenderTarget target(width, height, sampleCnt, stencil, info);
  sk_sp<SkSurface> surface(SkSurface::MakeFromBackendRenderTarget(
      grContext.get(), target, kBottomLeft_GrSurfaceOrigin,
      kRGBA_8888_SkColorType, SkColorSpace::MakeSRGB(), nullptr));
  return new SurfaceWrapper{context, grContext, surface};
}

extern "C" EMSCRIPTEN_KEEPALIVE void destroySurface(SurfaceWrapper* wrapper) {
  delete wrapper;
}

extern "C" EMSCRIPTEN_KEEPALIVE CanvasWrapper* surface_getCanvas(
    SurfaceWrapper* wrapper) {
  makeCurrent(wrapper->context);
  return new CanvasWrapper{wrapper->context, wrapper->surface->getCanvas()};
}

extern "C" EMSCRIPTEN_KEEPALIVE void surface_flush(SurfaceWrapper* wrapper) {
  makeCurrent(wrapper->context);
  wrapper->surface->flush();
}
