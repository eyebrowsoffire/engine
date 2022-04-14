import 'package:skwasm/src/raw/raw_picture.dart';

import 'canvas.dart';
import 'image.dart';

class Picture {
  final PictureHandle _handle;

  PictureHandle get handle => _handle;

  Picture.fromHandle(this._handle);

  Future<Image> toImage(int width, int height) {
    throw UnimplementedError();
  }

  void dispose() {
    picture_dispose(_handle);
  }

  int get approximateBytesUsed {
    return picture_approxmateBytesUsed(_handle).toIntSigned();
  }
}

class PictureRecorder {
  final PictureRecorderHandle _handle;

  PictureRecorderHandle get handle => _handle;

  factory PictureRecorder() {
    return PictureRecorder._fromHandle(pictureRecorder_create());
  }

  PictureRecorder._fromHandle(this._handle);

  void delete() {
    pictureRecorder_destroy(_handle);
  }

  Picture endRecording() {
    return Picture.fromHandle(pictureRecorder_endRecording(_handle));
  }
}
