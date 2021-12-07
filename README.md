# Easy Infinite Scroll

<a href="https://www.buymeacoffee.com/4inka" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-violet.png" alt="Buy Me A Pizza" style="height: 60px !important; width: 217px !important;" ></a>


A simple, but flexible and powerful Flutter plugin to handle infinite scroll lists

## Preview
![Preview](https://raw.githubusercontent.com/4inka/flutter_easy_infinite_scroll/main/preview/preview.gif)

## ToDo
* Add retry widget on error 
* Add refresh on empty list

## Usage

In the `pubspec.yaml` of your flutter project, add the following dependency:

``` yaml
dependencies:
  ...
  easy_infinite_scroll: ^1.0.0
```

You can create a simple autocomplete input widget with the following example:

``` dart
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
```
<br/>
In the example above we created a list that has a type of Color, but you can use any other model or datatype you prefer.
<br/>

## API
| Attribute | Type | Required | Description | Default value |
|:---|:---|:---:|:---|:---|
| onFetch | `Future<List<T>> Function()` | :heavy_check_mark: | A Future method that returns a List with the selected data type on fetch |  |
| onRefresh | `Future<List<T>> Function()` | :heavy_check_mark: | A Future method that returns a List with the selected data type on refresh |  |
| hasMoreData | `bool` | :heavy_check_mark: | A bool to determine if the lists has more data to be loaded |  |
| widgetBuilder | `Widget Function(dynamic data)` | :heavy_check_mark: | A function that that receives values for the current data index and returns a widget that can be filled using the param data |  |
| loaderBuilder | `Widget? Function()?` | :x: | A function that can be used to create a widget to display a custom loader |  |
| noMoreItemsBuilder | `Widget? Function()?` | :x: | A function that can be used to create a widget to display a custom `No more items` widget |  |
| noItemsBuilder | `Widget? Function()?` | :x: | A function that can be used to create a widget to display a custom `No items` widget |  |
| noMoreItemsText | `String` | :x: | A `String` param that can be changed to display a different message when there are no more items to load | No more items |
| noItemsText | `String` | :x: | A `String` param that can be changed to display a different message when there are no items to load | No items |

## Issues & Suggestions
If you encounter any issue you or want to leave a suggestion you can do it by filling an [issue](https://github.com/4inka/flutter_easy_infinite_scroll/issues).

### Thank you for the support!