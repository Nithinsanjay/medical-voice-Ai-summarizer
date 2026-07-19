import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/model_info.dart';
import '../state/model_download_viewmodel.dart';
import '../utils/constants.dart';

class DownloadScreen extends StatelessWidget {
  const DownloadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Download AI Models'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ModelDownloadViewModel>(
        builder: (context, vm, _) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Download both models to enable fully offline AI summarization.\nModels are stored on your device.',
                        style: TextStyle(fontSize: 13, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ...vm.models.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _ModelCard(
                        model: e.value,
                        onDownload: () => vm.downloadModel(e.key),
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  const _ModelCard({required this.model, required this.onDownload});

  final ModelInfo model;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final isInstalled = model.status == ModelStatus.installed;
    final isDownloading = model.status == ModelStatus.downloading;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isInstalled
                        ? Colors.green.shade50
                        : isDownloading
                            ? Colors.orange.shade50
                            : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isInstalled
                        ? Icons.check_circle
                        : isDownloading
                            ? Icons.downloading
                            : Icons.cloud_download_outlined,
                    color: isInstalled
                        ? Colors.green
                        : isDownloading
                            ? Colors.orange
                            : Colors.grey,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.name,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        model.size,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: model.status),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              model.description,
              style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
            ),
            if (isDownloading) ...[
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: model.progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(model.progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const Text('Downloading...',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ] else if (!isInstalled) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onDownload,
                  icon: const Icon(Icons.download_outlined),
                  label: Text('Download ${model.name}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: Colors.green, size: 18),
                  const SizedBox(width: 6),
                  const Text('Model ready for offline use',
                      style: TextStyle(color: Colors.green, fontSize: 13)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final ModelStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ModelStatus.installed => ('Installed', Colors.green),
      ModelStatus.downloading => ('Downloading', Colors.orange),
      ModelStatus.notDownloaded => ('Not Downloaded', Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontWeight: FontWeight.w600, fontSize: 11),
      ),
    );
  }
}
