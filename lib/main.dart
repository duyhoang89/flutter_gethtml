import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Table From HTML', style: TextStyle(fontWeight: FontWeight.bold),),
        ),
        body: TableListView(),
      ),
    );
  }
}

class TableListView extends StatefulWidget {
  const TableListView({Key? key}) : super(key: key);

  @override
  _TableListViewState createState() => _TableListViewState();
}

class _TableListViewState extends State<TableListView> {
  final tableData = <Table>[];
  final tableStream = StreamController<List<Table>>();

  void getGoldInfo() async {
    final client = Client();

    const SJC_URL = 'https://preview.colorlib.com/theme/bootstrap/table-01/';
    //final response = await http.get(Uri.parse(SJC_URL));
    final response = await client.get(Uri.parse(SJC_URL));
    // print(response.body);
    final document = parse(response.body);
    final trs = document.querySelectorAll("tr");
    // print(trs.length);
    for (final tr in trs) {
      try {
        final tds = tr.children;
        tableData.add(Table(tds[0].text, tds[1].text, tds[2].text));
      } catch (e) {}
      tableStream.sink.add(tableData);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getGoldInfo();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tableStream.close();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<List<Table>>(
        stream: tableStream.stream,
        initialData: null,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
                child: Center(
              child: const CircularProgressIndicator(),
            ));
          }
          final data = snapshot.data;
          return ListView.separated(
              itemBuilder: (context, index) =>
                  _buildInfoRow(data![index], index),
              separatorBuilder: (context, index) => Container(),
              itemCount: data!.length);
        },
      ),
    );
  }

  Widget _buildInfoRow(Table gold, int index) {
    return Container(
      height: 70,
      color: const Color(0xff416c7e),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                gold.type,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xffFBF203),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                gold.outGold,
                style: TextStyle(
                    color: index == 0 ? const Color(0xffFBF203) : Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),Expanded(
            child: Center(
              child: Text(
                gold.inGold,
                style: TextStyle(
                    color: index == 0 ? const Color(0xffFBF203) : Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class Table {
  String type;
  String inGold;
  String outGold;

  Table(this.type, this.inGold, this.outGold);
}
