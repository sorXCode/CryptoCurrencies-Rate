import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List currencies;
  List<MaterialColor> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CryptoCurrency'),
      ),
      body: _cryptoWidget(),
    );
  }

  _cryptoWidget() {
    return Container(
      child: FutureBuilder(
        future: _getCurrencies(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            currencies = snapshot.data;
            return ListView.builder(
              itemCount: 50,
              itemBuilder: (BuildContext context, int index) {
                final currency = currencies[index];
                final color = _colors[index % _colors.length];
                return _generateListEntry(currency, color);
              },
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<List> _getCurrencies() async {
    String url = "https://api.coinmarketcap.com/v1/ticker/?limit=50";
    var response = await http.get(url);
    return json.decode(response.body);
  }

  _generateListEntry(Map currency, MaterialColor color) {
    final _name = currency['name'];
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color,
        child: Text(_name[0]),
      ),
      title: Text(
        _name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: _getSubtitleText(
        currency['price_usd'],
        currency['percent_change_1h'],
      ),
      isThreeLine: true,
    );
  }

  _getSubtitleText(String priceInUSD, String percentageChange) {
    final positiveGain = double.parse(percentageChange) > 0;
    TextSpan priceWidget =
        TextSpan(text: "\$$priceInUSD", style: TextStyle(color: Colors.black));
    TextSpan percentageChangeWidget = TextSpan(
        text: "${percentageChange.padLeft(6)}%",
        style: positiveGain
            ? TextStyle(color: Colors.green)
            : TextStyle(color: Colors.red));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: priceWidget,
        ),
        Row(
          children: <Widget>[
            positiveGain
                ? Icon(
                    Icons.arrow_upward,
                    color: Colors.green,
                  )
                : Icon(
                    Icons.arrow_downward,
                    color: Colors.red,
                  ),
            RichText(
              text: percentageChangeWidget,
            ),
          ],
        ),
      ],
    );
  }
}
