// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:ui/src/engine.dart';
import 'package:ui/ui.dart' as ui;

const String kCanvasContainerTag = 'flt-canvas-container';
const String kPlatformViewSliceContainerTag = 'flt-platform-view-slice';
const String kPlatformViewContainerTag = 'flt-platform-view-container';

sealed class SliceContainer {
  DomElement get container;

  void updateContents();
}

final class PictureSliceContainer extends SliceContainer {
  factory PictureSliceContainer(ui.Rect bounds) {
    final DomElement container = domDocument.createElement(kCanvasContainerTag);
    final DomCanvasElement canvas = createDomCanvasElement(
      width: bounds.width.toInt(),
      height: bounds.height.toInt()
    );
    container.appendChild(canvas);
    return PictureSliceContainer._(bounds, container, canvas);
  }

  PictureSliceContainer._(this._bounds, this.container, this.canvas);

  ui.Rect _bounds;
  bool _dirty = true;

  ui.Rect get bounds => _bounds;
  set bounds(ui.Rect bounds) {
    if (_bounds != bounds) {
      _bounds = bounds;
      _dirty = true;
    }
  }

  @override
  void updateContents() {
    if (_dirty) {
      _dirty = false;
      final DomCSSStyleDeclaration style = canvas.style;
      final double logicalWidth = bounds.width / window.devicePixelRatio;
      final double logicalHeight = bounds.height / window.devicePixelRatio;
      style.width = '${logicalWidth}px';
      style.height = '${logicalHeight}px';
      style.position = 'absolute';
      style.left = '${bounds.left}px';
      style.top = '${bounds.top}px';
      canvas.width = bounds.width;
      canvas.height = bounds.height;
    }
  }

  void renderBitmap(DomImageBitmap bitmap) {
    final DomCanvasRenderingContextBitmapRenderer ctx = canvas.contextBitmapRenderer;
    ctx.transferFromImageBitmap(bitmap);
  }

  @override
  final DomElement container;
  final DomCanvasElement canvas;
}

final class PlatformViewSliceContainer extends SliceContainer {
  PlatformViewSliceContainer(this._views);

  List<PlatformView> _views;
  Map<int, DomElement> _slots = <int, DomElement>{};

  @override
  final DomElement container = domDocument.createElement(kPlatformViewSliceContainerTag);

  set views(List<PlatformView> views) {
    if (_views != views) {
      _views = views;
    }
  }

  @override
  void updateContents() {
    DomElement? currentContainer = container.firstElementChild;
    final Map<int, DomElement> newSlots = <int, DomElement>{};
    for (final PlatformView view in _views) {
      final DomElement platformView = _slots[view.viewId] ?? createPlatformViewSlot(view.viewId);
      newSlots[view.viewId] = platformView;
      final DomElement viewContainer;
      if (currentContainer != null && currentContainer.firstElementChild == platformView) {
        viewContainer = currentContainer;
        currentContainer = currentContainer.nextElementSibling;
      } else {
        viewContainer = domDocument.createElement(kPlatformViewContainerTag);
        if (currentContainer != null) {
          container.insertBefore(viewContainer, currentContainer);
        } else {
          container.appendChild(viewContainer);
        }
        viewContainer.appendChild(platformView);
      }
      final DomCSSStyleDeclaration style = viewContainer.style;
      final double logicalWidth = view.size.width / window.devicePixelRatio;
      final double logicalHeight = view.size.height / window.devicePixelRatio;
      style.width = '${logicalWidth}px';
      style.height = '${logicalHeight}px';
      style.position = 'absolute';

      final ui.Offset? offset = view.styling.position.offset;
      style.left = '${offset?.dx ?? 0}px';
      style.top = '${offset?.dy ?? 0}px';

      final Matrix4? transform = view.styling.position.transform;
      style.transform = transform != null ? float64ListToCssTransform3d(transform.storage) : '';
      style.opacity = view.styling.opacity != 1.0 ? '${view.styling.opacity}' : '';
      // TODO(jacksongardner): Implement clip styling for platform views
    }

    while (currentContainer != null) {
      final DomElement? next = currentContainer.nextElementSibling;
      currentContainer.remove();
      currentContainer = next;
    }

    _slots = newSlots;
  }
}

abstract class PictureRenderer {
  FutureOr<DomImageBitmap> renderPicture(ScenePicture picture);
}

class EngineSceneView {
  factory EngineSceneView(PictureRenderer pictureRenderer) {
    final DomElement sceneElement = createDomElement('flt-scene');
    return EngineSceneView._(pictureRenderer, sceneElement);
  }

  EngineSceneView._(this.pictureRenderer, this.sceneElement);

  final PictureRenderer pictureRenderer;
  final DomElement sceneElement;

  List<SliceContainer> containers = <SliceContainer>[];

  int queuedRenders = 0;
  static const int kMaxQueuedRenders = 3;

  Future<void> renderScene(EngineScene scene) async {
    if (queuedRenders >= kMaxQueuedRenders) {
      return;
    }
    queuedRenders += 1;

    scene.beginRender();
    final List<LayerSlice> slices = scene.rootLayer.slices;
    final Iterable<Future<DomImageBitmap?>> renderFutures = slices.map(
      (LayerSlice slice) async => switch (slice) {
          PlatformViewSlice() => null,
          PictureSlice() => pictureRenderer.renderPicture(slice.picture),
        }
    );
    final List<DomImageBitmap?> renderedBitmaps = await Future.wait(renderFutures);
    final List<SliceContainer?> reusableContainers = List<SliceContainer?>.from(containers);
    final List<SliceContainer> newContainers = <SliceContainer>[];
    for (int i = 0; i < slices.length; i++) {
      final LayerSlice slice = slices[i];
      switch (slice) {
        case PictureSlice():
          PictureSliceContainer? container;
          for (int j = 0; j < reusableContainers.length; j++) {
            final SliceContainer? candidate = reusableContainers[j];
            if (candidate is PictureSliceContainer) {
              container = candidate;
              reusableContainers[j] = null;
              break;
            }
          }

          if (container != null) {
            container.bounds = slice.picture.cullRect;
          } else {
            container = PictureSliceContainer(slice.picture.cullRect);
          }
          container.updateContents();
          container.renderBitmap(renderedBitmaps[i]!);
          newContainers.add(container);

        case PlatformViewSlice():
          PlatformViewSliceContainer? container;
          for (int j = 0; j < reusableContainers.length; j++) {
            final SliceContainer? candidate = reusableContainers[j];
            if (candidate is PlatformViewSliceContainer) {
              container = candidate;
              reusableContainers[j] = null;
              break;
            }
          }
          if (container != null) {
            container.views = slice.views;
          } else {
            container = PlatformViewSliceContainer(slice.views);
          }
          container.updateContents();
          newContainers.add(container);
      }
    }

    containers = newContainers;

    DomElement? currentElement = sceneElement.firstElementChild;
    for (final SliceContainer container in containers) {
      if (currentElement == null) {
        sceneElement.appendChild(container.container);
      } else if (currentElement == container.container) {
        currentElement = currentElement.nextElementSibling;
      } else {
        sceneElement.insertBefore(container.container, currentElement);
      }
    }

    // Remove any other unused containers
    while (currentElement != null) {
      final DomElement? sibling = currentElement.nextElementSibling;
      sceneElement.removeChild(currentElement);
      currentElement = sibling;
    }
    scene.endRender();

    queuedRenders -= 1;
  }
}
