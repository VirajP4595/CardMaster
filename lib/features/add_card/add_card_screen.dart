import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/catalog/catalog.dart';
import '../../domain/models.dart';
import '../../domain/money.dart';
import '../../ui/widgets.dart';
import 'card_form.dart';

/// Add card: 1 bank → 2 variant → 3 personalise (design board 4).
class AddCardScreen extends ConsumerStatefulWidget {
  const AddCardScreen({super.key});

  @override
  ConsumerState<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends ConsumerState<AddCardScreen> {
  int _step = 0;
  String _query = '';
  CatalogBank? _bank;
  CatalogProduct? _product;
  bool _custom = false;
  final _form = CardFormValues();
  String _customBank = '';
  String _customName = '';
  CardNetwork _customNetwork = CardNetwork.visa;

  void _pickBank(CatalogBank? b) => setState(() {
        _bank = b;
        _custom = b == null;
        _step = b == null ? 2 : 1;
        _query = '';
      });

  void _pickProduct(CatalogProduct p) => setState(() {
        _product = p;
        _form.annualFeeRupees =
            p.annualFeePaise == 0 ? '0' : '${p.annualFeePaise ~/ 100}';
        _form.waiverRupees = p.waiverSpendPaise == null
            ? ''
            : '${p.waiverSpendPaise! ~/ 100}';
        _step = 2;
      });

  bool get _canSave =>
      _form.valid &&
      (!_custom ||
          (_customBank.trim().isNotEmpty && _customName.trim().isNotEmpty));

  Future<void> _save() async {
    final p = _product;
    final card = UserCard(
      id: const Uuid().v4(),
      productId: _custom ? 'custom' : p!.id,
      bankName: _custom ? _customBank.trim() : _bank!.name,
      name: _custom ? _customName.trim() : p!.name,
      nickname: _form.nickname.trim().isEmpty ? null : _form.nickname.trim(),
      network: _custom ? _customNetwork : p!.network,
      last4: _form.last4.isEmpty ? null : _form.last4,
      creditLimitPaise: _form.limitPaise!,
      statementDay: _form.statement!,
      dueDay: _form.due!,
      annualFeePaise: _form.feePaise,
      waiverSpendPaise: _form.waiverPaise,
      anniversaryMonth: _form.anniversaryMonth,
      faceColor: _custom ? 0xFF3A2A8C : p!.face.base,
    );
    await ref
        .read(databaseProvider)
        .upsertCard(card, finish: _custom ? 'matte' : p!.face.finish);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider);
    final titles = [
      'Choose your bank',
      'Choose your ${_bank?.name ?? ''} card',
      _custom ? 'Add a custom card' : 'Personalise',
    ];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: _step == 0 ? 'Close' : 'Back',
          icon: Icon(_step == 0 ? Icons.close : Icons.arrow_back),
          onPressed: () => _step == 0
              ? context.pop()
              : setState(() => _step = _custom ? 0 : _step - 1),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step ${_step + 1} of 3',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
            Text(titles[_step],
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(children: [
              for (var i = 0; i < 3; i++)
                Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i <= _step ? AppColors.primary : AppColors.track,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ]),
          ),
        ),
      ),
      body: SafeArea(
        child: switch (_step) {
          0 => _banks(catalog),
          1 => _variants(catalog),
          _ => _personalise(),
        },
      ),
    );
  }

  Widget _search(String hint) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        child: TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: hint,
          ),
          onChanged: (s) => setState(() => _query = s.toLowerCase()),
        ),
      );

  Widget _banks(Catalog catalog) {
    final banks = catalog.banks
        .where((b) => b.name.toLowerCase().contains(_query))
        .toList();
    return Column(children: [
      _search('Search banks'),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            for (final b in banks)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Tile(
                  onTap: () => _pickBank(b),
                  child: Row(children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryContainer,
                      child: Text(b.name[0],
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.onPrimaryContainer)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(b.name,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    Text('${catalog.productsOf(b.id).length} cards',
                        style: const TextStyle(color: AppColors.textSecondary)),
                  ]),
                ),
              ),
            _customButton(),
          ],
        ),
      ),
    ]);
  }

  Widget _variants(Catalog catalog) {
    final products = catalog
        .productsOf(_bank!.id)
        .where((p) => p.name.toLowerCase().contains(_query))
        .toList();
    return Column(children: [
      _search('Search ${_bank!.name} cards'),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            for (final p in products)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Tile(
                  onTap: () => _pickProduct(p),
                  child: Row(children: [
                    Container(
                      width: 56,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color(p.face.base),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                          if (p.tagline != null) Caption(p.tagline!),
                        ],
                      ),
                    ),
                    Text(p.network.label,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                  ]),
                ),
              ),
            _customButton(),
          ],
        ),
      ),
    ]);
  }

  Widget _customButton() => OutlinedButton.icon(
        onPressed: () => setState(() {
          _custom = true;
          _step = 2;
        }),
        icon: const Icon(Icons.add),
        label: const Text("My card isn't listed: add a custom card"),
      );

  Widget _personalise() {
    final p = _product;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        if (_custom) ...[
          TextField(
            decoration: const InputDecoration(labelText: 'Bank'),
            onChanged: (s) => setState(() => _customBank = s),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(labelText: 'Card name'),
            onChanged: (s) => setState(() => _customName = s),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<CardNetwork>(
            initialValue: _customNetwork,
            decoration: const InputDecoration(labelText: 'Network'),
            items: [
              for (final n in CardNetwork.values)
                DropdownMenuItem(value: n, child: Text(n.label)),
            ],
            onChanged: (n) => setState(() => _customNetwork = n!),
          ),
          const SizedBox(height: 12),
          const Caption(
              "Custom cards don't have benefits yet, so Best card ranks them at 0%. Adding your own benefits is coming in an update."),
          const SizedBox(height: 16),
        ] else if (p != null) ...[
          Tile(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                for (final b in p.benefits
                    .where((b) => (b.rateBps ?? 0) > 0)
                    .take(3))
                  Caption('${b.title}: ${formatBps(b.rateBps!)}'
                      '${b.channel == null ? '' : ' via ${b.channel}'}'),
                const SizedBox(height: 6),
                Pill.attention('Sample rates. Check them against your bank.'),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        CardForm(values: _form, onChanged: () => setState(() {})),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _canSave ? _save : null,
          child: const Text('Save card'),
        ),
      ],
    );
  }
}
