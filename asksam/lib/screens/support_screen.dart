import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n.dart';
import '../services/payment_service.dart';
import '../theme.dart';
import '../widgets/ui.dart';
import 'pay_screen.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  static const _tiers = [2000, 5000, 10000];

  int _tier = 0;
  final _amountController = TextEditingController(text: '10000');

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  int get _donationAmount => int.tryParse(_amountController.text) ?? 0;

  void _payCoffee() {
    final t = L10nScope.of(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PayScreen(
          amount: _tiers[_tier],
          purpose: 'coffee',
          label: t.get('coffeeLabel'),
        ),
      ),
    );
  }

  void _payDonation() {
    final t = L10nScope.of(context);
    if (_donationAmount < 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.get('invalidAmount'))),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PayScreen(
          amount: _donationAmount,
          purpose: 'donation',
          label: t.get('donationLabel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = L10nScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tiers = [t.get('oneCoffee'), t.get('threeCoffees'), t.get('fiveCoffees')];
    final channelNames =
        PaymentService.channels().map((c) => c.name).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 30),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(t.get('supportTitle')),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 10, 26, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSoft : const Color(0xFFE9F1FE),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(
                    Icons.coffee_outlined,
                    size: 40,
                    color: Color(0xFF2E6BFF),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Text(
                t.get('buySamCoffee'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                t.get('helpKeepGoing'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: isDark ? AppColors.darkMuted : AppColors.muted,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(tiers.length, (i) {
                  final selected = _tier == i;
                  return Padding(
                    padding: EdgeInsets.only(right: i == tiers.length - 1 ? 0 : 10),
                    child: InkWell(
                      onTap: () => setState(() => _tier = i),
                      borderRadius: BorderRadius.circular(999),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? (isDark
                                  ? AppColors.darkSoft
                                  : const Color(0xFFE9F1FE))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF2E6BFF)
                                : (isDark ? AppColors.darkBorder : AppColors.border),
                            width: 1.4,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              tiers[i],
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              formatTzs(_tiers[i]),
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? AppColors.primary
                                    : (isDark
                                        ? AppColors.darkMuted
                                        : AppColors.muted),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: t.format('coffeeAmount', {'amount': formatTzs(_tiers[_tier])}),
                onPressed: _payCoffee,
              ),
              const SizedBox(height: 30),
              Divider(color: isDark ? AppColors.darkBorder : AppColors.border),
              const SizedBox(height: 28),
              Text(
                t.get('donateTitle'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  hintText: t.get('amountHint'),
                  prefixText: 'TZS ',
                  prefixStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              OutlinePillButton(
                label: t.format('donateAmount', {
                  'amount': formatTzs(_donationAmount),
                }),
                onPressed: _payDonation,
              ),
              const SizedBox(height: 26),
              SectionLabel(t.get('supportedPayments')),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: channelNames
                    .map(
                      (name) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 30),
              Text(
                t.get('paySafeNote'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.45,
                  color: isDark ? AppColors.darkMuted : AppColors.muted,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                t.get('thanks'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? AppColors.darkMuted : AppColors.muted,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
