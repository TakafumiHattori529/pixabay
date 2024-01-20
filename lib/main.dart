import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: PixabayPage());
  }
}

class PixabayPage extends StatefulWidget {
  const PixabayPage({super.key});

  @override
  State<PixabayPage> createState() => _PixabayPageState();
}

class _PixabayPageState extends State<PixabayPage> {
  List imageList = []; // 初期値は空のListを作成

  Future<void> fetchImages(String text) async {
    Response response = await Dio().get(
        'https://pixabay.com/api/?key=41615545-50f52ae48697ecb24d7316754&q=$text&image_type=photo&pretty=true&per_page=100');
    imageList = response.data['hits'];
    setState(() {});
  }

  @override
  void initState() {
    // initState関数は処理の初回に1度だけ実行される
    super.initState();
    // 最初に一度だけ画像データを取得する
    fetchImages('花');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: TextFormField(
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
          ),
          onFieldSubmitted: (text) {
            print(text);
            fetchImages(text);
          },
        ),
      ),
      body: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3),
          itemCount: imageList.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> image = imageList[index];
            return InkWell(
              onTap: () async {
                Directory dir = await getTemporaryDirectory();
                Response response = await Dio().get(image['webformatURL'],
                    options: Options(
                      responseType: ResponseType.bytes,
                    ));
                File imageFile = await File('${dir.path}/image.png')
                    .writeAsBytes(response.data);

                await Share.shareFiles([imageFile.path]);

                //print(image['likes']);
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    image['previewURL'],
                    fit: BoxFit.cover,
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                        color: Colors.white,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.thumb_up_alt_outlined,
                              size: 14,
                            ),
                            Text(image['likes'].toString()),
                          ],
                        )),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
