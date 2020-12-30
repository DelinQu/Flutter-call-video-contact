import 'package:flutter/material.dart';
import 'package:myflutter/src/Call.dart';
import 'package:myflutter/src/Contact.dart';
import 'package:myflutter/src/Video.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}
const iOSLocalizedLabels = false;
//flutter中控件分为无状态<StatelessWidget纯展示，无术语内部必须要有build>和有状态两类<有私有术语>
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //每个项目最外层必须要有MaterialApp
    return MaterialApp(
      title: 'myFlutter', //title，最小化的时候可以看到
      theme: ThemeData(
        primarySwatch: Colors.blue, //主题色
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      //通过home指定首页
      home: MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

//自定义的主页
class _MyHomeState extends State<MyHome> {
  @override
  void initState() {
    super.initState();
    _askPermissions();
  }

  Future<void> _askPermissions() async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus != PermissionStatus.granted) {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.contacts);
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.disabled) {
      Map<PermissionGroup, PermissionStatus> permissionStatus =
      await PermissionHandler()
          .requestPermissions([PermissionGroup.contacts]);
      return permissionStatus[PermissionGroup.contacts] ??
          PermissionStatus.unknown;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      throw PlatformException(
          code: "PERMISSION_DENIED",
          message: "Access to location data denied",
          details: null);
    } else if (permissionStatus == PermissionStatus.disabled) {
      throw PlatformException(
          code: "PERMISSION_DISABLED",
          message: "Location data is not available on device",
          details: null);
    }
  }


  @override
  Widget build(BuildContext context) {
    // 在Flutter中的每一个类都是一个控件
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        //用DefaultTabController包围,使每一个Tabbar都能对应一个页面
        appBar: PreferredSize(
            child: AppBar(
                title: Text("flutter call"),
                centerTitle: true, //居中
                actions: <Widget>[
              //右侧行为按钮
              IconButton(
                color: Colors.black,
                icon: Icon(Icons.cast),
          )
        ],
      ),
            preferredSize: Size.fromHeight(45)),


        drawer: Drawer(
            //侧面栏
            child: ListView(
          //一个列表// 抽屉可能在高度上超出屏幕，所以使用 ListView 组件包裹起来，实现纵向滚动效果
          // 干掉顶部灰色区域
          padding: EdgeInsets.all(0),
          // 所有抽屉中的子组件都定义到这里：
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountEmail: Text('qdl.cs@qq.com'),
              accountName: Text("LinXiaoDe"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1595780602873&di=7f0575b8a8cae012a829fb93fa5c8a04&imgtype=0&src=http%3A%2F%2Fp0.ifengimg.com%2Fpmop%2F2018%2F0809%2FD5AD6058C6F7F813F01E0AF06364286B93F53E27_size21_w600_h399.jpeg'),
              ),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                          'https://pic2.zhimg.com/80/v2-5667cfc00148b02c8aff3f3bc966bacd_720w.jpg')) //背景图片
                  ), //美化当前控件
            ),
            ListTile(
              title: Text('用户反馈'),
              trailing: Icon(
                Icons.feedback,
                color: Colors.blue,
              ),
            ),
            Divider(),
            ListTile(
              title: Text('系统设置'),
              trailing: Icon(
                Icons.settings,
                color: Colors.green,
              ),
            ),
            Divider(),
            ListTile(
              title: Text('发布'),
              trailing: Icon(
                Icons.send,
                color: Colors.deepPurpleAccent,
              ),
            ),
            Divider(),
            ListTile(
              title: Text('注销'),
              trailing: Icon(
                Icons.exit_to_app,
                color: Colors.amberAccent,
              ),
            ),
          ],
        )),
        bottomNavigationBar: Container(
          //底部导航栏
          //美化
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(3),
          ),
          height: 50, //一般tabbar的高度为50
//        borderRadius: BorderRadius.circular(50),
          child: TabBar(
            labelStyle: TextStyle(height: 0, fontSize: 10),
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.keyboard),
                text: "Call",
              ),
              Tab(
                icon: Icon(Icons.ondemand_video),
                text: "VideoCall",
              ),
              Tab(
                icon: Icon(Icons.quick_contacts_dialer_outlined),
                text: "Contacts",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Call(),
            // Camera(),
            Video(),
            //MyCenter(),
            ContactListPage(),
          ],
        ),
      ),
    );
  }
}
