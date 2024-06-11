import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'AppDrawer.dart';
import 'api/api.dart';

class block_chain_mypage extends StatefulWidget {
  const block_chain_mypage({super.key});

  @override
  _block_chain_mypage createState() => _block_chain_mypage();
}

class _block_chain_mypage extends State<block_chain_mypage> {
  String result = "No data";

  var fromAddress_Controller = TextEditingController();
  var payeeAddress_Controller = TextEditingController();
  var amount_Controller = TextEditingController();

  String? Amount;
  String? Payment_time;
  String? Remaining_time;
  int? Remaining_time_days;
  int? Remaining_time_hours;
  int? Remaining_time_minutes;
  int? Remaining_time_seconds;

  Future<void> makePayment() async {
    try {
      final response = await http.post(
        Uri.parse(API.host + '/makePayment'),
        body: jsonEncode({
          'fromAddress' : fromAddress_Controller.text.trim(),
          'payeeAddress': payeeAddress_Controller.text.trim(),
          'amount' : amount_Controller.text.trim(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          result = "Payment made successfully: ${response.body}";
        });
      } else {
        setState(() {
          result = "Failed to make payment: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        result = "Error: $e";
      });
    }
  }

  Future<void> completePayment() async {
    try {
      final response = await http.post(
        Uri.parse(API.host + '/completePayment'),
        body: jsonEncode({
          'fromAddress' : fromAddress_Controller.text.trim(),
          'payeeAddress': payeeAddress_Controller.text.trim(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          result = "Payment made successfully: ${response.body}";
        });
      } else {
        setState(() {
          result = "Failed to make payment: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        result = "Error: $e";
      });
    }
  }

  Future<void> viewPayment() async {
    try {
      final response = await http.post(
        Uri.parse(API.host + '/getViewPayment'),
        body: jsonEncode({
          'payerAddress': fromAddress_Controller.text.trim(),
          'payeeAddress': payeeAddress_Controller.text.trim(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        setState(() {
          Amount = jsonResponse['viewPendingPayment']['amount'];
          Payment_time = jsonResponse['viewPaymentTimestamp'];
          Remaining_time_days = jsonResponse['viewRemainingTime']['days'];
          Remaining_time_hours = jsonResponse['viewRemainingTime']['hours'];
          Remaining_time_minutes = jsonResponse['viewRemainingTime']['minutes'];
          Remaining_time_seconds = jsonResponse['viewRemainingTime']['seconds'];
        });
      }
    } catch (e) {
      print(123);
      setState(() {
        Amount = null;
        Payment_time = null;
        Remaining_time_days = null;
        Remaining_time_hours = null;
        Remaining_time_minutes = null;
        Remaining_time_seconds = null;
      });
    }
  }

  Future<void> getView() async {
    try {
      final response = await http.post(
        Uri.parse(API.host + '/getView'),
        body: jsonEncode({
          'payerAddress': fromAddress_Controller.text.trim(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch(e) {
      setState(() {
      print(123);
        Amount = null;
        Payment_time = null;
        Remaining_time_days = null;
        Remaining_time_hours = null;
        Remaining_time_minutes = null;
        Remaining_time_seconds = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("블록체인 마이페이지", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(Amount != null ? "보류된 이더 : $Amount ETH" : "보류된 이더 : 0 ETH"),
            Text(Payment_time != null ? "결제된 날짜 : $Payment_time" : ""),
            Text(Remaining_time_seconds != null ? "보류 기간 까지 | $Remaining_time_days 일 "
                "$Remaining_time_hours 시 $Remaining_time_minutes 분 $Remaining_time_seconds 초 | 남았습니다." : ""),
          ],
        ),
      ),
    );
  }
}