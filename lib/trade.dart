import 'package:flutter/material.dart';

import 'AppDrawer.dart';

class TradePage extends StatelessWidget {
  const TradePage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("중고 거래", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: AppDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SearchBar(
              trailing: [Icon(Icons.search)],
              constraints: BoxConstraints(maxWidth: 300, minHeight: 50)
            ),
            Container(
              margin: const EdgeInsets.only(top: 40),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                children: [
                  Image(
                    image: AssetImage("assets/images/test_trade_book.jpg"),
                    width: 200,
                    height: 200,
                  ),
                  Text("제품명: 스프링부트3 자바 백엔드 개발 입문"),
                  Text("가격: 25,000원"),
                  Text("설명: @@@@@@@@@@@@@@@@@"),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                children: [
                  Image(
                    image: AssetImage("assets/images/test_trade_book.jpg"),
                    width: 200,
                    height: 200,
                  ),
                  Text("제품명: 스프링부트3 자바 백엔드 개발 입문"),
                  Text("가격: 25,000원"),
                  Text("설명: @@@@@@@@@@@@@@@@@"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
