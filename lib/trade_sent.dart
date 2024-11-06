import 'dart:convert';
import 'package:clover/trade_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart' as http;
import 'package:clover/api/api.dart';
import 'AppDrawer.dart';

class TradePage_sent extends StatefulWidget {
  const TradePage_sent({super.key});

  @override
  State<TradePage_sent> createState() => _TradePage_sent();
}

class _TradePage_sent extends State<TradePage_sent> {
  String result = "No data";

  final FlutterSecureStorage storage = FlutterSecureStorage();
  List tradeList = [];
  List filteredPosts = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  int? custNum;
  String ethereumAddress = "";

  @override
  void initState() {
    super.initState();
    tokenCheck();
  }

  void tokenCheck() async {
    var token = await storage.read(key: 'jwt_token');
    if (token != null) {
      final response = await http.get(
        Uri.parse(API.host + "/profile"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        setState(() {
          custNum = jsonResponse['user']['custNum'];
          custNum_find_wallet(custNum!);
        });
        return;
      }
    }
  }

  Future<void> custNum_find_wallet(int custNum) async {
    try {
      final response = await http.post(
        Uri.parse(API.host + '/custNum_find_wallet'),
        body: json.encode({'custNum': custNum}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        var jsonResponse = json.decode(response.body);
        setState(() {
          ethereumAddress = jsonResponse['wallet'];
          t_list(ethereumAddress);
        });
      }
    } catch (e) {
    }
  }

  Future<void> t_list(String ethereumAddress) async {
    try {
      final response = await http.post(
        Uri.parse(API.host + '/t_trade_sent_view'),
          body: jsonEncode({'payerAddress' : ethereumAddress}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        setState(() {
          tradeList = json.decode(response.body)['results'];
          filteredPosts = List.from(tradeList);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        showErrorDialog('보내신 이더중 보류 중인 이더가 없습니다.');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showErrorDialog('보내신 이더중 보류 중인 이더중 오류가 발생했습니다.');
    }
  }

  Future<String> custNumFind(int custNum) async {
    try {
      final response = await http.post(
        Uri.parse(API.host + '/custNum_find'),
        body: json.encode({'custNum': custNum}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        var jsonResponse = json.decode(response.body);
        return jsonResponse['name'];
      } else {
        return '오류';
      }
    } catch (e) {
      return '오류';
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('오류'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('확인'),
              ),
            ],
          ),
    );
  }

  Future<void> t_trade_sendPayment(int custNum) async {
    try {
      final response = await http.post(
        Uri.parse(API.host + '/t_trade_sendPayment'),
        body: jsonEncode({
          'custNum': custNum,
          'payerAddress' : ethereumAddress,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          showErrorDialog('이더를 보냈습니다.');
        });
      } else if (response.statusCode == 500) {
        setState(() {
          showErrorDialog('보류 기간이 지났습니다.');
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

  Future<void> holdPayment(int custNum) async {
    try {
      final response = await http.post(
        Uri.parse(API.host + '/holdPayment'),
        body: jsonEncode({
          'custNum': custNum,
          'payerAddress' : ethereumAddress,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          showErrorDialog('신고되었습니다.');
        });
      } else if (response.statusCode == 400) {
        setState(() {
          showErrorDialog('이미 신고되어 보류 중인 이더입니다.');
        });
      } else if (response.statusCode == 402) {
        setState(() {
          showErrorDialog('보류 중인 이더가 없습니다.');
        });
      } else {
        setState(() {
          showErrorDialog('다시 시도해주세요.');
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
      appBar: AppBar(
        title: Text("보류 중인 보낸 이더 확인", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: () {
              t_list(ethereumAddress); },
            child: Text('리로드'),
          ),
          SizedBox(height: 5.0),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: filteredPosts.length,
              itemBuilder: (context, index) {
                return _buildCommunityPost(
                  filteredPosts[index]['itemKey'],
                  filteredPosts[index]['custNum'],
                  filteredPosts[index]['title'],
                  filteredPosts[index]['name'],
                  filteredPosts[index]['image1'],
                  filteredPosts[index]['content'],
                  filteredPosts[index]['price'],
                  filteredPosts[index]['rdate'],
                  filteredPosts[index]['amous'],
                  filteredPosts[index]['remainingTime_days'],
                  filteredPosts[index]['remainingTime_hours'],
                  filteredPosts[index]['remainingTime_minutes'],
                  filteredPosts[index]['remainingTime_seconds'],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityPost(int itemKey, int custNum, String title,
      String name, String image1, String content,
      int price, String rdate, String amous,
      int remainingTime_days, int remainingTime_hours, remainingTime_minutes, remainingTime_seconds) {
    return GestureDetector(
      // onTap: () {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => TradePage_view(itemKey: itemKey),
      //     ),
      //   );
      // },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "상품명 : " + name,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "가격 : " + price.toString() + " ETH",
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          FutureBuilder<String>(
                            future: custNumFind(custNum),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Text(
                                  "판매자 : ${snapshot.data}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return const Text(
                                  "구매자 정보 불러오기 실패",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red,
                                  ),
                                );
                              } else {
                                return const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 5),
                          Text(
                            remainingTime_days == 0 && remainingTime_hours == 0 && remainingTime_minutes == 0 && remainingTime_seconds == 0
                                ? "남은 보류 기간 : 보류 기간이 끝났습니다."
                                : "남은 보류 기간 : $remainingTime_days 일 $remainingTime_hours 시 $remainingTime_minutes 분 $remainingTime_seconds 초\n남았습니다.",
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (image1 != null && image1.isNotEmpty)
                      Container(
                        width: 90,
                        height: 90,
                        margin: const EdgeInsets.only(left: 10),
                        child: Image.network(
                          '${API.host}/$image1',
                          fit: BoxFit.cover,
                        ),
                      ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        holdPayment(custNum);
                      },
                      child: Text('신고'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        t_trade_sendPayment(custNum);
                      },
                      child: Text('보류중인 이더 보내기'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
