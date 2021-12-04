library easy_infinite_scroll;

import 'package:flutter/material.dart';

class EasyInfiniteScroll extends StatefulWidget {
  final Future<List> fetchData;
  final bool hasMoreData;

  EasyInfiniteScroll({
    required this.fetchData,
    required this.hasMoreData
  });

  @override
  _EasyInfiniteScrollState createState() => _EasyInfiniteScrollState();
}

class _EasyInfiniteScrollState extends State<EasyInfiniteScroll> {
  late ScrollController _scrollController;
  final List _items = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async => await _fetchData() );
    _scrollController = ScrollController();
    _scrollController.addListener(() async {
      var triggerFetchMoreSize = 0.9 * _scrollController.position.maxScrollExtent;

      if (_scrollController.position.pixels > triggerFetchMoreSize) {
        _fetchData();
      }
    });
  }

  Future<void> _fetchData() async {
    await widget.fetchData.then((value) {
      setState(() => _items.addAll(value));
    });
  }
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _items.length,
      itemBuilder: (context, index) {
        return _items[index];
      }
    );
  }
}