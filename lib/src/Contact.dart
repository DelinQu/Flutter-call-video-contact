import 'package:flutter/material.dart';
import 'package:myflutter/main.dart';

import 'package:contacts_service/contacts_service.dart';
import 'package:intl/intl.dart';
import 'package:myflutter/src/Call.dart';

//当前类注册
class ContactListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ContactListPageState();
  }
}

//实现他
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

  void contactOnDeviceHasBeenUpdated(Contact contact) {
    this.setState(() {
      var id = _contacts.indexWhere((c) => c.identifier == contact.identifier);
      _contacts[id] = contact;
    });
  }
}

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
}

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
