## 用Flutter构建一个 视频 / 通话 / 联系人管理 应用

​																																																			——created by qdl in 2020/11/29

![image-20201129161550357](https://i.loli.net/2020/12/30/e4i5HS3toZBCLg8.png) 

目录：

[TOC]

这是编程务实的第三个实验， 要完成一个简单的拨号器。在此需求基础上，我使用Flutter添加了一些全新的功能，包括视频通话，观众视角通话，联系人管理等功能， 尽我最大所能...美化（救命 ，UI  真的尽力了....怎么调  都  这么丑）， 下面是一个简易的Demo展示:

![call](https://i.loli.net/2020/12/30/UfuvOJjxFD4LHdC.gif) ![contacts](https://i.loli.net/2020/12/30/3LnrfWiUvkpIZMO.gif)![video](https://i.loli.net/2020/12/30/5WfU6DIdeRhLXN1.gif)



## 项目目录：

```bash
$ ls
android  build  ios  lib  myflutter.iml  pubspec.lock  pubspec.yaml  README.md  test
$ tree lib/
lib/
├── main.dart
├── src
│   ├── Call.dart
│   ├── Contact.dart
│   ├── Video.dart
│   └── VideoPage.dart
└── utils
    └── settings.dart
```



## 项目依赖

- `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  cool_ui: "^0.1.14"
  # 视频通话
  agora_rtc_engine: ^3.1.3
  # 电话调用
  url_launcher: ^5.4.2
  # 联系人
  contacts_service:
  # 国际化
  intl: ^0.16.0
  # 权限
  permission_handler: ^3.0.0
```

- `第三方API`

为了运行视频通话， 你还需要创建一个Agora帐户并获取一个 AppID和Token，获取方法如下：

1. 在[agora.io](https://dashboard.agora.io/signin/)创建开发人员帐户。完成注册过程后，您将被重定向到仪表板页面。
2. 在左侧的仪表板树中导航到**项目** > **项目列表**。
3. 将从仪表板获取的 App ID 复制到文本文件中。您将在启动应用程序时用到它。
4. Agora官网： [https://dashboard.agora.io/signin/](https://dashboard.agora.io/signin/)





## 手机权限

- 读写联系人
- 网络权限
- WIFI权限

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.READ_CONTACTS" />
<uses-permission android:name="android.permission.WRITE_CONTACTS" />
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
```



## 步骤一： Call.dart

### (1) 构建键盘

- 实现思路：

创建一个数组number，存储[1,2,3,4,5,6,7,8,9,"call",0,"del"]， 顺序遍历他们，渲染按键，返回组件

```dart
 //处理输入
void _handlerResult(numberitem) {
  if (numberitem == 'call') {
    launch("tel://" + phoneStr);
    // Toast.show('拨号失败！');
    print("拨打电话完成");
    return;
  } else if (numberitem == 'del') {
    if (outputnumber.length == 0) return;
    outputnumber.removeAt(outputnumber.length - 1);
  } else
    outputnumber.add(numberitem);
  setState(() {
    phoneStr = outputnumber.join();
  });
}

//渲染按钮
Widget _biildeKeysItem(index) {
  if (index == "call")
    return Container(
      width: (MediaQuery.of(context).size.width / 3 - 8.0) - 14.0,
      height: (MediaQuery.of(context).size.height / 6 - 38.0) - 14.0,
      // color: Colors.tealAccent,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),

        ///圆角
        //border: Border.all(color:Colors.black45,width: 1, ),///边框颜色、宽
      ),
      child: RaisedButton(
          onPressed: () {
            _handlerResult(index);
            print(index);
            telno.text = phoneStr;
          },
          color: Colors.blue,
          shape: CircleBorder(
            side: BorderSide(
              //color: Colors.black12,
              //style: BorderStyle.solid,
              style: BorderStyle.none,
            ),
          ),
          child: Icon(
            Icons.add_ic_call_outlined,
            color: Colors.tealAccent,
          )),
    );
  else if (index == "del")
    return Container(
      width: (MediaQuery.of(context).size.width / 3 - 8.0) - 14.0,
      height: (MediaQuery.of(context).size.height / 6 - 38.0) - 14.0,
      // color: Colors.tealAccent,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),

        ///圆角
        //border: Border.all(color:Colors.black45,width: 1, ),///边框颜色、宽
      ),
      child: RaisedButton(
          onPressed: () {
            _handlerResult(index);
            print(index);
            telno.text = phoneStr;
          },
          color: Colors.blue,
          shape: CircleBorder(
            side: BorderSide(
              //color: Colors.black12,
              //style: BorderStyle.solid,
              style: BorderStyle.none,
            ),
          ),
          child: Icon(
            Icons.backspace_outlined,
            color: Colors.tealAccent,
          )),
    );
  else
    return Container(
      width: (MediaQuery.of(context).size.width / 3 - 8.0) - 14.0,
      height: (MediaQuery.of(context).size.height / 6 - 38.0) - 14.0,
      // color: Colors.tealAccent,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: RaisedButton(
        onPressed: () {
          _handlerResult(index);
          print(index);
          telno.text = phoneStr;
        },
        color: Colors.blue,
        shape: CircleBorder(
          side: BorderSide(
            //color: Colors.black12,
            //style: BorderStyle.solid,
            style: BorderStyle.none,
          ),
        ),
        child: Text(index.toString(),
            style: TextStyle(fontSize: 25, color: Colors.white)),
      ),
    );
}

//渲染按钮列表
List<Widget> _builderList() {
  return number.map((e) {
    return _biildeKeysItem(e);
  }).toList();
}

//渲染键盘组件
Widget _builderKeys(context) {
  return Container(
    height: MediaQuery.of(context).size.height / 2,
    width: MediaQuery.of(context).size.width,
    padding: EdgeInsets.all(8.0),
    // color: Colors.white,
    child: Center(
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 8.0,
        runSpacing: 8.0,
        children: _builderList(),
      ),
    ),
  );
}
```

- 绑定事件：

当触发数字按键的时候，将输入的字段添加到`outputnumber`中，并且更新号码值`phoneStr`; 触发call按键的时候，调用通话；触发del的时候，从`outputnumber`

尾部去掉一个数，更新`phoneStr`。重点要介绍的是如何调用系统通话：

- 依赖：

url_launcher 插件是支持在app中打开外部链接用的。链接可以是一般的http/https/ftp等链接，也可以是手机中的app链接。

比如：微信 wechat:// 支付宝 alipay:// 等等。添加依赖：

```yaml
# 电话调用
url_launcher: ^5.4.2
```

- 代码实现：

```dart
  //处理输入
  void _handlerResult(numberitem) {
    if (numberitem == 'call') {
      launch("tel://" + phoneStr);
      // Toast.show('拨号失败！');
      print("拨打电话完成");
      return;
    } else if (numberitem == 'del') {
      if (outputnumber.length == 0) return;
      outputnumber.removeAt(outputnumber.length - 1);
    } else
      outputnumber.add(numberitem);
    setState(() {
      phoneStr = outputnumber.join();
    });
  }
```



### (2)构建文本框

文本框构建很简单，注意一点，由于要使用自定义的键盘，所以要防止文本框触发之后弹起系统键盘，因此需要将其设置为只读：`readOnly: true,`

- 代码实现：

```bash
//文本框组件
Widget buildText() {
  return Container(
      padding: EdgeInsets.all(10.0),
      child: TextField(
        style: TextStyle(color: Colors.blueAccent, fontSize: 20.0),
        readOnly: true,
        controller: telno,
        cursorColor: Colors.green,
        decoration: InputDecoration(
          labelText: "输入电话",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
        ),
      ));
}
```



### (3) 实现build，返回组件

- 组件渲染好了，可以实现build将其返回了。

```dart
Widget build(BuildContext context) {
  return Scaffold(
    appBar: PreferredSize(
        child: AppBar(
          title: Text("拨号"),
        ),
        preferredSize: Size.fromHeight(45)),

    body: Column(
      children: <Widget>[
        buildText(),
        SizedBox(
          height: 80,
        ),
        _builderKeys(context),
      ],
    ),
  );
}
```



## 步骤二： 视频通话Video.dart

- 这里大部分逻辑都参考自：https://www.jianshu.com/p/5875ddea122e

### (1) 渲染文本框

![image-20201129170527835](https://i.loli.net/2020/12/30/QrbNezjDdB4AMqp.png) 

文本框的渲染，不过多介绍，视频通话主要是业务逻辑实现。

```dart
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          child: AppBar(
            title: Text("视频通话"),
          ),
          preferredSize: Size.fromHeight(45)),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: 400,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                      child: TextField(
                        controller: _channelController,
                        decoration: InputDecoration(
                          errorText:
                          _validateError ? 'Channel name is mandatory' : null,
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(width: 1),
                          ),
                          hintText: 'Channel name',
                        ),
                      ))
                ],
              ),
              Column(
                children: [
                  ListTile(
                    title: Text("视频通话"),
                    leading: Radio(
                      value: ClientRole.Broadcaster,
                      groupValue: _role,
                      onChanged: (ClientRole value) {
                        setState(() {
                          _role = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text("视频观众"),
                    leading: Radio(
                      value: ClientRole.Audience,
                      groupValue: _role,
                      onChanged: (ClientRole value) {
                        setState(() {
                          _role = value;
                        });
                      },
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        onPressed: onJoin,
                        child: Text('Join'),
                        color: Colors.blueAccent,
                        textColor: Colors.white,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
```



### (2) 按键触发

我们的UI现在只能看，还不能交互。我们希望可以基于现在的UI实现以下功能

1. 为Join按钮添加回调导航到通话页面
2. 对频道名做检查，若尝试加入频道时频道名为空，则在TextField上提示错误

```dart
  Future<void> onJoin() async {
    // update input validation
    setState(() {
      _channelController.text.isEmpty
          ? _validateError = true
          : _validateError = false;
    });
    if (_channelController.text.isNotEmpty) {
      // await for camera and mic permissions before pushing video page
      await _handleCameraAndMic();
      // push video page with given channel name
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPage(
            channelName: _channelController.text,
            role: _role,
          ),
        ),
      );
    }
  }
  Future<void> _handleCameraAndMic() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone],
    );
  }
```



### (3) 通话页面

在前面的代码中用`Navigator`跳转到新的通话页面，在通话页面中我们将会实现通话。

- 预先准备：

为了运行视频通话， 你还需要创建一个Agora帐户并获取一个 AppID和Token，获取方法如下：

1. 在[agora.io](https://dashboard.agora.io/signin/)创建开发人员帐户。完成注册过程后，您将被重定向到仪表板页面。
2. 在左侧的仪表板树中导航到**项目** > **项目列表**。
3. 将从仪表板获取的 App ID 复制到文本文件中。您将在启动应用程序时用到它。
4. Agora官网： [https://dashboard.agora.io/signin/](https://dashboard.agora.io/signin/)

- 获取APPID和Token：

![image-20201129171347816](https://i.loli.net/2020/12/30/U4tQbpWJEgPzH1T.png)





### 正式开始：

在`/lib/src/pages`目录下，我们需要新建一个`callPage.dart`文件，在这个文件里我们会实现我们最重要的实时视频通话逻辑。首先还是需要创建我们的`CallPage`类。如果你还记得我们在`IndexPage`的实现，`CallPage`会需要在构造函数中带入一个参数作为频道名。

```dart
class CallPage extends StatefulWidget {
    /// non-modifiable channel name of the page
    final String channelName;
    
    /// Creates a call page with given channel name.
    const CallPage({Key key, this.channelName}) : super(key: key);
    
    @override
    _CallPageState createState() {
        return new _CallPageState();
    }
 }
  
class _CallPageState extends State<CallPage> {
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
              title: Text(widget.channelName),
            ),
            backgroundColor: Colors.black,
            body: Center(
                child: Stack(
              children: <Widget>[],
            )));
    }
}
```

这里需要注意的是，我们并不需要把参数在创建`state`实例的时候传入，`state`可以直接访问`widget.channelName`获取到组件的属性。

### 引入声网SDK

因为我们在最开始已经在`pubspec.yaml`中添加了`agora_rtc_engine`的依赖，因此我们现在可以直接通过以下方式引入声网sdk。



```dart
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
```

引入后即可以使用创建声网媒体引擎实例。在使用声网SDK进行视频通话之前，我们需要进行以下初始化工作。初始化工作应该在整个页面生命周期中只做一次，因此这里我们需要override`initState`方法，在这个方法里做好初始化。



```dart
class _CallPageState extends State<CallPage> {
    @override
    void initState() {
        super.initState();
        initialize();
    }
    void initialize() {
        _initAgoraRtcEngine();
        _addAgoraEventHandlers();
    }
    
    /// Create agora sdk instance and initialze
    void _initAgoraRtcEngine() {
        AgoraRtcEngine.create(APP_ID);
        AgoraRtcEngine.enableVideo();
    }
    
    /// Add agora event handlers
   void _addAgoraEventHandlers() {
    AgoraRtcEngine.onError = (int code) {
      // sdk error
    };
    
    AgoraRtcEngine.onJoinChannelSuccess =
        (String channel, int uid, int elapsed) {
      // join channel success
    };
    
    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      // there's a new user joining this channel
    };
    
    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      // there's an existing user leaving this channel
    };
  }
}
```

**注意:** 有关如何获取声网APP_ID，请参阅[声网官方文档](https://links.jianshu.com/go?to=https%3A%2F%2Fdocs.agora.io%2Fcn%2FInteractive%20Broadcast%2Fandroid_video%3Fplatform%3DAndroid%23agora-app-id)。

在以上的代码中我们主要创建了声网的媒体SDK实例并监听了关键事件，接下去我们会开始做视频流的处理。

在一般的视频通话中，对于本地设备来说一共会有两种视频流，本地流与远端流 - 前者需要通过本地摄像头采集渲染并发送出去，后者需要接收远端流的数据后渲染。现在我们需要动态地将最多4人的视频流渲染到通话页面。

我们会以大致这样的结构渲染通话页面。

![img](https:////upload-images.jianshu.io/upload_images/2332624-9fc055faa9073083.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/181/format/webp)

flutter2.jpg

这里和首页不同的是，放置通话操作按钮的工具栏是覆盖在视频上的，因此这里我们会使用`Stack`组件来放置层叠组件。

为了更好地区分UI构建，我们将视频构建与工具栏构建分为两个方法。

### 本地流创建与渲染

要渲染本地流，需要在初始化SDK完成后创建一个供视频流渲染的容器，然后通过SDK将本地流渲染到对应的容器上。声网SDK提供了`createNativeView`的方法以创建容器，在获取到容器并且成功渲染到容器视图上后，我们就可以利用SDK加入频道与其他客户端互通了。



```dart
    void initialize() {
        _initAgoraRtcEngine();
        _addAgoraEventHandlers();
        // use _addRenderView everytime a native video view is needed
        _addRenderView(0, (viewId) {
            // local view setup & preview
            AgoraRtcEngine.setupLocalVideo(viewId, 1);
            AgoraRtcEngine.startPreview();
            // state can access widget directly
            AgoraRtcEngine.joinChannel(null, widget.channelName, null, 0);
        });
    }
    /// Create a native view and add a new video session object
    /// The native viewId can be used to set up local/remote view
    void _addRenderView(int uid, Function(int viewId) finished) {
        Widget view = AgoraRtcEngine.createNativeView(uid, (viewId) {
          setState(() {
            _getVideoSession(uid).viewId = viewId;
            if (finished != null) {
              finished(viewId);
            }
          });
        });
        VideoSession session = VideoSession(uid, view);
        _sessions.add(session);
    }
```

**注意:** 代码最后利用uid与容器信息创建了一个`VideoSession`对象并添加到`_sessions`中，这主要是为了视频布局需要，这块稍后会详细触及。

### 远端流监听与渲染

远端流的监听其实我们已经在前面的初始化代码中提及了，我们可以监听SDK提供的`onUserJoined`与`onUserOffline`回调来判断是否有其他用户进出当前频道，若有新用户加入频道，就为他创建一个渲染容器并做对应的渲染；若有用户离开频道，则去掉他的渲染容器。



```dart
    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      setState(() {
        _addRenderView(uid, (viewId) {
          AgoraRtcEngine.setupRemoteVideo(viewId, 1, uid);
        });
      });
    };
    
    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      setState(() {
        _removeRenderView(uid);
      });
    };
    /// Remove a native view and remove an existing video session object
    void _removeRenderView(int uid) {
        VideoSession session = _getVideoSession(uid);
        if (session != null) {
          _sessions.remove(session);
        }
        AgoraRtcEngine.removeNativeView(session.viewId);
    }
```

**注意:** `_sessions`的作用是在本地保存一份当前频道内的视频流列表信息。因此在用户加入的时候，需要创建对应的`VideoSession`对象并添加到`sessions`，在用户离开的时候，则需要删除对应的`VideoSession`实例。

### 视频流布局

在有了`_sessions`数组，且每一个本地/远端流都有了一个对应的原生渲染容器后，我们就可以开始对视频流进行布局了。



```dart
    /// Helper function to get list of native views
    List<Widget> _getRenderViews() {
        return _sessions.map((session) => session.view).toList();
    }
    
    /// Video view wrapper
    Widget _videoView(view) {
        return Expanded(child: Container(child: view));
    }
    
    /// Video view row wrapper
    Widget _expandedVideoRow(List<Widget> views) {
        List<Widget> wrappedViews =
            views.map((Widget view) => _videoView(view)).toList();
        return Expanded(
            child: Row(
          children: wrappedViews,
    ));
    }
    
    /// Video layout wrapper
    Widget _viewRows() {
        List<Widget> views = _getRenderViews();
        switch (views.length) {
          case 1:
            return Container(
                child: Column(
              children: <Widget>[_videoView(views[0])],
            ));
          case 2:
            return Container(
                child: Column(
              children: <Widget>[
                _expandedVideoRow([views[0]]),
                _expandedVideoRow([views[1]])
              ],
            ));
          case 3:
            return Container(
                child: Column(
              children: <Widget>[
                _expandedVideoRow(views.sublist(0, 2)),
                _expandedVideoRow(views.sublist(2, 3))
              ],
            ));
          case 4:
            return Container(
                child: Column(
              children: <Widget>[
                _expandedVideoRow(views.sublist(0, 2)),
                _expandedVideoRow(views.sublist(2, 4))
              ],
            ));
          default:
        }
        return Container();
    }
```

### 工具栏(挂断、静音、切换摄像头)

在实现完视频流布局后，我们接下来实现视频通话的操作工具栏。工具栏里有三个按钮，分别对应静音、挂断、切换摄像头的顺序。用简单的`flex Row`布局即可。

```dart
    /// Toolbar layout
    Widget _toolbar() {
        return Container(
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RawMaterialButton(
                onPressed: () => _onToggleMute(),
                child: new Icon(
                  muted ? Icons.mic : Icons.mic_off,
                  color: muted ? Colors.white : Colors.blueAccent,
                  size: 20.0,
                ),
                shape: new CircleBorder(),
                elevation: 2.0,
                fillColor: muted?Colors.blueAccent : Colors.white,
                padding: const EdgeInsets.all(12.0),
              ),
              RawMaterialButton(
                onPressed: () => _onCallEnd(context),
                child: new Icon(
                  Icons.call_end,
                  color: Colors.white,
                  size: 35.0,
                ),
                shape: new CircleBorder(),
                elevation: 2.0,
                fillColor: Colors.redAccent,
                padding: const EdgeInsets.all(15.0),
              ),
              RawMaterialButton(
                onPressed: () => _onSwitchCamera(),
                child: new Icon(
                  Icons.switch_camera,
                  color: Colors.blueAccent,
                  size: 20.0,
                ),
                shape: new CircleBorder(),
                elevation: 2.0,
                fillColor: Colors.white,
                padding: const EdgeInsets.all(12.0),
              )
            ],
          ),
        );
    }
    
    void _onCallEnd(BuildContext context) {
        Navigator.pop(context);
    }
    
    void _onToggleMute() {
        setState(() {
          muted = !muted;
        });
        AgoraRtcEngine.muteLocalAudioStream(muted);
    }
    
    void _onSwitchCamera() {
        AgoraRtcEngine.switchCamera();
    }
```

### 最终整合

现在两个部分的UI都完成了，我们接下去要将这两个组件通过`Stack`组装起来。

```dart
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
              title: Text(widget.channelName),
            ),
            backgroundColor: Colors.black,
            body: Center(
                child: Stack(
              children: <Widget>[_viewRows(), _toolbar()],
            )));
```

### 清理

若只在当前页面使用声网SDK，则需要在离开前调用`destroy`接口将SDK实例销毁。若需要跨页面使用，则推荐将SDK实例做成单例以供不同页面访问。同时也要注意对原生渲染容器的释放，可以至直接使用`removeNativeView`方法释放对应的原生容器,

```dart
    @override
    void dispose() {
        // clean up native views & destroy sdk
        _sessions.forEach((session) {
          AgoraRtcEngine.removeNativeView(session.viewId);
        });
        _sessions.clear();
        AgoraRtcEngine.destroy();
        super.dispose();
    }
```



## 步骤三：联系人列表

- 依赖：contacts_service

A Flutter plugin to access and manage the device's contacts.

### (1) 注册并管理联系人列表类

- 联系人列表`build`

```dart
  //返回build页面
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          child: AppBar(
            title: Text("联系人列表"),
          ),
          preferredSize: Size.fromHeight(45)),

      //浮动按键添加联系人(系统)
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _openContactForm,
      ),

      //构建列表List
      body: SafeArea(
        child: _contacts != null
            ? ListView.builder(
          itemCount: _contacts?.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            Contact c = _contacts?.elementAt(index);
            return ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => ContactDetailsPage(
                      c,
                      onContactDeviceSave:
                      contactOnDeviceHasBeenUpdated,
                    ))).then((avatar) async {

                      var contacts = (await ContactsService.getContacts(
                          withThumbnails: false, iOSLocalizedLabels: iOSLocalizedLabels)).toList();

                      // 延迟加载缩略图后，渲染
                      for (final contact in contacts) {
                        ContactsService.getAvatar(contact).then((avatar) {
                          if (avatar == null) return; // Don't redraw if no change.
                          setState(() => contact.avatar = avatar);
                        });
                      }

                      setState((){
                          print("试图重建");
                          _contacts = contacts;
                      });

                });
              },
              leading: (c.avatar != null && c.avatar.length > 0)
                  ? CircleAvatar(backgroundImage: MemoryImage(c.avatar))
                  : CircleAvatar(child: Text(c.initials())),
              title: Text(c.displayName ?? ""),
            );
          },
        )
            : Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
```

- 初始化和刷新：

```dart
class _ContactListPageState extends State<ContactListPage> {
  List<Contact> _contacts;

  //初始化状态， 刷新列表
  @override
  void initState() {
    super.initState();
    refreshContacts();
  }

  //刷新联系人
  Future<void> refreshContacts() async {
    var contacts = (await ContactsService.getContacts(
        withThumbnails: false, iOSLocalizedLabels: iOSLocalizedLabels))
        .toList();
    setState(() {
      _contacts = contacts;
    });

    // 延迟加载缩略图后，渲染
    for (final contact in contacts) {
      ContactsService.getAvatar(contact).then((avatar) {
        if (avatar == null) return; // Don't redraw if no change.
        setState(() => contact.avatar = avatar);
      });
    }
  }

  //更新联系人
  void updateContact() async {
    Contact ninja = _contacts
        .toList()
        .firstWhere((contact) => contact.familyName.startsWith("Ninja"));
    ninja.avatar = null;
    await ContactsService.updateContact(ninja);
    refreshContacts();
  }

  //打开联系人列表
  _openContactForm() async {
    try {
      var contact = await ContactsService.openContactForm(
          iOSLocalizedLabels: iOSLocalizedLabels);
      refreshContacts();
    } on FormOperationException catch (e) {
      switch (e.errorCode) {
        case FormOperationErrorCode.FORM_OPERATION_CANCELED:
        case FormOperationErrorCode.FORM_COULD_NOT_BE_OPEN:
        case FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR:
        default:
          print(e.errorCode);
      }
    }
  }
}
```



### (2) 联系人详情

- 打开已有的设备联系人列表

```dart
//构建联系人数据详情页
class ContactDetailsPage extends StatelessWidget {
  ContactDetailsPage(this._contact, {this.onContactDeviceSave});

  final Contact _contact;
  final Function(Contact) onContactDeviceSave;

  _openExistingContactOnDevice(BuildContext context) async {
    try {
      var contact = await ContactsService.openExistingContact(_contact,
          iOSLocalizedLabels: iOSLocalizedLabels);
      if (onContactDeviceSave != null) {
        onContactDeviceSave(contact);
      }
      Navigator.of(context).pop(true);
    } on FormOperationException catch (e) {
      switch (e.errorCode) {
        case FormOperationErrorCode.FORM_OPERATION_CANCELED:
        case FormOperationErrorCode.FORM_COULD_NOT_BE_OPEN:
        case FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR:
        default:
          print(e.toString());
      }
    }
  }
}
```

- 构建详情页

```dart
  //构建详情
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_contact.displayName ?? ""),
        actions: <Widget>[
          //删除
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: (){
              ContactsService.deleteContact(_contact);
              //弹窗
              //返回之前的页面
              Navigator.of(context).pop(true);
            }
          ),
          //系统修改
          IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _openExistingContactOnDevice(context)),
        ],
      ),

      //浮动按键添加联系人(系统)
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.call),
        onPressed: (){
          print("打印phone: "+_contact.phones.first.value);
          //页面路由
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => Call(id: _contact.phones.first.value)
              ));
        }
      ),

      body: SafeArea(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text("姓名"),
              trailing: Text(_contact.givenName ?? ""),
            ),
            ListTile(
              title: Text("生日"),
              trailing: Text(_contact.birthday != null
                  ? DateFormat('yyyy-dd-MM').format(_contact.birthday)
                  : ""),
            ),
            ListTile(
              title: Text("公司"),
              trailing: Text(_contact.company ?? ""),
            ),
            ListTile(
              title: Text("职位"),
              trailing: Text(_contact.jobTitle ?? ""),
            ),
            ListTile(
              title: Text("账户类型"),
              trailing: Text("私人"),
            ),
            ItemsTile("电话", _contact.phones),
            ItemsTile("@邮箱", _contact.emails),
            AddressesTile(_contact.postalAddresses),
          ],
        ),
      ),
    );
  }
```

- 渲染地址行

```dart
class AddressesTile extends StatelessWidget {
  AddressesTile(this._addresses);

  final Iterable<PostalAddress> _addresses;

  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(title: Text("Addresses")),
        Column(
          children: _addresses
              .map((a) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: <Widget>[
                ListTile(
                  title: Text("详细地址"),
                  trailing: Text(a.street ?? ""),
                ),
                ListTile(
                  title: Text("邮件编码"),
                  trailing: Text(a.postcode ?? ""),
                ),
                ListTile(
                  title: Text("城市"),
                  trailing: Text(a.city ?? ""),
                ),
                ListTile(
                  title: Text("宗教"),
                  trailing: Text(a.region ?? ""),
                ),
                ListTile(
                  title: Text("国家"),
                  // trailing: Text(a.country ?? ""),
                  trailing: Text("China"),
                ),
              ],
            ),
          ))
              .toList(),
        ),
      ],
    );
  }
}
```



- 渲染每一行

```dart
class ItemsTile extends StatelessWidget {
  ItemsTile(this._title, this._items);

  final Iterable<Item> _items;
  final String _title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(title: Text(_title)),
        Column(
          children: _items
              .map(
                (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListTile(
                title: Text(i.label ?? ""),
                trailing: Text(i.value ?? ""),
              ),
            ),
          ).toList(),
        ),
      ],
    );
  }
}
```

前面这些页面都构建好了，将他们添加到maind的路由中：

```dart
  @override
  Widget build(BuildContext context) {
		...........................
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
```



## 步骤四： 打包发布

- 图标素材请参考：https://www.iconfont.cn/

- 图标快速生成请参考：[https://blog.csdn.net/zhutao_java/article/details/103605526](https://blog.csdn.net/zhutao_java/article/details/103605526)

- 打包发布请参考我的另一篇博客：[打包发布](https://blog.csdn.net/weixin_44307065/article/details/107687942?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522160663495419195271690910%2522%252C%2522scm%2522%253A%252220140713.130102334.pc%255Fblog.%2522%257D&request_id=160663495419195271690910&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~blog~first_rank_v1~rank_blog_v1-1-107687942.pc_v1_rank_blog_v1&utm_term=flutter&spm=1018.2118.3001.4450)

- 打包

```bash
$ flutter build apk				# 构建一个apk
$ flutter install .				# 直接安装当前apk
```

![image-20201129154555819](https://i.loli.net/2020/12/30/KBHbojvCkSwMxFp.png) 

- 可以快乐使用了。





