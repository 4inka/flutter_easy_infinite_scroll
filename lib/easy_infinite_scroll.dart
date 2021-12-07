  // Copyright 2021 4inka

// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:

// 1. Redistributions of source code must retain the above copyright notice,
// this list of conditions and the following disclaimer.

// 2. Redistributions in binary form must reproduce the above copyright
// notice, this list of conditions and the following disclaimer in the
// documentation and/or other materials provided with the distribution.

// 3. Neither the name of the copyright holder nor the names of its contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission.

// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
// NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

library easy_infinite_scroll;

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EasyInfiniteScroll<T> extends StatefulWidget {
  final Future<List<T>> Function() onFetch;
  final Future<List<T>> Function() onRefresh;
  final bool hasMoreData;
  final Widget Function(dynamic data) widgetBuilder;
  final Widget? Function()? loaderBuilder;
  final Widget? Function()? noMoreItemsBuilder;
  final Widget? Function()? noItemsBuilder;
  final String noMoreItemsText;
  final String noItemsText;

  const EasyInfiniteScroll({
    Key? key,
    required this.hasMoreData,
    required this.onFetch,
    required this.onRefresh,
    required this.widgetBuilder,
    this.loaderBuilder,
    this.noMoreItemsBuilder,
    this.noItemsBuilder,
    this.noMoreItemsText = 'No more items',
    this.noItemsText = 'No items',
  }): super(key: key);

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
      if (_scrollController.position.pixels > 0.95 * _scrollController.position.maxScrollExtent && widget.hasMoreData && !_isLoading) {
        await _onFetch();
      }
    });
  }

  Widget? _loaderBuilder() {
    Widget? child = const CircularProgressIndicator();

    if(widget.loaderBuilder != null) {
      child = widget.loaderBuilder!();
    }
    else if (Platform.isIOS) {
      child = const CupertinoActivityIndicator();
    }

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: child
    );
  }

  Widget? _noMoreItemsBuilder() {
    Widget? child = Text(
      widget.noMoreItemsText,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 16,
        fontWeight: FontWeight.bold
      )
    );

    if(widget.noMoreItemsBuilder != null) {
      child = widget.noMoreItemsBuilder!();
    }

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 5, bottom: 10),
      child: child
    );
  }

  Widget? _noItemsBuilder(BoxConstraints constraints) {
    Widget? child = Text(
      widget.noItemsText,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 16,
        fontWeight: FontWeight.bold
      )
    );

    if (widget.noItemsBuilder != null) {
      child = widget.noItemsBuilder!();
    }

    return Container(
      width: constraints.maxWidth,
      height: constraints.maxHeight,
      alignment: Alignment.center,
      child: child
    );
  }

  Future<void> _onFetch({ bool isRefresh = false }) async {
    if (!widget.hasMoreData && !isRefresh) {
      return;
    }
    else if (isRefresh) {
      setState(() => _isLoading = true );
      await widget.onRefresh().then((value) {
        setState(() {
          _items.clear();
          _items.addAll(value as List<T>);
          _isLoading = false;
        });
      }).catchError((error) {
        setState(() => _isLoading = false );
        throw(error);
      });
    }
    else {
      setState(() => _isLoading = true );
      await widget.onFetch().then((value) {
        setState(() {
          _items.addAll(value as List<T>);
          _isLoading = false;
        });
      }).catchError((error) {
        setState(() => _isLoading = false );
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
          physics: const BouncingScrollPhysics(),
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: () => _onFetch(isRefresh: true),
              builder: (context, refreshState, pulledExtent, refreshTriggerPullDistance, refreshIndicatorExtent) {
                return _loaderBuilder()!;
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
                    return _loaderBuilder()!;
                  }
                  else if (_items.isEmpty && !widget.hasMoreData) {
                    return _noItemsBuilder(constraints)!;
                  }

                  return _noMoreItemsBuilder()!;
                }
              )
            )
          ]
        );
      }
    );
  }

  @override
  dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
