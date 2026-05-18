import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../suggestion/presentation/suggestion_card.dart';
import '../../suggestion/presentation/suggestion_provider.dart';
import '../domain/record.dart';
import 'record_provider.dart';

Future<void> showAddRecordSheet(BuildContext context, {Record? editing}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _AddRecordSheet(editing: editing),
  );
}

enum _SheetMode { loading, suggestion, manual }

class _AddRecordSheet extends ConsumerStatefulWidget {
  final Record? editing;
  const _AddRecordSheet({this.editing});

  @override
  ConsumerState<_AddRecordSheet> createState() => _AddRecordSheetState();
}

class _AddRecordSheetState extends ConsumerState<_AddRecordSheet> {
  _SheetMode _mode = _SheetMode.loading;
  Record? _suggestion;

  late RecordCategory _selectedCategory;
  late final TextEditingController _valueCtrl;
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = kCategories.first;
    _valueCtrl = TextEditingController(text: widget.editing?.value ?? '');

    if (widget.editing != null) {
      _selectedCategory = kCategories.firstWhere(
        (c) => c.name == widget.editing!.category,
        orElse: () => kCategories.first,
      );
      _mode = _SheetMode.manual;
    } else {
      _loadSuggestion();
    }
  }

  @override
  void dispose() {
    _valueCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSuggestion() async {
    final suggestion = await ref.read(suggestionProvider.future);
    if (!mounted) return;
    setState(() {
      _suggestion = suggestion;
      _mode = suggestion != null ? _SheetMode.suggestion : _SheetMode.manual;
    });
  }

  void _acceptSuggestion() async {
    if (_suggestion == null) return;
    setState(() => _saving = true);
    final id = await ref.read(recordListProvider.notifier).add(_suggestion!);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('기록됐어요 ✓'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '취소',
          onPressed: () => ref.read(recordListProvider.notifier).remove(id),
        ),
      ),
    );
  }

  void _modifySuggestion() {
    if (_suggestion == null) return;
    setState(() {
      _selectedCategory = kCategories.firstWhere(
        (c) => c.name == _suggestion!.category,
        orElse: () => kCategories.first,
      );
      _valueCtrl.text = _suggestion!.value;
      _mode = _SheetMode.manual;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final notifier = ref.read(recordListProvider.notifier);
    final record = Record(
      id: widget.editing?.id,
      category: _selectedCategory.name,
      value: _valueCtrl.text.trim(),
      recordedAt: widget.editing?.recordedAt ?? DateTime.now(),
      source: widget.editing?.source ?? 'manual',
    );

    if (widget.editing != null) {
      await notifier.edit(record);
      if (mounted) Navigator.pop(context);
    } else {
      final id = await notifier.add(record);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('기록됐어요 ✓'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: '취소',
            onPressed: () => ref.read(recordListProvider.notifier).remove(id),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
      child: switch (_mode) {
        _SheetMode.loading => const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          ),
        _SheetMode.suggestion => _buildSuggestionView(),
        _SheetMode.manual => _buildManualForm(),
      },
    );
  }

  Widget _buildSuggestionView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('새 기록', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        SuggestionCard(
          suggestion: _suggestion!,
          onAccept: _saving ? () {} : _acceptSuggestion,
          onModify: _modifySuggestion,
          onSkip: () => setState(() => _mode = _SheetMode.manual),
        ),
      ],
    );
  }

  Widget _buildManualForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.editing != null ? '기록 수정' : '새 기록',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          _CategoryGrid(
            selected: _selectedCategory,
            onSelect: (c) => setState(() {
              _selectedCategory = c;
              _valueCtrl.clear();
            }),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _valueCtrl,
            autofocus: true,
            keyboardType:
                _selectedCategory.isNumeric ? TextInputType.number : TextInputType.text,
            inputFormatters: _selectedCategory.isNumeric
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            decoration: InputDecoration(
              labelText: _selectedCategory.isNumeric ? '금액 (원)' : '내용',
              border: const OutlineInputBorder(),
              suffixText: _selectedCategory.isNumeric ? '원' : null,
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? '값을 입력해주세요' : null,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.editing != null ? '수정 완료' : '저장'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final RecordCategory selected;
  final ValueChanged<RecordCategory> onSelect;

  const _CategoryGrid({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: kCategories.map((c) {
        return ChoiceChip(
          label: Text('${c.emoji} ${c.name}'),
          selected: c.name == selected.name,
          onSelected: (_) => onSelect(c),
        );
      }).toList(),
    );
  }
}
