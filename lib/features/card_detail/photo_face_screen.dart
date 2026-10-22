import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/photo_face.dart';
import '../../ui/widgets.dart';

/// Photo card face (docs/02-DESIGN.md §7): in-app camera, so nothing lands
/// in the gallery, then a required step that hides the card number before
/// anything is saved.
class PhotoFaceScreen extends ConsumerStatefulWidget {
  const PhotoFaceScreen({super.key, required this.cardId});
  final String cardId;

  @override
  ConsumerState<PhotoFaceScreen> createState() => _PhotoFaceScreenState();
}

class _PhotoFaceScreenState extends ConsumerState<PhotoFaceScreen> {
  CameraController? _camera;
  String? _error;
  Uint8List? _photo;
  final _boxes = <BlurBox>[BlurBox.numberDefault];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _startCamera();
  }

  Future<void> _startCamera() async {
    try {
      final cams = await availableCameras();
      final back = cams.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => cams.first);
      final c = CameraController(back, ResolutionPreset.high,
          enableAudio: false);
      await c.initialize();
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() => _camera = c);
    } on CameraException catch (e) {
      setState(() => _error = e.code == 'CameraAccessDenied'
          ? 'Camera permission was denied. Allow it in Android Settings to take a card photo.'
          : 'Camera unavailable: ${e.description}');
    } catch (e) {
      setState(() => _error = 'Camera unavailable: $e');
    }
  }

  @override
  void dispose() {
    _camera?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    final c = _camera;
    if (c == null) return;
    final shot = await c.takePicture();
    final bytes = await shot.readAsBytes();
    // The camera writes a temporary file; delete it straight away so the
    // unblurred photo only lives in memory.
    try {
      await File(shot.path).delete();
    } catch (_) {}
    await c.dispose();
    setState(() {
      _camera = null;
      _photo = bytes;
    });
  }

  Future<void> _save() async {
    final store = ref.read(photoStoreProvider);
    if (store == null || _photo == null) return;
    setState(() => _saving = true);
    final prepared = await compute(
        (({Uint8List photo, List<BlurBox> boxes}) a) =>
            prepareCardPhoto(a.photo, a.boxes),
        (photo: _photo!, boxes: List.of(_boxes)));
    await store.save(widget.cardId, prepared);
    _photo = null;
    ref.invalidate(facePhotoProvider(widget.cardId));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_photo == null
              ? 'Photo of your card'
              : 'Hide your card number')),
      body: SafeArea(
        child: _photo == null ? _cameraView() : _blurEditor(),
      ),
    );
  }

  Widget _cameraView() {
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(_error!, style: TextStyle(color: AppColors.dangerText)),
      );
    }
    final c = _camera;
    return Column(children: [
      const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Fit the front of your card inside the frame',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      Expanded(
        child: c == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(alignment: Alignment.center, children: [
                Center(child: CameraPreview(c)),
                FractionallySizedBox(
                  widthFactor: 0.88,
                  child: AspectRatio(
                    aspectRatio: faceWidth / faceHeight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.onPrimaryContainer, width: 2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ]),
      ),
      Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          IconButton.filled(
            iconSize: 36,
            tooltip: 'Take photo',
            onPressed: c == null ? null : _capture,
            icon: const Icon(Icons.camera_alt),
          ),
          const SizedBox(height: 8),
          const Caption('The photo stays on this phone and isn\'t saved to your gallery.'),
        ]),
      ),
    ]);
  }

  Widget _blurEditor() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
            'Drag the box over the card number. Add boxes for your name or expiry if you like. The blur is permanent.',
            style: TextStyle(color: AppColors.textTertiary)),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: faceWidth / faceHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: LayoutBuilder(builder: (context, size) {
              final w = size.maxWidth, h = size.maxHeight;
              return Stack(children: [
                Positioned.fill(
                    child: Image.memory(_photo!, fit: BoxFit.cover)),
                for (var i = 0; i < _boxes.length; i++)
                  _box(i, w, h),
              ]);
            }),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => setState(
              () => _boxes.add(const BlurBox(0.06, 0.75, 0.5, 0.12))),
          icon: const Icon(Icons.add),
          label: const Text('Add a box'),
        ),
        const SizedBox(height: 10),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Saving…' : 'Blur & save'),
        ),
        TextButton(
          onPressed: () {
            setState(() => _photo = null);
            _startCamera();
          },
          child: const Text('Retake'),
        ),
        const Caption(
            'Saved encrypted on this phone. Photos aren\'t included in backups.'),
      ],
    );
  }

  Widget _box(int i, double w, double h) {
    final b = _boxes[i];
    return Positioned(
      left: b.left * w,
      top: b.top * h,
      width: b.width * w,
      height: b.height * h,
      child: GestureDetector(
        onPanUpdate: (d) => setState(() => _boxes[i] = BlurBox(
              (b.left + d.delta.dx / w).clamp(0.0, 1 - b.width),
              (b.top + d.delta.dy / h).clamp(0.0, 1 - b.height),
              b.width,
              b.height,
            )),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xCC9AA0B4),
            border: Border.all(color: AppColors.attention, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Stack(children: [
            Center(
              child: Text('BLURRED',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.background)),
            ),
            // Resize handle (bottom-right).
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onPanUpdate: (d) => setState(() => _boxes[i] = BlurBox(
                      b.left,
                      b.top,
                      (b.width + d.delta.dx / w).clamp(0.05, 1 - b.left),
                      (b.height + d.delta.dy / h).clamp(0.05, 1 - b.top),
                    )),
                child: Container(
                  width: 22,
                  height: 22,
                  color: AppColors.attention,
                  child: Icon(Icons.open_in_full,
                      size: 14, color: AppColors.background),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
