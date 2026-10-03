import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stokmobile/registerPage/services/user_photo_storage.dart';

class ProfileAvatar extends StatefulWidget {
  const ProfileAvatar({super.key, required this.photo});
  final String photo;

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  Future<Uint8List>? _photo;

  void _load() {
    _photo = widget.photo.isEmpty
        ? null
        : UserPhotoStorage()
              .resolve(widget.photo)
              .then((file) => file.readAsBytes());
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photo != widget.photo) _load();
  }

  Widget _placeholder() => SvgPicture.asset(
    'assets/images/register/avatar.svg',
    width: 100,
    height: 100,
    semanticsLabel: 'Perfil sem foto',
  );

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 100,
    height: 100,
    child: ClipOval(
      child: FutureBuilder<Uint8List>(
        future: _photo,
        builder: (context, snapshot) => snapshot.hasData
            ? Image.memory(
                snapshot.data!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                semanticLabel: 'Foto de perfil',
                errorBuilder: (_, _, _) => _placeholder(),
              )
            : _placeholder(),
      ),
    ),
  );
}
