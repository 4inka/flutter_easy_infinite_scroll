import 'package:easy_infinite_scroll/easy_infinite_scroll.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyHomePage());
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _pageCount = 1;

  Future<List<Color>> _fetchData() async {
    List<Color> _colors = [];

    if (_pageCount <= 3) {
      await Future.delayed(const Duration(milliseconds: 1500)).then((value) {
        _colors = List.generate(15, (index) {
          return Colors.pink;
        });
        setState(() => _pageCount++ );
      });
    }

    return _colors;
  }

  Future<List<Color>> _refreshData() async {
    List<Color> _colors = [];

    await Future.delayed(const Duration(milliseconds: 1500)).then((value) {
      _colors = List.generate(15, (index) {
        return Colors.pink;
      });
      // We loaded the first part of data and want to load the second part on next fetch
      // If we set this to 1, it will fetch the first piece of data twice
      setState(() => _pageCount = 2 );
    });

    return _colors;
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
          title: const Text('Example'),
        ),
        body: EasyInfiniteScroll<Color>(
          hasMoreData: _pageCount <= 3,
          onFetch: () async => _fetchData(),
          onRefresh: () async => _refreshData(),
          widgetBuilder: (data) {
            return Container(
              width: double.infinity,
              height: 50,
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: data,
                borderRadius: BorderRadius.circular(5)
              )
            );
          }
        )
      )
    );
  }
}
