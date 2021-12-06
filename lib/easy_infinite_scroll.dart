library easy_infinite_scroll;

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EasyInfiniteScroll<T> extends StatefulWidget {
  final Future<List<T>> Function() onFetch;
  final Future<List<T>> Function() onRefresh;
  final bool hasMoreData;
  final Widget Function(dynamic data) widgetBuilder;
  final Widget? loaderWidget;
  final Widget? noMoreItemsWidget;

  EasyInfiniteScroll({
    Key? key,
    required this.hasMoreData,
    required this.onFetch,
    required this.onRefresh,
    required this.widgetBuilder,
    this.loaderWidget,
    this.noMoreItemsWidget,
  }) : super(key: key);// : assert(noMoreItemsText.is);

  @override
  _EasyInfiniteScrollState createState() => _EasyInfiniteScrollState<T>();
}

class _EasyInfiniteScrollState<T> extends State<EasyInfiniteScroll> {
  final ScrollController _scrollController = ScrollController();
  final List<T> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async => await _onFetch() );
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && widget.hasMoreData) {
        await _onFetch();
      }
    });
  }

  Widget? _setLoaderWidget() {
    if(widget.loaderWidget != null) {
      return widget.loaderWidget;
    }
    else if (Platform.isIOS) {
      return CupertinoActivityIndicator();
    }
    else {
      return CircularProgressIndicator();
    }
  }

  Widget? _buildLoaderWidget() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: _setLoaderWidget()
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

  Future<void> _onFetch({ bool isRefresh = false }) async {
    if (!widget.hasMoreData) return;
    else if (isRefresh) {print('Is refrweshin');
      _isLoading = true;
      await widget.onRefresh().then((value) {
        _items.clear();
        _items.addAll(value as List<T>);
        _isLoading = false;
      }).catchError((error) {
        _isLoading = false;
        throw(error);
      });
    }
    else {
      _isLoading = true;
      await widget.onFetch().then((value) {
        _items.addAll(value as List<T>);
        _isLoading = false;
      }).catchError((error) {
        _isLoading = false;
        throw(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomScrollView(
          primary: false,
          shrinkWrap: true,
          controller: _scrollController,
          physics: BouncingScrollPhysics(),
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: () => _onFetch(isRefresh: true),
              builder: (context, refreshState, pulledExtent, refreshTriggerPullDistance, refreshIndicatorExtent) {
                return _buildLoaderWidget()!;
              }
            ),
            SliverToBoxAdapter(
              child: ListView.builder(
                primary: false,
                shrinkWrap: true,
                itemCount: _items.length + 1,
                itemBuilder: (ctx, i) {
                  if (i < _items.length) {
                    return widget.widgetBuilder(_items[i]);
                  }
                  else if(_isLoading || widget.hasMoreData) {
                    return _buildLoaderWidget()!;
                  }
                  else if (_items.isEmpty && !widget.hasMoreData) {
                    return Container(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      alignment: Alignment.center,
                      child: Text('Empty list')
                    );
                  }

                  return _buildNoMoreItemsWidget()!;
                }
              )
            )
          ]
        );
      }
    );
  }

  dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
