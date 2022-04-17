#include <GLES2/gl2.h>
#include <GLES2/gl2ext.h>
#include <emscripten.h>
#include <emscripten/html5_webgl.h>
#include <emscripten/threading.h>
#include <webgl/webgl1.h>
#include "export.h"
#include "third_party/skia/include/core/SkCanvas.h"
#include "third_party/skia/include/core/SkPicture.h"
#include "third_party/skia/include/core/SkSurface.h"
#include "third_party/skia/include/gpu/GrDirectContext.h"
#include "third_party/skia/include/gpu/gl/GrGLInterface.h"
#include "third_party/skia/include/gpu/gl/GrGLTypes.h"
#include "wrappers.h"

using namespace Skwasm;

namespace {
class Surface {
 public:
  Surface(const char* canvasID) : _canvasID(canvasID) {
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    emscripten_pthread_attr_settransferredcanvases(&attr, _canvasID.c_str());

    pthread_mutex_init(&_mutex, nullptr);
    pthread_cond_init(&_condition, nullptr);
    pthread_create(
        &_thread, &attr,
        [](void* context) -> void* {
          static_cast<Surface*>(context)->_runWorker();
          return nullptr;
        },
        this);
    pthread_detach(_thread);
  }

  void dispose() {
    pthread_mutex_lock(&_mutex);
    _exit = true;

    pthread_cond_broadcast(&_condition);
  }

  void setCanvasSize(int width, int height) {
    pthread_mutex_lock(&_mutex);

    _desiredCanvasWidth = width;
    _desiredCanvasHeight = height;

    pthread_mutex_unlock(&_mutex);
    pthread_cond_broadcast(&_condition);
  }

  void renderPicture(sk_sp<SkPicture> picture) {
    pthread_mutex_lock(&_mutex);

    // Do a swap so that if there is an old picture, it is not freed inside the
    // lock.
    std::swap(picture, _queuedPicture);

    pthread_mutex_unlock(&_mutex);
    pthread_cond_broadcast(&_condition);
  }

 private:
  void _runWorker() {
    _init();
    for (;;) {
      bool shouldExit = false;
      bool recreateSurface = false;
      sk_sp<SkPicture> picture = nullptr;
      pthread_mutex_lock(&_mutex);
      for (;;) {
        shouldExit = _exit;
        if (_desiredCanvasWidth != _canvasWidth ||
            _desiredCanvasHeight != _canvasHeight) {
          recreateSurface = true;
          _canvasWidth = _desiredCanvasWidth;
          _canvasHeight = _desiredCanvasHeight;
        }

        std::swap(picture, _queuedPicture);

        if (!recreateSurface && !picture && !shouldExit) {
          pthread_cond_wait(&_condition, &_mutex);
        } else {
          pthread_mutex_unlock(&_mutex);
          break;
        }
      }

      if (shouldExit) {
        pthread_mutex_destroy(&_mutex);
        pthread_cond_destroy(&_condition);
        delete this;
        return;
      }

      if (recreateSurface) {
        _recreateSurface();
      }

      if (picture) {
        _renderPicture(picture.get());
      }
    }
  }

  void _init() {
    EmscriptenWebGLContextAttributes attributes;
    emscripten_webgl_init_context_attributes(&attributes);

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
    attributes.renderViaOffscreenBackBuffer = true;
    attributes.majorVersion = 2;

    _glContext =
        emscripten_webgl_create_context(_canvasID.c_str(), &attributes);
    if (!_glContext) {
      printf("Failed to create context!\n");
      return;
    }

    makeCurrent(_glContext);

    _grContext = GrDirectContext::MakeGL(GrGLMakeNativeInterface());

    // WebGL should already be clearing the color and stencil buffers, but do it
    // again here to ensure Skia receives them in the expected state.
    emscripten_glBindFramebuffer(GL_FRAMEBUFFER, 0);
    emscripten_glClearColor(0, 0, 0, 0);
    emscripten_glClearStencil(0);
    emscripten_glClear(GL_COLOR_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
    _grContext->resetContext(kRenderTarget_GrGLBackendState |
                             kMisc_GrGLBackendState);

    // The on-screen canvas is FBO 0. Wrap it in a Skia render target so Skia
    // can render to it.
    _fbInfo.fFBOID = 0;
    _fbInfo.fFormat = GL_RGBA8_OES;

    emscripten_glGetIntegerv(GL_SAMPLES, &_sampleCount);
    emscripten_glGetIntegerv(GL_STENCIL_BITS, &_stencil);
  }

  void _recreateSurface() {
    GrBackendRenderTarget target(_canvasWidth, _canvasHeight, _sampleCount,
                                 _stencil, _fbInfo);
    _surface = SkSurface::MakeFromBackendRenderTarget(
        _grContext.get(), target, kBottomLeft_GrSurfaceOrigin,
        kRGBA_8888_SkColorType, SkColorSpace::MakeSRGB(), nullptr);
  }

  void _renderPicture(const SkPicture* picture) {
    if (!_surface) {
      printf("Can't render picture with no surface.\n");
      return;
    }

    auto canvas = _surface->getCanvas();
    canvas->drawPicture(picture);
    _surface->flush();

    emscripten_unwind_to_js_event_loop();
  }

  std::string _canvasID;

  int _desiredCanvasWidth = 0;
  int _desiredCanvasHeight = 0;
  int _canvasWidth = 0;
  int _canvasHeight = 0;
  bool _exit = false;

  sk_sp<SkPicture> _queuedPicture = nullptr;

  EMSCRIPTEN_WEBGL_CONTEXT_HANDLE _glContext = 0;
  sk_sp<GrDirectContext> _grContext = nullptr;
  sk_sp<SkSurface> _surface = nullptr;
  GrGLFramebufferInfo _fbInfo;
  GrGLint _sampleCount;
  GrGLint _stencil;

  pthread_mutex_t _mutex;
  pthread_cond_t _condition;
  pthread_t _thread;
};
}  // namespace

SKWASM_EXPORT Surface* surface_createFromCanvas(const char* canvasID) {
  return new Surface(canvasID);
}

SKWASM_EXPORT void surface_destroy(Surface* surface) {
  surface->dispose();
}

SKWASM_EXPORT void surface_setCanvasSize(Surface* surface,
                                         int width,
                                         int height) {
  surface->setCanvasSize(width, height);
}

SKWASM_EXPORT void surface_renderPicture(Surface* surface, SkPicture* picture) {
  surface->renderPicture(sk_ref_sp(picture));
}
