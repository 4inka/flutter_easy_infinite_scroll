library easy_infinite_scroll;

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EasyInfiniteScroll extends StatefulWidget {
  final Future<List<Widget>> fetchData;
  final bool hasMoreData;
  final Widget? loaderWidget;
  final Widget? noMoreItemsWidget;

  EasyInfiniteScroll({
    required this.fetchData,
    required this.hasMoreData,
    this.loaderWidget,
    this.noMoreItemsWidget,
  });// : assert(noMoreItemsText.is);

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

  Widget? _buildLoaderWidget() {
    Widget? _loader;
    if(widget.loaderWidget != null) {
      _loader = widget.loaderWidget;
    }
    else if (Platform.isIOS) {
      _loader = CupertinoActivityIndicator();
    }
    else {
      _loader = CircularProgressIndicator();
    }

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: _loader,
    );
  }

  Widget? _buildNoMoreItemsWidget() {
    if(widget.loaderWidget != null) {
      return widget.loaderWidget;
    }

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Text(
        'No more items',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 16,
          fontWeight: FontWeight.bold
        )
      )
    );
  }

  Future<void> _fetchData() async {
    if (_isFirstLoad) {
      setState(() =>_items.add( _buildLoaderWidget()) );
    }

    await widget.fetchData.then((value) {
      setState(() {
        _items.removeLast();
        _items.addAll(value);
        if (widget.hasMoreData) {
          setState(() =>_items.add( _buildLoaderWidget()) );
        }
        else {
          setState(() =>_items.add(_buildNoMoreItemsWidget()) );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      controller: _scrollController,
      itemCount: _items.length,
      itemBuilder: (_, i) {
        return _items[i];
      }
    );
  }
}