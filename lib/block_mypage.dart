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

  var ethereumAddress = TextEditingController();

  String? ethereum;
  String? sent_ethereum;
  String? received_ethereum;
  String? finish_ethereum;

  void getEther() {
    getBalance();
    viewTotalPaymentsByPayer();
    viewPaymentsByPayee();
    viewCompletedPaymentsByPayee();
  }

  Future<void> getBalance() async {
    try {
      final response = await http.post(
        Uri.parse(API.host + '/getBalance'),
        body: jsonEncode({
          'ethereumAddress' : ethereumAddress.text.trim(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        double balance = double.parse(jsonResponse['balance']);
        String formattedBalance = balance.toStringAsFixed(2);
        setState(() {
          ethereum = formattedBalance as String?;
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

  Future<void> viewTotalPaymentsByPayer() async {
    try {
      final response = await http.post(
        Uri.parse(API.host + '/viewTotalPaymentsByPayer'),
        body: jsonEncode({
          'ethereumAddress' : ethereumAddress.text.trim(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        double ether = double.parse(jsonResponse['ether']);
        String formattedEther = ether.toStringAsFixed(2);
        setState(() {
          sent_ethereum = formattedEther as String?;
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

  Future<void> viewPaymentsByPayee() async {
    try {
      final response = await http.post(
        Uri.parse(API.host + '/viewPaymentsByPayee'),
        body: jsonEncode({
          'ethereumAddress' : ethereumAddress.text.trim(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        double ether = double.parse(jsonResponse['ether']);
        String formattedEther = ether.toStringAsFixed(2);
        setState(() {
          received_ethereum = formattedEther as String?;
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

  Future<void> viewCompletedPaymentsByPayee() async {
    try {
      final response = await http.post(
        Uri.parse(API.host + '/viewCompletedPaymentsByPayee'),
        body: jsonEncode({
          'ethereumAddress' : ethereumAddress.text.trim(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        double ether = double.parse(jsonResponse['ether']);
        String formattedEther = ether.toStringAsFixed(2);
        setState(() {
          finish_ethereum = formattedEther as String?;
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

  Future<void> receivePayment() async {
    try {
      final response = await http.post(
        Uri.parse(API.host + '/receivePayment'),
        body: jsonEncode({
          'payeeAddress' : ethereumAddress.text.trim(),
          'payerAddress' : '0xE13FB373B1824C18a31A8Aa20699254419BC7102',
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        setState(() {
          print(jsonResponse['result']);
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
            TextFormField(
              controller: ethereumAddress,
              decoration: const InputDecoration(
                labelText: '자신 주소',
                border: OutlineInputBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: () { getEther(); },
              child: Text('확인'),
            ),
            ElevatedButton(
              onPressed: () { receivePayment(); },
              child: Text('체크'),
            ),
            SizedBox(height: 20),
            Text(ethereum != null ? "보유 이더 : $ethereum ETH" : "보유 이더 : 0 ETH"),
            Text(sent_ethereum != null ? "보류중인 보낸 이더 : $sent_ethereum ETH" : "보류중인 보낸 이더 : 0 ETH"),
            Text(received_ethereum != null ? "보류중인 받은 이더 : $received_ethereum ETH" : "보류중인 받은 이더 : 0 ETH"),
          ],
        ),
      ),
    );
  }
}