import 'package:flutter/material.dart';
import '../model/category.dart';

//ChangeNotifier的混入是不用管理听众
class ChildCategory with ChangeNotifier{

    List<BxMallSubDto> childCategoryList = [];
    int childIndex = 0 ; //顶部小类索引
    String categoryId = '4'; //大类Id 

    getChildCategory(List list,String id){
      categoryId = id;
      childIndex = 0 ;
      childCategoryList=list;
      notifyListeners();
    }

    //改变子类索引
    changeChildIndex (index){
      childIndex = index ; 
      notifyListeners();
    }
}