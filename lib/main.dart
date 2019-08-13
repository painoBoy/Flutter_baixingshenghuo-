import 'package:flutter/material.dart';
import './pages/index_page.dart';
import 'package:provide/provide.dart';
import './provide/counter.dart';
import './provide/child_category.dart';
import './provide/category_goods_list.dart';

void main(){
  var counter =Counter();
  var childCategory=ChildCategory();
  var categoryGoodsList  =CategoryGoodsListProvide();
  var providers  =Providers();
  providers
    ..provide(Provider<Counter>.value(counter))
    ..provide(Provider<ChildCategory>.value(childCategory))
    ..provide(Provider<CategoryGoodsListProvide>.value(categoryGoodsList));
  runApp(ProviderNode(child:MyApp(),providers:providers));
}

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // debugShowCheckedModeBanner: false,
      title: '百姓生活+',
      theme: ThemeData(
        primaryColor: Colors.pink[600]
      ),
      home: IndexPage(),
    );
  }
}