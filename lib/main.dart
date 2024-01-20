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
  List<PixabayImage> pixabayImages = [];
  //List imageList = []; // 初期値は空のListを作成

  Future<void> fetchImages(String text) async {
    final response = await Dio().get(
      // 'https://pixabay.com/api/?key=41615545-50f52ae48697ecb24d7316754&q=$text&image_type=photo&pretty=true&per_page=100');
      'https://pixabay.com/api',
      queryParameters: {
        'key': '41615545-50f52ae48697ecb24d7316754',
        'q': text,
        'image_type': 'photo',
        'per_page': 100,
      },
    );
    //imageList = response.data['hits'];
    //この時点で要素の中身の型はMap＜String, dynamic>
    final List hits = response.data['hits'];
    //mapメソッドを使って Map<String, dynamic> の型を一つひとつ PixabayImage 型に変換していきます。
    pixabayImages = hits.map((e) => PixabayImage.fromMap(e)).toList();

    setState(() {});
  }

  Future<void> shareImage(String url) async {
    final dir = await getTemporaryDirectory();
    final response = await Dio().get(
      url,
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );

    // フォルダの中に image.png という名前でファイルを作り、そこに画像データを書き込みます。
    final imageFile =
        await File('${dir.path}/image.png').writeAsBytes(response.data);

    //pathを指定してShare
    await Share.shareFiles([imageFile.path]);
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
          itemCount: pixabayImages.length,
          itemBuilder: (context, index) {
            final pixabayImage = pixabayImages[index];
            return InkWell(
              onTap: () async {
                // final dir = await getTemporaryDirectory();
                // final response = await Dio().get(image['webformatURL'],
                //     options: Options(
                //       responseType: ResponseType.bytes,
                //     ));
                // final imageFile = await File('${dir.path}/image.png')
                //     .writeAsBytes(response.data);

                // await Share.shareFiles([imageFile.path]);
                shareImage(pixabayImage.webformatURL);
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    //image['previewURL'],
                    pixabayImage.previewURL,
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
                            //Text(image['likes'].toString()),
                            Text('${pixabayImage.likes}'),
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

class PixabayImage {
  final String previewURL;
  final int likes;
  final String webformatURL;

  //PixabayImage(this.previewURL, this.likes, this.webformatURL);}
  PixabayImage({
    required this.previewURL,
    required this.likes,
    required this.webformatURL,
  });

  factory PixabayImage.fromMap(Map<String, dynamic> map) {
    return PixabayImage(
      previewURL: map['previewURL'],
      likes: map['likes'],
      webformatURL: map['webformatURL'],
    );
  }
}
