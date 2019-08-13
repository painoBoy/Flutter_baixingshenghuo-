// const serviceUrl= 'http://v.jspang.com:8088/baixing/';//jspang测试接口地址
const serviceUrl= 'https://wxmini.baixingliangfan.cn/baixing/';//真实接口地址
const servicePath={
  'homePageContext': serviceUrl+'wxmini/homePageContent', // 商家首页信息
  'homePageBelowConten': serviceUrl+'wxmini/homePageBelowConten', //商城首页热卖商品拉取
  'getCategory': serviceUrl+'wxmini/getCategory', //分类信息
  'getMallGoods': serviceUrl+'wxmini/getMallGoods', //商品分类的商品列表
};