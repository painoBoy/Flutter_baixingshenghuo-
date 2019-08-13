import 'package:flutter/material.dart';
import '../model/categoryGoodsList.dart';

//ChangeNotifier的混入是不用管理听众
class CategoryGoodsListProvide with ChangeNotifier{

    List<CategoryListData> goodsList = [];

    getGoodsList(List<CategoryListData> list){
      goodsList = list;
      notifyListeners();
    }
}