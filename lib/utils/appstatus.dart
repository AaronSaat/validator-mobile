import 'package:flutter/material.dart';

class AppStatus {
  static Color getStatusColor(String statusStr) {
    int? status = int.tryParse(statusStr);
    if (status == null) return Colors.grey.shade300;

    if (status >= 1 && status <= 10) {
      return Colors.cyan;
    } else if (status == 11) {
      return Colors.cyan;
    } else if (status == 12) {
      return Colors.cyan;
    } else if (status == 21) {
      return Colors.cyan;
    } else if (status == 29) {
      return Colors.red;
    } else if (status == 30) {
      return Colors.cyan;
    } else if (status == 31) {
      return Colors.cyan;
    } else if (status == 79) {
      return Colors.red;
    } else if (status == 41 || status == 42) {
      return Colors.green;
    } else if (status == 101) {
      return Colors.orange;
    } else if (status == 99) {
      return Colors.red;
    } else if (status == 89) {
      return Colors.red;
    } else if (status == 100 || status == 200) {
      return Colors.grey.shade300;
    } else if (status == 201) {
      return Colors.cyan;
    } else if (status == 25 || status == 26) {
      return Colors.cyan;
    } else if (status == 51 || status == 52 || status == 60) {
      return Colors.green;
    } else if (status == 69) {
      return Colors.red;
    }
    return Colors.grey.shade300;
  }

  static IconData getStatusIcon(String statusStr) {
    int? status = int.tryParse(statusStr);
    if (status == null) return Icons.help_outline;

    if (status >= 1 && status <= 10) {
      return Icons.check_circle_outline;
    } else if (status == 11) {
      return Icons.check_circle;
    } else if (status == 12) {
      return Icons.attach_money;
    } else if (status == 21) {
      return Icons.account_balance;
    } else if (status == 29) {
      return Icons.error_outline;
    } else if (status == 30) {
      return Icons.inventory_2;
    } else if (status == 31) {
      return Icons.assignment_turned_in;
    } else if (status == 79) {
      return Icons.undo;
    } else if (status == 41 || status == 42) {
      return Icons.done_all;
    } else if (status == 101) {
      return Icons.send;
    } else if (status == 99) {
      return Icons.reply;
    } else if (status == 89) {
      return Icons.reply_all;
    } else if (status == 100 || status == 200) {
      return Icons.hourglass_empty;
    } else if (status == 201) {
      return Icons.payment;
    } else if (status == 25 || status == 26) {
      return Icons.check_circle_outline;
    } else if (status == 51 || status == 52 || status == 60) {
      return Icons.done;
    } else if (status == 69) {
      return Icons.cancel;
    }
    return Icons.help_outline;
  }
}
