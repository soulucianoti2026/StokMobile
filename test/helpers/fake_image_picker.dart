import 'package:image_picker/image_picker.dart';

class FakeImagePicker extends ImagePicker {
  XFile? selected;
  Object? failure;
  ImageSource? lastSource;
  LostDataResponse lost = LostDataResponse.empty();

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    lastSource = source;
    if (failure != null) throw failure!;
    return selected;
  }

  @override
  Future<LostDataResponse> retrieveLostData() async => lost;
}
