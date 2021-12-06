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
  bool _hasMoreData = true;

  Future<List<Color>> _fetchData() async {
    print(_pageCount);
    if (_pageCount <= 0) {
      await Future.delayed(Duration(seconds: 3));
      setState(() => _pageCount++);
      print('Page: $_pageCount');
      return List.generate(15, (index) {
        return Colors.pink;
      });
    }

    print('No more data');
    setState(() => _hasMoreData = false);

    return [];
  }

  Future<List<Color>> _refreshData() async {
    await Future.delayed(Duration(seconds: 3));
    setState(() {
      _pageCount = 1;
      _hasMoreData = true;
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
          hasMoreData: _hasMoreData,
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
