import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/suggestion/presentation/suggestion_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          const _SectionHeader('AI 설정'),
          ListTile(
            leading: const Icon(Icons.key_outlined),
            title: const Text('Claude API 키'),
            subtitle: const Text('AI 자동 제안 기능에 필요합니다'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showApiKeyDialog(context, ref),
          ),
          const Divider(),
          const _SectionHeader('데이터'),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('데이터 초기화', style: TextStyle(color: Colors.red)),
            onTap: () => _showResetDialog(context),
          ),
        ],
      ),
    );
  }

  Future<void> _showApiKeyDialog(BuildContext context, WidgetRef ref) async {
    final service = ref.read(aiServiceProvider);
    final existing = await service.getApiKey();
    if (!context.mounted) return;

    final ctrl = TextEditingController(text: existing ?? '');
    bool obscure = true;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Claude API 키 설정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                obscureText: obscure,
                decoration: InputDecoration(
                  hintText: 'sk-ant-...',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => obscure = !obscure),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'API 키는 기기에 안전하게 저장되며 외부로 전송되지 않습니다.',
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            if (existing != null)
              TextButton(
                onPressed: () async {
                  await service.deleteApiKey();
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('API 키가 삭제됐습니다')));
                  }
                },
                child: const Text('삭제', style: TextStyle(color: Colors.red)),
              ),
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
            FilledButton(
              onPressed: () async {
                final key = ctrl.text.trim();
                if (key.isNotEmpty) await service.saveApiKey(key);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('API 키가 저장됐습니다 ✓')));
                }
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
    ctrl.dispose();
  }

  Future<void> _showResetDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('데이터 초기화'),
        content: const Text('모든 기록이 삭제됩니다. 계속하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx, false), child: const Text('취소')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('준비 중인 기능입니다')));
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
