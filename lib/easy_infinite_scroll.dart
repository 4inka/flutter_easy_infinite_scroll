library easy_infinite_scroll;

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EasyInfiniteScroll extends StatefulWidget {
  final Future<List<Widget>> fetchData;
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
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await _fetchData();
      setState(() => _isFirstLoad = false );
    });
    _scrollController = ScrollController();
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        await _fetchData();
      }
    });
  }

  Widget _buildLoader() {
    Widget _loader;
    if (Platform.isIOS) {
      _loader = CupertinoActivityIndicator();
    }
    else {
      _loader = CircularProgressIndicator();
    }

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 5),
      child: _loader,
    );
  }

  Future<void> _fetchData() async {
    if (_isFirstLoad) {
      setState(() =>_items.add( _buildLoader() ));
    }

    await widget.fetchData.then((value) {
      setState(() {
        _items.removeLast();
        _items.addAll(value);
        if (widget.hasMoreData) {
          print('Not done yet');
          setState(() =>_items.add( _buildLoader() ));
        }
        else {
          print('Done');
          setState(() =>_items.add(
            Center(
              child: Text('Loaded last item')
            )
          ));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _items.length,
      itemBuilder: (_, i) {
        return _items[i];
      }
    );
  }
}