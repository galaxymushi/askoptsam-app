import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';

class PayChannel {
  const PayChannel({
    required this.id,
    required this.name,
    required this.color,
    required this.account,
    required this.ussd,
  });

  final String id;
  final String name;
  final int color;
  final String account;
  final String ussd;
}

class PaymentService {
  PaymentService._();

  static List<PayChannel> channels() => const [
        PayChannel(
          id: 'airtel',
          name: 'Airtel Money',
          color: 0xFFE40000,
          account: AppConfig.payAirtel,
          ussd: '*150*60#',
        ),
        PayChannel(
          id: 'mpesa',
          name: 'M-Pesa (Vodacom)',
          color: 0xFFE60000,
          account: AppConfig.payMpesa,
          ussd: '*150*00#',
        ),
      ];

  /// Opens the phone dialer pre-filled with the network USSD code.
  /// USSD cannot be executed silently from an app on modern Android, so the
  /// user confirms the call — this is the real operator flow, not a demo.
  static Future<bool> dialUssd(String code) async {
    if (code.isEmpty) return false;
    final uri = Uri.parse('tel:${Uri.encodeComponent(code)}');
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  static Future<void> copy(String value) =>
      Clipboard.setData(ClipboardData(text: value));

  /// Sends the claim reference to the operator on WhatsApp so the payment can
  /// be matched against the mobile-money statement before service is given.
  static Future<bool> shareReceipt(String message) async {
    final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  /// Stores the user's "I have paid" claim so the operator can verify it.
  /// Cloud (Firestore) when configured, otherwise on-device.
  static Future<String> recordClaim({
    required String? uid,
    required num amount,
    required String channel,
    required String purpose,
  }) async {
    final ref =
        'ASK-${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}';
    final claim = {
      'reference': ref,
      'uid': uid,
      'amount': amount,
      'currency': 'TZS',
      'channel': channel,
      'purpose': purpose,
      'status': 'pending',
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };
    if (AppConfig.firebaseConfigured && uid != null) {
      await FirebaseFirestore.instance.collection('payments').doc(ref).set(claim);
      return ref;
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('payment_claims') ?? <String>[];
    raw.add(jsonEncode(claim));
    await prefs.setStringList('payment_claims', raw);
    return ref;
  }
}
