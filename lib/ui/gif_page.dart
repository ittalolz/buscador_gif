import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';

class GifPage extends StatelessWidget {
  //const GifPage({Key? key}) : super(key: key);

  final Map _gifData;

  GifPage(this._gifData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_gifData["title"]),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
              onPressed: () async {
                //Share.share(_gifData["images"]["downsized_large"]["url"]);
                var request = await HttpClient()
                    .getUrl(Uri.parse(_gifData["images"]["downsized_large"]["url"]));
                var response = await request.close();
                Uint8List bytes = await consolidateHttpClientResponseBytes(response);
                await Share.file('ESYS AMLOG', 'giphy.gif', bytes, 'image/gif');
              },
              icon: Icon(Icons.share))
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Image.network(_gifData["images"]["downsized_large"]["url"]),
      ),
    );
  }
}
