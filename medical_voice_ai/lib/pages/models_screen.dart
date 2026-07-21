import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/model_download_viewmodel.dart';
import '../data/models/model_info.dart';
import '../utils/constants.dart';
import 'download_screen.dart';

class ModelsScreen extends StatelessWidget {
  const ModelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage AI Models'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ModelDownloadViewModel>(
        builder: (context, vm, _) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Essential Models',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'These models are required for offline transcription and clinical summarization.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 20),
              ...vm.models.asMap().entries.map(
                    (e) => _ModelManagementCard(
                      model: e.value,
                      onDownload: () => vm.downloadModel(e.key),
                      onDelete: () => _confirmDelete(context, vm, e.key, e.value.name),
                    ),
                  ),
              const Divider(height: 48),
              const Text(
                'Storage Tip',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.storage_outlined, color: AppColors.primary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Models are stored locally. Ensure you have at least 1GB of free space.',
                        style: TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, ModelDownloadViewModel vm, int index, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove $name?'),
        content: const Text('This will delete the model from your device storage. You will need to download it again to use offline features.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              vm.removeModel(index);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class _ModelManagementCard extends StatelessWidget {
  const _ModelManagementCard({
    required this.model,
    required this.onDownload,
    required this.onDelete,
  });

  final ModelInfo model;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isInstalled = model.status == ModelStatus.installed;
    final isDownloading = model.status == ModelStatus.downloading;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(18),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isInstalled ? Colors.green.shade50 : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isInstalled ? Icons.check_circle : Icons.offline_bolt_outlined,
                color: isInstalled ? Colors.green : AppColors.primary,
              ),
            ),
            title: Text(
              model.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('${model.size} • ${isInstalled ? 'Installed' : 'Ready to Download'}'),
            ),
            trailing: isInstalled
                ? IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: onDelete,
                  )
                : null,
          ),
          if (isDownloading)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: model.progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${(model.progress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Text('Downloading...', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            )
          else if (!isInstalled)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: ElevatedButton.icon(
                onPressed: onDownload,
                icon: const Icon(Icons.download),
                label: const Text('Download Now'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
