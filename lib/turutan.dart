import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:graphql/client.dart';
import 'package:wordle_flutter/WordleApiClient.dart';

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

  double _resultBoxWidth = 70;
  Map<String,dynamic> _wordleAnswerData = {};
  String _wordleAnswerMeaning(){
    return _wordleAnswerData["mean"];
  }
  String _wordleAnswerWord(){
    return _wordleAnswerData["word"];
  }
  
  List _wordleResults = []; //１ゲーム5ターン分のデータが入る
  List _getWordleResult(String inputWord, String answerWord){
    return [0,1,2,0,1];
  }

  int _maxChallengeCount = 5;
  int _gameState = 0; //0:実行中、1:クリア,2:失敗
  int _characterCount = 4; //correctWordの文字数

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
      _PushInputAnswer();
    });
  }

  bool _isClear(List _wordleResult){
    return false;
  }
  void _PushInputAnswer(){
    //5回目以降のチャレンジは弾く
    if(_wordleResults.length >= _maxChallengeCount){
      return;
    }

    _wordleResults.add(_getWordleResult(_showText, _word));
    //クリアかどうか判定
    if(_isClear(_wordleResults[_wordleResults.length - 1])){
      _gameState = 1;
      return;
    }

    //失敗判定
    if(_wordleResults.length >= _maxChallengeCount){
      _gameState = 2;
      _showGameOverDialog();
    }
  }

  void _showGameOverDialog(){
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("タイトル"),
          content: Text("メッセージメッセージメッセージメッセージメッセージメッセージ"),
          actions: <Widget>[
            // ボタン領域
            FlatButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            FlatButton(
              child: Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
  void _getWord() async {
    final _apiClient = WordleApiClient();
    _wordleAnswerData = await _apiClient.getCorrectWordAsync();
    setState(() {
      _word = _wordleAnswerWord();
      print(_word);
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
              child: Text("$_characterCount 文字の英単語")),
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
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for(var i = 0; i < _wordleResults.length; i++) ...{
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (var j = 0; j < _showText.length; j++) ...{
                      SizedBox(
                        width: _resultBoxWidth,
                        height: _resultBoxWidth,
                        child: ColoredBox(
                            color: _getMaterialColor(_wordleResults[i][j])!,
                            child: Text(_showText[j].toUpperCase())),
                      ),
                    },
                  ],
                ),
              }
            ],
          ),
        ],
      ),
    );
  }
}