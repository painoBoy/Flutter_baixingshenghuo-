import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_shop/service/service_method.dart';
import '../model/category.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provide/provide.dart';
import '../provide/child_category.dart';
import '../provide/category_goods_list.dart';
import '../model/categoryGoodsList.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

//分类主方法
class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('商品分类'),
        ),
        body: Container(
          child: Row(
            children: <Widget>[
              LeftCategoryNav(),
              Column(
                children: <Widget>[TopCategoryNav(), CategoryGoodsList()],
              )
            ],
          ),
        ));
  }
}

//左侧导航
class LeftCategoryNav extends StatefulWidget {
  @override
  _LeftCategoryNavState createState() => _LeftCategoryNavState();
}

class _LeftCategoryNavState extends State<LeftCategoryNav> {
  List list = [];
  var listIndex = 0; //初始化高亮索引

  @override
  void initState() {
    _getGoodList();
    _getCategory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(180),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(width: 1, color: Colors.black12)),
      ),
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          return _leftInkWell(index);
        },
      ),
    );
  }

  //单个菜单item
  Widget _leftInkWell(int index) {
    bool isClick = false;
    isClick = (index == listIndex) ? true : false;
    return InkWell(
      onTap: () {
        setState(() {
          listIndex = index;
        });
        var childList = list[index].bxMallSubDto;
        var categoryId = list[index].mallCategoryId;
        Provide.value<ChildCategory>(context)
            .getChildCategory(childList, categoryId);
        _getGoodList(categoryId: categoryId);
      },
      child: Container(
        height: ScreenUtil().setHeight(100),
        padding: EdgeInsets.only(left: 10.0),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
            color: isClick ? Color.fromRGBO(236, 236, 236, .8) : Colors.white,
            border:
                Border(bottom: BorderSide(width: 1, color: Colors.black12))),
        child: Text(list[index].mallCategoryName,
            style: TextStyle(fontSize: ScreenUtil().setSp(28))),
      ),
    );
  }

  // 获取左侧导航数据
  void _getCategory() {
    request('getCategory').then((val) {
      var data = json.decode(val.toString());
      CategoryModel category = CategoryModel.fromJson(data);
      setState(() {
        list = category.data;
        Provide.value<ChildCategory>(context).getChildCategory(
            list[0].bxMallSubDto, list[0].mallCategoryId); //初始化将数据传给provide
      });
    });
  }

  void _getGoodList({String categoryId}) {
    var data = {
      'categoryId': categoryId == null ? "4" : categoryId,
      'categorySubId': "",
      'page': 1
    };
    request('getMallGoods', formData: data).then((val) {
      var data = json.decode(val.toString());
      CategoryGoodsListModel goodsList = CategoryGoodsListModel.fromJson(data);
      Provide.value<CategoryGoodsListProvide>(context)
          .getGoodsList(goodsList.data);
      print('>>>>>>>>>>>>>>>>>>>:${list[0].goodsName}');
    });
  }
}

//顶部子导航
class TopCategoryNav extends StatefulWidget {
  TopCategoryNav({Key key}) : super(key: key);

  _TopCategoryNavState createState() => _TopCategoryNavState();
}

class _TopCategoryNavState extends State<TopCategoryNav> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Provide<ChildCategory>(builder: (context, child, childCategory) {
        return Container(
          height: ScreenUtil().setHeight(80.0),
          width: ScreenUtil().setWidth(570),
          decoration: BoxDecoration(
              border: Border(
            bottom: BorderSide(width: 1, color: Colors.black12),
          )),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: childCategory.childCategoryList.length,
            itemBuilder: (context, index) {
              return _item(childCategory.childCategoryList[index], index);
            },
          ),
        );
      }),
    );
  }

  Widget _item(BxMallSubDto item, int index) {
    bool isClick = false;
    isClick = (index == Provide.value<ChildCategory>(context).childIndex)
        ? true
        : false;
    return InkWell(
      onTap: () {
        Provide.value<ChildCategory>(context).changeChildIndex(index);
        _getGoodList(item.mallSubId);
      },
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
        child: Text(
          item.mallSubName,
          style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              color: isClick ? Colors.pink[600] : Colors.black),
        ),
      ),
    );
  }

  void _getGoodList(String categorySubId) {
    var data = {
      'categoryId': Provide.value<ChildCategory>(context).categoryId,
      'categorySubId': categorySubId,
      'page': 1
    };
    request('getMallGoods', formData: data).then((val) {
      var data = json.decode(val.toString());
      CategoryGoodsListModel goodsList = CategoryGoodsListModel.fromJson(data);
      // Provide.value<CategoryGoodsListProvide>(context).getGoodsList(goodsList.data);
      if (goodsList.data == null) {
        Provide.value<CategoryGoodsListProvide>(context).getGoodsList([]);
      } else {
        Provide.value<CategoryGoodsListProvide>(context)
            .getGoodsList(goodsList.data);
      }
    });
  }
}

//商品列表
class CategoryGoodsList extends StatefulWidget {
  @override
  _CategoryGoodsListState createState() => _CategoryGoodsListState();
}

class _CategoryGoodsListState extends State<CategoryGoodsList> {
  @override
  void initState() {
    // _getGoodList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Provide<CategoryGoodsListProvide>(
        builder: (context, child, data) {
          if (data.goodsList.length == 0) {
            return Center(
              child: Text("暂时没有数据...",style: TextStyle(color: Colors.black26),),
            );
          } else {
            return Container(
                width: ScreenUtil().setWidth(570),
                child: ListView.builder(
                  itemCount: data.goodsList.length,
                  itemBuilder: (context, index) {
                    return _listWidget(data.goodsList, index);
                  },
                ));
          }
        },
      ),
    );
  }

  //获取商品列表数据

  //商品图片
  Widget _goodsImage(newList, index) {
    return Container(
      width: ScreenUtil().setWidth(200),
      child: Image.network(newList[index].image),
    );
  }

  //商品名称
  Widget _goodsName(newList, index) {
    return Container(
      padding: EdgeInsets.all(5.0),
      width: ScreenUtil().setWidth(370),
      child: Text(
        newList[index].goodsName,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  //商品价格
  Widget _goodsPrice(newList, index) {
    return Container(
      padding: EdgeInsets.fromLTRB(5, 20, 5, 0),
      width: ScreenUtil().setWidth(370),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '￥${newList[index].presentPrice}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Colors.pink[600], fontSize: ScreenUtil().setSp(30)),
          ),
          Text('￥${newList[index].oriPrice}',
              style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.black26,
                  fontSize: ScreenUtil().setSp(28))),
        ],
      ),
    );
  }

  //单个商品Item
  Widget _listWidget(List newList, int index) {
    return InkWell(
      onTap: () {},
      child: Container(
          padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                  bottom: BorderSide(width: 1.0, color: Colors.black12))),
          child: Row(
            children: <Widget>[
              _goodsImage(newList, index),
              Column(
                children: <Widget>[
                  _goodsName(newList, index),
                  _goodsPrice(newList, index),
                ],
              )
            ],
          )),
    );
  }
}
