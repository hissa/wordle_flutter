import 'package:uuid/uuid.dart';
import 'package:graphql/client.dart';

class WordleApiClient{

  QueryOptions _getCollectWordQueryOption(String id){
    String callUserList = r'''
    query GetCorrectWord($wordId:String!) {
      correctWord(wordId: $wordId){
        word
        mean
      }
    }
    ''';

    final QueryOptions options = QueryOptions(
      document: gql(callUserList),
      variables: <String, dynamic>{
        // 引数に wordId 渡す
        'wordId': id,
      },
    );
    return options;
  }

  Future<Map<String,dynamic>> getCorrectWordAsync() async{
    final _httpLink = HttpLink("https://serene-garden-89220.herokuapp.com/query");
// Graphql のクライアントを準備
    final GraphQLClient client =
        GraphQLClient(link: _httpLink, cache: GraphQLCache());
    const uuid = Uuid();
    String id = uuid.v4();
    final QueryOptions options = _getCollectWordQueryOption(id);
    final QueryResult result = await client.query(options);

    if (result.hasException) {
      print(result.exception.toString());
      throw Error();
    }

    final data = result.data;

    if(data == null){
      throw Error();
    }
    
    return data["correctWord"];
  }
}