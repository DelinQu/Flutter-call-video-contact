import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Call extends StatefulWidget {
  //必传参数
  Call({Key key, @required this.id}) : super(key: key);
  String id;

  @override
  State<StatefulWidget> createState() {
    return CallBuilder();
  }
}

class CallBuilder extends State<Call> {
  List number = [];
  List outputnumber = [];
  String phoneStr = '';

  //文本输入框控制器
  TextEditingController telno = new TextEditingController();

  //初始化数字键盘字符
  //初始化全局状态8
  void initState() {
    if(widget.id!=null){
      phoneStr=widget.id;   //初始化数据
      for(int i=0;i<phoneStr.length;i++){
        outputnumber.add(phoneStr[i]);
      }
      telno.text = phoneStr;
    }
    super.initState();
    for (int i = 1; i < 10; i++) {
      number.add(i);
    }
    number.add('call');
    number.add(0);
    number.add('del');

  }

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

  //渲染组件
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
}
