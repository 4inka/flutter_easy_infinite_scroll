import 'package:easy_infinite_scroll/easy_infinite_scroll.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyHomePage());
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _pageCount = 1;

  Future<List<Color>> _fetchData() async {
    List<Color> _colors = [];

    if (_pageCount <= 3) {
      await Future.delayed(Duration(seconds: 3)).then((value) {
          _colors = List.generate(15, (index) {
            return Colors.pink;
          });
        setState(() {
          _pageCount++;
        });
        print('Page: $_pageCount');
      });
    }
    else {
      print('No more data');
    }

    return _colors;
  }

  Future<List<Color>> _refreshData() async {
    print('ddjdhdssj sssh');
    await Future.delayed(Duration(seconds: 4));
    setState(() {
      _pageCount = 1;
    });
    return List.generate(15, (index) {
      return Colors.pink;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Example'),
        ),
        body: EasyInfiniteScroll<Color>(
          hasMoreData: _pageCount <= 3,
          onFetch: _fetchData(),
          onRefresh: _refreshData(),
          widgetBuilder: (data) {
            return Container(
              width: double.infinity,
              height: 50,
              margin: EdgeInsets.all(5),
              color: data
            );
          },
        )
      ),
    );
  }
}
