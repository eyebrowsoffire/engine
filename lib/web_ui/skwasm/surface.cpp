// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "surface.h"
#include "render_strategy.h"

#include <algorithm>

using namespace Skwasm;

Surface::Surface() {
  assert(emscripten_is_main_browser_thread());

  pthread_attr_t attr;
  pthread_attr_init(&attr);
  pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);

  pthread_create(
      &_thread, &attr,
      [](void* context) -> void* {
        static_cast<Surface*>(context)->_runWorker();
        return nullptr;
      },
      this);
  // Listen to messages from the worker
  skwasm_registerMessageListener(_thread);

  // Synchronize the time origin for the worker thread
  skwasm_syncTimeOriginForThread(_thread);
}

// Main thread only
void Surface::dispose() {
  assert(emscripten_is_main_browser_thread());
  emscripten_dispatch_to_thread(_thread, EM_FUNC_SIG_VI,
                                reinterpret_cast<void*>(fDispose), nullptr,
                                this);
}

// Main thread only
uint32_t Surface::renderPictures(Picture** pictures, int count) {
  assert(emscripten_is_main_browser_thread());
  uint32_t callbackId = ++_currentCallbackId;
  std::unique_ptr<sk_sp<Picture>[]> picturePointers =
      std::make_unique<sk_sp<Picture>[]>(count);
  for (int i = 0; i < count; i++) {
    picturePointers[i] = sk_ref_sp(pictures[i]);
  }

  // Releasing picturePointers here and will recreate the unique_ptr on the
  // other thread See surface_renderPicturesOnWorker
  skwasm_dispatchRenderPictures(_thread, this, picturePointers.release(), count,
                                callbackId);
  return callbackId;
}

// Main thread only
uint32_t Surface::rasterizeImage(Image* image, ImageByteFormat format) {
  assert(emscripten_is_main_browser_thread());
  uint32_t callbackId = ++_currentCallbackId;
  image->ref();

  emscripten_dispatch_to_thread(_thread, EM_FUNC_SIG_VIIII,
                                reinterpret_cast<void*>(fRasterizeImage),
                                nullptr, this, image, format, callbackId);
  return callbackId;
}

std::unique_ptr<TextureSourceWrapper> Surface::createTextureSourceWrapper(
    SkwasmObject textureSource) {
  return std::unique_ptr<TextureSourceWrapper>(
      new TextureSourceWrapper(_thread, textureSource));
}

// Main thread only
void Surface::setCallbackHandler(CallbackHandler* callbackHandler) {
  assert(emscripten_is_main_browser_thread());
  _callbackHandler = callbackHandler;
}

// Worker thread only
void Surface::_runWorker() {
  _init();
  emscripten_exit_with_live_runtime();
}

// Worker thread only
void Surface::_init() {
  // Listen to messages from the main thread
  skwasm_registerMessageListener(0);
  _glContext = skwasm_createOffscreenCanvas(256, 256);
  if (!_glContext) {
    printf("Failed to create context!\n");
    return;
  }

  makeCurrent(_glContext);
  emscripten_webgl_enable_extension(_glContext, "WEBGL_debug_renderer_info");

  _grContext = createGraphicsContext();

  // WebGL should already be clearing the color and stencil buffers, but do it
  // again here to ensure Skia receives them in the expected state.
  emscripten_glBindFramebuffer(GL_FRAMEBUFFER, 0);
  emscripten_glClearColor(0, 0, 0, 0);
  emscripten_glClearStencil(0);
  emscripten_glClear(GL_COLOR_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
  resetGraphicsContext(_grContext);

  emscripten_glGetIntegerv(GL_SAMPLES, &_sampleCount);
  emscripten_glGetIntegerv(GL_STENCIL_BITS, &_stencil);
}

// Worker thread only
void Surface::_dispose() {
  delete this;
}

// Worker thread only
void Surface::_resizeCanvasToFit(int width, int height) {
  if (!_surface || width > _canvasWidth || height > _canvasHeight) {
    _canvasWidth = std::max(width, _canvasWidth);
    _canvasHeight = std::max(height, _canvasHeight);
    _recreateSurface();
  }
}

// Worker thread only
void Surface::_recreateSurface() {
  makeCurrent(_glContext);
  skwasm_resizeCanvas(_glContext, _canvasWidth, _canvasHeight);
  _surface = createGraphicsSurface(_grContext, _canvasWidth, _canvasHeight,
                                   _sampleCount, _stencil);
}

// Worker thread only
void Surface::renderPicturesOnWorker(sk_sp<Picture>* pictures,
                                     int pictureCount,
                                     uint32_t callbackId,
                                     double rasterStart) {
  // This is populated by the `captureImageBitmap` call the first time it is
  // passed in.
  SkwasmObject imagePromiseArray = __builtin_wasm_ref_null_extern();
  for (int i = 0; i < pictureCount; i++) {
    sk_sp<Picture> picture = pictures[i];
    Rect pictureRect = picture->cullRect();
    IRect roundedOutRect;
    pictureRect.roundOut(&roundedOutRect);
    _resizeCanvasToFit(roundedOutRect.width(), roundedOutRect.height());
    makeCurrent(_glContext);
    drawPictureToSurface(picture.get(), _surface.get(), -roundedOutRect.fLeft,
                         -roundedOutRect.fTop);
    _grContext->flush(_surface.get());
    imagePromiseArray =
        skwasm_captureImageBitmap(_glContext, roundedOutRect.width(),
                                  roundedOutRect.height(), imagePromiseArray);
  }
  skwasm_resolveAndPostImages(this, imagePromiseArray, rasterStart, callbackId);
}

void Surface::_rasterizeImage(Image* image,
                              ImageByteFormat format,
                              uint32_t callbackId) {
  // We handle PNG encoding with browser APIs so that we can omit libpng from
  // skia to save binary size.
  assert(format != ImageByteFormat::png);
  sk_sp<SkData> data;
  SkAlphaType alphaType = format == ImageByteFormat::rawStraightRgba
                              ? SkAlphaType::kUnpremul_SkAlphaType
                              : SkAlphaType::kPremul_SkAlphaType;
  ImageInfo info = ImageInfo::Make(image->width(), image->height(),
                                   ColorType::kRGBA_8888_SkColorType, alphaType,
                                   ColorSpace::MakeSRGB());
  size_t bytesPerRow = 4 * image->width();
  size_t byteSize = info.computeByteSize(bytesPerRow);
  data = SkData::MakeUninitialized(byteSize);
  uint8_t* pixels = reinterpret_cast<uint8_t*>(data->writable_data());
  bool success = false;  // image->readPixels(_grContext.get(),
                         // image->imageInfo(), pixels, bytesPerRow, 0, 0);
  if (!success) {
    printf("Failed to read pixels from image!\n");
    data = nullptr;
  }
  emscripten_async_run_in_main_runtime_thread(
      EM_FUNC_SIG_VIII, fOnRasterizeComplete, this, data.release(), callbackId);
}

void Surface::_onRasterizeComplete(SkData* data, uint32_t callbackId) {
  _callbackHandler(callbackId, data, __builtin_wasm_ref_null_extern());
}

// Main thread only
void Surface::onRenderComplete(uint32_t callbackId, SkwasmObject imageBitmap) {
  assert(emscripten_is_main_browser_thread());
  _callbackHandler(callbackId, nullptr, imageBitmap);
}

void Surface::fDispose(Surface* surface) {
  surface->_dispose();
}

void Surface::fOnRasterizeComplete(Surface* surface,
                                   SkData* imageData,
                                   uint32_t callbackId) {
  surface->_onRasterizeComplete(imageData, callbackId);
}

void Surface::fRasterizeImage(Surface* surface,
                              Image* image,
                              ImageByteFormat format,
                              uint32_t callbackId) {
  surface->_rasterizeImage(image, format, callbackId);
  image->unref();
}

SKWASM_EXPORT Surface* surface_create() {
  return new Surface();
}

SKWASM_EXPORT unsigned long surface_getThreadId(Surface* surface) {
  return surface->getThreadId();
}

SKWASM_EXPORT void surface_setCallbackHandler(
    Surface* surface,
    Surface::CallbackHandler* callbackHandler) {
  surface->setCallbackHandler(callbackHandler);
}

SKWASM_EXPORT void surface_destroy(Surface* surface) {
  surface->dispose();
}

SKWASM_EXPORT uint32_t surface_renderPictures(Surface* surface,
                                              Picture** pictures,
                                              int count) {
  return surface->renderPictures(pictures, count);
}

SKWASM_EXPORT void surface_renderPicturesOnWorker(Surface* surface,
                                                  sk_sp<Picture>* pictures,
                                                  int pictureCount,
                                                  uint32_t callbackId,
                                                  double rasterStart) {
  // This will release the pictures when they leave scope.
  std::unique_ptr<sk_sp<Picture>[]> picturesPointer =
      std::unique_ptr<sk_sp<Picture>[]>(pictures);
  surface->renderPicturesOnWorker(pictures, pictureCount, callbackId,
                                  rasterStart);
}

SKWASM_EXPORT uint32_t surface_rasterizeImage(Surface* surface,
                                              Image* image,
                                              ImageByteFormat format) {
  return surface->rasterizeImage(image, format);
}

// This is used by the skwasm JS support code to call back into C++ when the
// we finish creating the image bitmap, which is an asynchronous operation.
SKWASM_EXPORT void surface_onRenderComplete(Surface* surface,
                                            uint32_t callbackId,
                                            SkwasmObject imageBitmap) {
  return surface->onRenderComplete(callbackId, imageBitmap);
}
