import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProductPhoto extends StatelessWidget {
  const ProductPhoto({super.key, required this.photo, this.size = 80});
  final String photo;
  final double size;

  @override
  Widget build(BuildContext context) {
    Widget fallback() =>
        Image.asset('assets/images/app_icon.png', fit: BoxFit.cover);
    Widget image;
    try {
      image = photo.startsWith('data:image/')
          ? Image.memory(
              base64Decode(photo.substring(photo.indexOf(',') + 1)),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallback(),
            )
          : photo.startsWith('https://') || photo.startsWith('http://')
          ? Image.network(
              photo,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallback(),
            )
          : fallback();
    } catch (_) {
      image = fallback();
    }
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(borderRadius: BorderRadius.circular(10), child: image),
    );
  }
}

class ProductPhotoPicker extends StatefulWidget {
  const ProductPhotoPicker({
    super.key,
    required this.photo,
    required this.onChanged,
    this.enabled = true,
    this.imagePicker,
  });
  final String photo;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final ImagePicker? imagePicker;

  @override
  State<ProductPhotoPicker> createState() => _ProductPhotoPickerState();
}

class _ProductPhotoPickerState extends State<ProductPhotoPicker> {
  bool _busy = false;

  Future<void> _capture([ImageSource source = ImageSource.camera]) async {
    setState(() => _busy = true);
    try {
      final file = await (widget.imagePicker ?? ImagePicker()).pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 75,
        requestFullMetadata: false,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) throw StateError('Foto vazia');
      if (mounted) {
        widget.onChanged('data:image/jpeg;base64,${base64Encode(bytes)}');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível carregar a foto. Verifique a permissão da câmera ou galeria e tente novamente.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Row(
    children: [
      ProductPhoto(photo: widget.photo),
      const SizedBox(width: 12),
      Flexible(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: widget.enabled && !_busy ? _capture : null,
              icon: const Icon(Icons.camera_alt_outlined),
              label: Text(
                _busy
                    ? 'Carregando foto...'
                    : widget.photo.isEmpty
                    ? 'Tirar foto'
                    : 'Alterar foto',
              ),
            ),
            TextButton.icon(
              onPressed: widget.enabled && !_busy
                  ? () => _capture(ImageSource.gallery)
                  : null,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Escolher da galeria'),
            ),
          ],
        ),
      ),
    ],
  );
}
