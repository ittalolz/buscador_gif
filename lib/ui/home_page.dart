import 'dart:convert';

import 'package:busca_gif/ui/gif_page.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String _search = "";
  late int _offset = 0;

  Future<Map> _getGif() async {
    http.Response response;

    if (_search.isEmpty)
      response = await http.get(Uri.parse(
          "https://api.giphy.com/v1/gifs/trending?api_key=R9tH4mWDtf7rEAbOEkIMnbBRnsTat0hH&limit=20&rating=g"));
    else
      response = await http.get(Uri.parse(
          "https://api.giphy.com/v1/gifs/search?api_key=R9tH4mWDtf7rEAbOEkIMnbBRnsTat0hH&q=$_search&limit=19&offset=$_offset&rating=g&lang=pt"));

    return jsonDecode(response.body);
  }

  @override
  void initState() {
    super.initState();

    _getGif().then((value) => print(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:
        Image.network("https://developers.giphy.com/static/img/dev-logo-lg.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Pesquise Aqui!",
                labelStyle: TextStyle(color: Colors.white),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2.0),
                ),
              ),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                setState(() {
                  _search = text;
                  _offset = 0;
                });
              },
            ),
          ),
          Expanded(
              child: FutureBuilder(
                future: _getGif(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Center(
                          child: Container(
                            width: 50.0,
                            height: 50.0,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                              strokeWidth: 5.0,
                            ),
                          ));
                    default:
                      if (snapshot.hasError)
                        return Container();
                      else
                        return _createGifTable(context, snapshot);
                  }
                },
              ))
        ],
      ),
    );
  }

  int _getCount(List data) {
    if (_search == null) {
      return data.length;
    }
    return data.length + 1;
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
        itemCount: _search.isEmpty
            ? snapshot.data["data"].length
            : snapshot.data["data"].length + 1,
        itemBuilder: (contex, index) {
          if (_search.isEmpty || index < snapshot.data["data"].length)
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: snapshot.data["data"][index]["images"]["preview_gif"]["url"],
                height: 300.0,
                fit: BoxFit.cover,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            GifPage(snapshot.data["data"][index])));
              },
            );
          else
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 70.0,
                    ),
                    Text(
                      'Carregar mais ...',
                      style: TextStyle(color: Colors.white, fontSize: 22.0),
                    )
                  ],
                ),
                onTap: () {
                  setState(() {
                    _offset += 19;
                  });
                },
              ),
            );
        });
  }
}
