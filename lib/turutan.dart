import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:graphql/client.dart';

class WordlePage extends StatefulWidget {
  const WordlePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MyWordleState();
  }
}

class MyWordleState extends State<WordlePage> {
  String _showText = "";
  String _tmpText = "";
  String _word = "";
  List _worldleResults = [];

  List _getWorldleResult(String inputWord, String answerWord){
    return [0,1,2,0,1];
  }

  Color? _getMaterialColor(int result){
    if(result == 0)return Colors.grey;
    if(result == 1)return Colors.amber[300];
    if(result == 2)return Colors.green[300];
    return Colors.grey;
  }

  void _handleChange(String value) {
    setState(() {
      _tmpText = value;
    });
  }

  void _reflectionText() {
    setState(() {
      _showText = _tmpText;
      _worldleResults = _getWorldleResult(_showText, _word);
    });
  }

  void _getWord() async {
    final _httpLink =
        HttpLink("https://serene-garden-89220.herokuapp.com/query");
// Graphql のクライアントを準備
    final GraphQLClient client =
        GraphQLClient(link: _httpLink, cache: GraphQLCache());

    const String callUserList = r'''
      correctWord(wordId: ) {
        mean
        word
      }
    ''';

    final QueryOptions options = QueryOptions(document: gql(callUserList));

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      print(result.exception.toString());
    }

    print(result);

    final data = result.data;
    var uuid = Uuid();
    var v1 = uuid.v1();
    setState(() {
      _word = v1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TextField"),
      ),
      body: Column(
        children: [
          TextButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.blueGrey),
              ),
              onPressed: _getWord,
              child: const Text("4文字の英単語")),
          Text(_word),
          TextField(onChanged: (value) {
            _handleChange(value);
          }),
          TextButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.blueGrey),
              ),
              onPressed: _reflectionText,
              child: const Text("回答する")),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var i = 0; i < _showText.length; i++) ...{
                SizedBox(
                  width: 40,
                  height: 40,
                  child: ColoredBox(
                      color: _getMaterialColor(_worldleResults[i])!,
                      child: Text(_showText[i].toUpperCase())),
                ),
              }
            ],
          ),
        ],
      ),
    );
  }
}