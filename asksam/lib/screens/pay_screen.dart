import 'package:flutter/material.dart';

import '../app_state.dart';
import '../config.dart';
import '../l10n.dart';
import '../services/payment_service.dart';
import '../theme.dart';
import '../widgets/ui.dart';

class PayScreen extends StatefulWidget {
  const PayScreen({
    super.key,
    required this.amount,
    required this.purpose,
    this.label,
  });

  final int amount;
  final String purpose;
  final String? label;

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  void _openChannel(PayChannel channel) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChannelSheet(
        channel: channel,
        amount: widget.amount,
        purpose: widget.purpose,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = L10nScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final channels = PaymentService.channels();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 30),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(t.get('payTitle')),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.navy,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                children: [
                  Text(
                    widget.label ?? t.get('donationLabel'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: (isDark ? AppColors.darkMuted : Colors.white)
                          .withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatTzs(widget.amount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppConfig.payAccountName,
                    style: TextStyle(
                      color: (isDark ? AppColors.darkMuted : Colors.white)
                          .withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            SectionLabel(t.get('mobileMoney')),
            ...channels.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ChannelTile(channel: c, onTap: () => _openChannel(c)),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              t.get('paySafeNote'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: isDark ? AppColors.darkMuted : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChannelTile extends StatelessWidget {
  const _ChannelTile({required this.channel, required this.onTap});

  final PayChannel channel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = Color(channel.color);
    return Material(
      color: isDark ? AppColors.darkSurface : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.smartphone_rounded,
                  size: 21,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      channel.account,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                        color: isDark ? AppColors.darkMuted : AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? AppColors.darkMuted : AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChannelSheet extends StatelessWidget {
  const _ChannelSheet({
    required this.channel,
    required this.amount,
    required this.purpose,
  });

  final PayChannel channel;
  final int amount;
  final String purpose;

  @override
  Widget build(BuildContext context) {
    final t = L10nScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = Color(channel.color);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkPage : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        22,
        10,
        22,
        22 + MediaQuery.paddingOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.payments_rounded, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        channel.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        formatTzs(amount),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _DetailRow(
              label: t.get('merchantNumber'),
              value: channel.account,
              onCopy: () async {
                await PaymentService.copy(channel.account);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t.get('copied'))),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            _DetailRow(
              label: t.get('payName'),
              value: AppConfig.payAccountName,
            ),
            const SizedBox(height: 20),
            Text(
              t.get('paySteps'),
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            _Step(1, t.get('stepDial')),
            _Step(
              2,
              t.format('stepChoose', {
                'amount': formatTzs(amount),
                'account': channel.account,
              }),
            ),
            _Step(3, t.get('stepDone')),
            const SizedBox(height: 18),
            PrimaryButton(
              label: t.format('dialUssd', {'code': channel.ussd}),
              onPressed: () async {
                final ok = await PaymentService.dialUssd(channel.ussd);
                if (!ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t.get('dialFailed'))),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            OutlinePillButton(
              label: t.get('ivePaid'),
              icon: Icons.check_circle_outline_rounded,
              onPressed: () => _claim(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _claim(BuildContext context) async {
    final t = L10nScope.of(context);
    final uid = AppScope.read(context).user?.uid;
    final ref = await PaymentService.recordClaim(
      uid: uid,
      amount: amount,
      channel: channel.id,
      purpose: purpose,
    );
    if (!context.mounted) return;
    final receipt = t.format('receiptText', {
      'ref': ref,
      'channel': channel.name,
      'amount': formatTzs(amount),
    });
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.get('claimTitle')),
        content: Text(t.format('claimBody', {'ref': ref})),
        actions: [
          TextButton(
            onPressed: () => PaymentService.shareReceipt(receipt),
            child: Text(t.get('sendReceipt')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.get('ok')),
          ),
        ],
      ),
    );
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.onCopy});

  final String label;
  final String value;
  final Future<void> Function()? onCopy;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSoft : AppColors.soft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: isDark ? AppColors.darkMuted : AppColors.muted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              onPressed: onCopy,
              icon: const Icon(Icons.copy_rounded, size: 20),
            ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step(this.number, this.text);

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSoft : AppColors.soft,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: isDark ? AppColors.darkText : AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String formatTzs(int amount) {
  final digits = amount.toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return 'TZS $buf';
}
