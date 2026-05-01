import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../models/models.dart';
import '../widgets/love_widgets.dart';

class FilePreviewScreen extends StatefulWidget {
  static const route = '/file-preview';
  const FilePreviewScreen({super.key});

  @override
  State<FilePreviewScreen> createState() => _FilePreviewScreenState();
}

class _FilePreviewScreenState extends State<FilePreviewScreen> {
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  bool _initialized = false;
  bool _loading = false;
  String? _error;

  PrivateFileItem get file => ModalRoute.of(context)!.settings.arguments as PrivateFileItem;

  bool get _isImage => file.type.startsWith('image/');
  bool get _isVideo => file.type.startsWith('video/');
  bool get _isAudio => file.type.startsWith('audio/');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _prepareMedia();
  }

  Future<void> _prepareMedia() async {
    final url = file.downloadUrl;
    if (url == null || url.isEmpty || (!_isVideo && !_isAudio)) return;
    setState(() => _loading = true);
    try {
      if (_isVideo) {
        final controller = VideoPlayerController.networkUrl(Uri.parse(url));
        await controller.initialize();
        if (!mounted) return;
        setState(() => _videoController = controller);
      } else if (_isAudio) {
        final player = AudioPlayer();
        await player.setUrl(url);
        if (!mounted) {
          await player.dispose();
          return;
        }
        setState(() => _audioPlayer = player);
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'تعذّر تجهيز المعاينة. يمكنك فتح الملف خارجيًا.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  Future<void> _openExternal() async {
    final url = file.downloadUrl;
    if (url == null || url.isEmpty) return;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return LoveScaffold(
      title: file.name,
      actions: [
        IconButton(
          tooltip: 'فتح خارجيًا',
          icon: const Icon(Icons.open_in_browser),
          onPressed: file.downloadUrl == null ? null : _openExternal,
        ),
      ],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildPreview(context),
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    if (_loading) return const CircularProgressIndicator();
    if (_error != null) return _fallbackCard(context, _error!);
    final url = file.downloadUrl;
    if (url == null || url.isEmpty) return _fallbackCard(context, 'رابط الملف غير متاح.');

    if (_isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain),
      );
    }

    if (_isVideo && _videoController != null) {
      final controller = _videoController!;
      return LoveCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(aspectRatio: controller.value.aspectRatio, child: VideoPlayer(controller)),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                setState(() => controller.value.isPlaying ? controller.pause() : controller.play());
              },
              icon: Icon(controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
              label: Text(controller.value.isPlaying ? 'إيقاف مؤقت' : 'تشغيل'),
            ),
          ],
        ),
      );
    }

    if (_isAudio && _audioPlayer != null) {
      return LoveCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.audiotrack, size: 72),
            const SizedBox(height: 12),
            Text(file.name, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            StreamBuilder<PlayerState>(
              stream: _audioPlayer!.playerStateStream,
              builder: (context, snapshot) {
                final playing = snapshot.data?.playing ?? false;
                return FilledButton.icon(
                  onPressed: () => playing ? _audioPlayer!.pause() : _audioPlayer!.play(),
                  icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                  label: Text(playing ? 'إيقاف مؤقت' : 'تشغيل الصوت'),
                );
              },
            ),
          ],
        ),
      );
    }

    return _fallbackCard(context, 'لا توجد معاينة داخلية لهذا النوع من الملفات.');
  }

  Widget _fallbackCard(BuildContext context, String message) {
    return LoveCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file, size: 72),
          const SizedBox(height: 12),
          Text(file.name, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(file.type, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: file.downloadUrl == null ? null : _openExternal,
            icon: const Icon(Icons.download),
            label: const Text('فتح / تحميل'),
          ),
        ],
      ),
    );
  }
}
