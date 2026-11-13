import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../theme/app_theme.dart';
import '../theme/app_strings.dart';

class TutorialsScreen extends StatefulWidget {
  final bool isPortuguese;
  const TutorialsScreen({super.key, required this.isPortuguese});

  @override
  State<TutorialsScreen> createState() => _TutorialsScreenState();
}

class _TutorialsScreenState extends State<TutorialsScreen> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  int _activeLesson = 0;

  final List<Map<String, String>> _lessons = [
    {
      'module': 'MÓDULO 01 • PREPARAÇÃO',
      'title': 'Ordem Correta do Skincare Diurno',
      'desc': 'Entenda a densidade molecular: da textura mais fluida à mais densa para absorção máxima.',
      'duration': '03:45 min',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    },
    {
      'module': 'MÓDULO 02 • GLOWFRIDGE IoT',
      'title': 'Conservação Térmica de Ativos',
      'desc': 'Como manter séruns entre 4°C e 8°C evita oxidação da Vitamina C e potencializa o efeito calmante.',
      'duration': '04:12 min',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    },
    {
      'module': 'MÓDULO 03 • TÉCNICA FACIAL',
      'title': 'Drenagem Linfática com Roll-on Gelado',
      'desc': 'Movimentos ascendentes para reduzir edema matinal e estimular a microcirculação.',
      'duration': '05:20 min',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoy.mp4',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initPlayer(_lessons[0]['url']!);
  }

  Future<void> _initPlayer(String url) async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
    await _videoController.initialize();
    _chewieController?.dispose();
    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: false,
      looping: false,
      aspectRatio: 16 / 9,
    );
    if (mounted) setState(() {});
  }

  Future<void> _switchLesson(int index) async {
    setState(() {
      _activeLesson = index;
      _chewieController?.dispose();
      _chewieController = null;
    });
    await _videoController.dispose();
    await _initPlayer(_lessons[index]['url']!);
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _lessons[_activeLesson];
    final pt = widget.isPortuguese;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Text(AppStrings.t(pt, 'academy_title'), style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(AppStrings.t(pt, 'academy_sub'), style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 18),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: AppTheme.softShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: _chewieController != null && _videoController.value.isInitialized
                      ? Chewie(controller: _chewieController!)
                      : const Center(child: CircularProgressIndicator(color: AppColors.primaryLight)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(8)),
                          child: Text(current['module']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        ),
                        Text(current['duration']!, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(current['title']!, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(current['desc']!, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(AppStrings.t(pt, 'learning_path'), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ...List.generate(_lessons.length, (index) {
          final item = _lessons[index];
          final selected = index == _activeLesson;
          return GestureDetector(
            onTap: () => _switchLesson(index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selected ? AppColors.primarySoft.withOpacity(0.65) : AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: selected ? AppColors.primary : AppColors.borderSubtle, width: selected ? 1.6 : 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.surfaceTint,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(selected ? Icons.equalizer_rounded : Icons.play_arrow_rounded, color: selected ? Colors.white : AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
                        const SizedBox(height: 3),
                        Text(item['duration']!, style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
