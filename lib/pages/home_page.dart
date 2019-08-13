import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/material_footer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import '../service/service_method.dart';
import 'dart:io';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  int page = 1;
  List<Map> hotGoodsList = [];
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    _getHotGoods();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("百姓生活+")),
        body: FutureBuilder(
          future: request('homePageContext',
              formData: {'lon': '104.10194', 'lat': '30.65984'}),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = json.decode(snapshot.data.toString());
              List<Map> swiperDataList =
                  (data['data']['slides'] as List).cast(); // 轮播数据
              List<Map> gridDataList =
                  (data['data']['category'] as List).cast(); // 导航数据
              String bannerPic =
                  data['data']['advertesPicture']['PICTURE_ADDRESS']; //广告banner
              if (gridDataList.length > 10) {
                gridDataList.removeRange(10, gridDataList.length);
              }
              String leaderImage =
                  data['data']['shopInfo']['leaderImage']; //店长图片
              String leaderPhone =
                  data['data']['shopInfo']['leaderPhone']; //店长电话
              List<Map> recommendList =
                  (data['data']['recommend'] as List).cast(); // 商品推荐
              String pictureUrl =
                  data['data']['floor1Pic']['PICTURE_ADDRESS']; //楼层1标题图片
              String floor2Title =
                  data['data']['floor2Pic']['PICTURE_ADDRESS']; //楼层1的标题图片
              String floor3Title =
                  data['data']['floor3Pic']['PICTURE_ADDRESS']; //楼层1的标题图片
              List<Map> floor1 =
                  (data['data']['floor1'] as List).cast(); //楼层1商品和图片
              List<Map> floor2 =
                  (data['data']['floor2'] as List).cast(); //楼层1商品和图片
              List<Map> floor3 =
                  (data['data']['floor3'] as List).cast(); //楼层1商品和图片
              return EasyRefresh(
                // footer:ClassicalFooter(
                //   bgColor: Colors.white,
                //   textColor: Colors.pink[600],
                //   noMoreText: '',
                //   loadReadyText: '上拉加载...',
                // ),
                footer: MaterialFooter(),
                firstRefresh: true,
                child: ListView(
                  children: <Widget>[
                    SwiperDiy(swiperDataList: swiperDataList),
                    NavigatorGrid(gridDataList: gridDataList),
                    BannerView(bannerPicture: bannerPic),
                    LeaderPhoneNum(
                        leaderImage: leaderImage, leaderPhone: leaderPhone),
                    Recommend(recommendList: recommendList),
                    FloorTitle(pictureUrl: pictureUrl),
                    FloorContent(goodsList: floor1),
                    FloorTitle(pictureUrl: floor2Title),
                    FloorContent(goodsList: floor2),
                    FloorTitle(pictureUrl: floor3Title),
                    FloorContent(goodsList: floor3),
                    _hotGoods(),
                  ],
                ),
                onLoad: () async {
                  print('开始加载更多');
                  _getHotGoods();
                },
              );
            } else {
              return Center(
                child: Text("加载中..."),
              );
            }
          },
        ));
  }

  // 获取火爆商品数据
  void _getHotGoods() {
    var formPage = {'page': page};
    request('homePageBelowConten', formData: formPage).then((val) {
      var data = json.decode(val.toString());
      List<Map> newGoodsList = (data['data'] as List).cast();
      setState(() {
        hotGoodsList.addAll(newGoodsList);
        page++;
      });
    });
  }

  //火爆商品标题
  Widget _hotTitle() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 10.0, 0, 10.0),
      alignment: Alignment.center,
      color: Colors.transparent,
      child: Text("火爆商品", style: TextStyle(color: Colors.pink[600])),
    );
  }

  Widget _wrapList() {
    if (hotGoodsList.length != 0) {
      List<Widget> listWidget = hotGoodsList.map((item) {
        return InkWell(
          onTap: () {},
          child: Container(
            width: ScreenUtil().setWidth(372.0),
            color: Colors.white,
            padding: EdgeInsets.all(5.0),
            margin: EdgeInsets.only(bottom: 5.0),
            child: Column(
              children: <Widget>[
                Image.network(item['image'],
                    width: ScreenUtil().setWidth(370.0)),
                Text(
                  item['name'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.pink[600],
                      fontSize: ScreenUtil().setSp(26)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text(
                        '￥${item['mallPrice']}',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(25),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 10.0),
                      child: Text(
                        '￥${item['price']}',
                        style: TextStyle(
                            color: Colors.black26,
                            fontSize: ScreenUtil().setSp(25),
                            decoration: TextDecoration.lineThrough),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }).toList();

      return Wrap(
        spacing: 2,
        children: listWidget,
      );
    } else {
      return Text('');
    }
  }

  Widget _hotGoods() {
    return Container(
      child: Column(
        children: <Widget>[_hotTitle(), _wrapList()],
      ),
    );
  }
}

// 首页轮播组件编写
class SwiperDiy extends StatelessWidget {
  final List swiperDataList;
  SwiperDiy({Key key, this.swiperDataList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(333.0),
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          return Image.network("${swiperDataList[index]['image']}",
              fit: BoxFit.fill);
        },
        itemCount: swiperDataList.length,
        pagination: new SwiperPagination(),
        autoplay: true,
      ),
    );
  }
}

// //Grid导航
class NavigatorGrid extends StatelessWidget {
  final List gridDataList;
  NavigatorGrid({Key key, this.gridDataList}) : super(key: key);

  @override
  Widget _gridViewItemUI(BuildContext context, item) {
    return InkWell(
      onTap: () {
        print("click");
      },
      child: Column(
        children: <Widget>[
          Image.network(item['image'], width: ScreenUtil().setWidth(90.0)),
          Text(item['mallCategoryName']),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(330.0),
      padding: EdgeInsets.all(3.0),
      child: GridView.count(
        crossAxisCount: 5,
        padding: EdgeInsets.all(4.0),
        children: gridDataList.map((item) {
          return _gridViewItemUI(context, item);
        }).toList(),
      ),
    );
  }
}

//banner广告
class BannerView extends StatelessWidget {
  final String bannerPicture;
  BannerView({Key key, this.bannerPicture}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.network(bannerPicture),
    );
  }
}

//店长电话
class LeaderPhoneNum extends StatelessWidget {
  final String leaderImage;
  final String leaderPhone;
  LeaderPhoneNum({Key key, this.leaderImage, this.leaderPhone})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: _launchURL,
        child: Image.network(leaderImage),
      ),
    );
  }

  void _launchURL() async {
    // 调用lunch包拨打电话
    String url = 'tel:' + leaderPhone;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'url不能正常访问';
    }
  }
}

//商品推荐
class Recommend extends StatelessWidget {
  final List recommendList;
  Recommend({Key key, this.recommendList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _titleWidget(),
            _recommendList(context),
          ],
        ),
      ),
    );
  }

  //推荐商品title
  Widget _titleWidget() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.fromLTRB(10.0, 2.0, 0, 5.0),
      decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border(bottom: BorderSide(width: 0.5, color: Colors.black12))),
      child: Text(
        '商品推荐',
        style: TextStyle(color: Colors.pink[600]),
      ),
    );
  }

  //单个商品item
  Widget _item(index, context) {
    return InkWell(
      onTap: () {},
      child: Container(
        width: ScreenUtil().setWidth(250),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            color: Colors.white,
            border:
                Border(left: BorderSide(width: 0.5, color: Colors.black12))),
        child: Column(
          children: <Widget>[
            Image.network(recommendList[index]['image']),
            Text('￥${recommendList[index]['mallPrice']}',
                style: TextStyle(fontSize: ScreenUtil().setSp(28))),
            Text(
              '￥${recommendList[index]['price']}',
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  //横向列表组件
  Widget _recommendList(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(360.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recommendList.length,
        itemBuilder: (context, index) {
          return _item(index, context);
        },
      ),
    );
  }
}

//楼层广告图片
class FloorTitle extends StatelessWidget {
  final String pictureUrl;

  FloorTitle({Key key, this.pictureUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 10.0, 0, 10.0),
      child: InkWell(
        onTap: () {},
        child: Image.network(pictureUrl),
      ),
    );
  }
}

//楼层内容
class FloorContent extends StatelessWidget {
  final List goodsList;
  FloorContent({Key key, this.goodsList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          _firstRow(),
          _otherItem(),
        ],
      ),
    );
  }

  //中间三张图
  Widget _firstRow() {
    return Row(
      children: <Widget>[
        _goodsItem(goodsList[0]),
        Column(
          children: <Widget>[
            _goodsItem(goodsList[1]),
            _goodsItem(goodsList[2]),
          ],
        ),
      ],
    );
  }

  //第三层楼层
  Widget _otherItem() {
    return Row(
      children: <Widget>[
        _goodsItem(goodsList[3]),
        _goodsItem(goodsList[4]),
      ],
    );
  }

  Widget _goodsItem(Map goods) {
    return Container(
      width: ScreenUtil().setWidth(375.0),
      child: InkWell(
        onTap: () {
          print("点击商品");
        },
        child: Image.network(goods['image']),
      ),
    );
  }
}

class HotGoods extends StatefulWidget {
  _HotGoodsState createState() => _HotGoodsState();
}

//火爆商品
class _HotGoodsState extends State<HotGoods> {
  void initState() {
    super.initState();
    request('homePageBelowConten', formData: 1).then((val) {
      print(val);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('1111'),
    );
  }
}
