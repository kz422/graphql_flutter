import 'package:badges/badges.dart';
import 'package:dart_cart/dart_cart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:o_popup/o_popup.dart';

import 'GraphQL/queries.dart' as queries;

String filterType = '';
String filterSubType = '';
String searchQuery = '';
String searchQueryKeyword = '';
const int filterNum = 500;
int initialNum = 20;
dynamic initialPrice = priceList[2];
dynamic selectedPrice = priceList[2];

dynamic initialHprice = priceList[0];
dynamic selectedHprice = priceList[0];

int selectedNum = numList[0];

List numList = [10, 20, 30];
List<dynamic> priceList = [100, 200, 300, 500, 600, 700, 800, 900, 1000];

void main() {
  final HttpLink httpLink = HttpLink("https://dev.twidy.link/wfr_graphql/");

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: InMemoryStore()),
    ),
  );

  var app = GraphQLProvider(client: client, child: const MyApp());
  runApp(app);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter GraphQL',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Foody'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var cart = DartCart();

  updateCart() {
    cart.getTotalAmount();
  }

  @override
  Widget build(BuildContext context) {
    var total = cart.getTotalAmount().floor();
    var qrt = cart.getCartItemCount();

    List cartedItem = cart.cartItem;

    return Scaffold(
      backgroundColor: const Color(0xFF101727),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.title),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Tooltip(
              message: '合計' + total.toString() + '円',
              triggerMode: TooltipTriggerMode.tap,
              child: Badge(
                  showBadge: qrt == 0 ? false : true,
                  badgeContent: Text(
                    qrt.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  child: const Icon(Icons.shopping_basket)),
            ),
          )
        ],
      ),
      body: Query(
          options: QueryOptions(
            document: gql(queries.productsGraphQL),
            variables: {
              'initialNum': initialNum,
              'cursor': null,
              'price': initialPrice,
              'hprice': initialHprice,
              'query': searchQuery
            },
          ),
          builder: (QueryResult result, {FetchMore? fetchMore, refetch}) {
            if (result.hasException) {
              return const Text('例外が発生しました');
            }

            if (result.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final productList =
                (result.data!['products']['edges'] as List<dynamic>);

            final Map pageInfo = result.data!['products']['pageInfo'];
            final String? fetchMoreCursor = pageInfo['endCursor'];
            final opts = FetchMoreOptions(
                variables: {'cursor': fetchMoreCursor},
                updateQuery: (previousResultData, fetchMoreResultData) {
                  final pdts = [
                    ...previousResultData!['products']['edges']
                        as List<dynamic>,
                    ...fetchMoreResultData!['products']['edges']
                        as List<dynamic>
                  ];

                  fetchMoreResultData['products']['edges'] = pdts;

                  return fetchMoreResultData;
                });

            return Column(
              children: [
                ExpansionTile(
                    backgroundColor: Colors.blueGrey,
                    children: [
                      const Text(
                        'キーワード検索',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(
                          width: MediaQuery.of(context).size.width * .8,
                          child: CupertinoTextField(
                            onSubmitted: (_) {
                              setState(() {
                                searchQuery = searchQueryKeyword;
                              });
                            },
                            onChanged: (value) {
                              setState(() {
                                searchQueryKeyword = value;
                              });
                            },
                          )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CupertinoButton(
                              child: const Text('表示件数',
                                  style: TextStyle(
                                    color: Colors.white,
                                  )),
                              onPressed: () {
                                showCupertinoModalPopup(
                                  context: context,
                                  builder: (context) {
                                    return Container(
                                      height: 150,
                                      color: Colors.white,
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child:const Text('キャンセル')),
                                              TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      initialNum = selectedNum;
                                                      Navigator.pop(context);
                                                    });
                                                  },
                                                  child: Text('保存')),
                                            ],
                                          ),
                                          Expanded(
                                            child: CupertinoPicker(
                                              itemExtent: 30,
                                              children: numList.map((e) {
                                                return Text(
                                                    e.toString() + '件ずつ表示');
                                              }).toList(),
                                              onSelectedItemChanged: (i) {
                                                setState(() {
                                                  selectedNum = numList[i];
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }),
                          CupertinoButton(
                              child: const Text('金額で絞り込み',
                                  style: TextStyle(
                                    color: Colors.white,
                                  )),
                              onPressed: () {
                                showCupertinoModalPopup(
                                  context: context,
                                  builder: (context) {
                                    return Container(
                                      height: 150,
                                      color: Colors.white,
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('キャンセル')),
                                              TextButton(
                                                  onPressed: () {
                                                    if (selectedPrice >
                                                        selectedHprice) {
                                                      setState(() {
                                                        initialPrice =
                                                            selectedPrice;
                                                        initialHprice =
                                                            selectedHprice;
                                                        Navigator.pop(context);
                                                      });
                                                    } else {
                                                      showCupertinoDialog(
                                                          context: context,
                                                          builder: (builder) {
                                                            return CupertinoAlertDialog(
                                                              title: const Text(
                                                                  '最大金額は最小金額より高く設定してください'),
                                                              actions: [
                                                                CupertinoButton(
                                                                    child:
                                                                        const Text(
                                                                            'OK'),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    })
                                                              ],
                                                            );
                                                          });
                                                    }
                                                  },
                                                  child: Text('保存')),
                                            ],
                                          ),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: CupertinoPicker(
                                                    scrollController:
                                                        FixedExtentScrollController(
                                                            initialItem: 0),
                                                    itemExtent: 30,
                                                    children:
                                                        priceList.map((e) {
                                                      return Text(
                                                          e.toString() + '円以上');
                                                    }).toList(),
                                                    onSelectedItemChanged: (i) {
                                                      setState(() {
                                                        selectedHprice =
                                                            priceList[i];
                                                      });
                                                    },
                                                  ),
                                                ),
                                                Expanded(
                                                  child: CupertinoPicker(
                                                    scrollController:
                                                        FixedExtentScrollController(
                                                            initialItem: 2),
                                                    itemExtent: 30,
                                                    children:
                                                        priceList.map((e) {
                                                      return Text(
                                                          e.toString() + '円以下');
                                                    }).toList(),
                                                    onSelectedItemChanged: (i) {
                                                      setState(() {
                                                        selectedPrice =
                                                            priceList[i];
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }),
                        ],
                      ),
                    ],
                    title: const Text(
                      '絞り込み',
                      style: TextStyle(color: Colors.white),
                    )),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('キーワード:' + searchQueryKeyword,
                        style: const TextStyle(
                          color: Colors.white,
                        )),
                    Text(
                        initialHprice.toString() +
                            '〜' +
                            initialPrice.toString() +
                            '円で表示中',
                        style: const TextStyle(
                          color: Colors.white,
                        )),
                  ],
                ),
                Expanded(
                    child: GridView.builder(
                        itemCount: productList.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 2.0,
                          crossAxisSpacing: 2.0,
                          childAspectRatio: 0.75,
                        ), // SilverGridDelegateWithFixedCrossAxisCount
                        itemBuilder: (_, index) {
                          final product = productList[index]['node'];
                          return OPopupTrigger(
                            popupHeader: OPopupContent.standardizedHeader(
                                'Click anywhere'),
                            popupContent: Card(
                              child: Container(
                                // color: const Color(0xFF101727),
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: popCard(
                                        product['images'].length > 0
                                            ? product['images'][0]['url']
                                            : 'https://media.istockphoto.com/photos/delicious-meal-on-a-black-plate-top-view-copy-space-picture-id1165399909?k=20&m=1165399909&s=612x612&w=0&h=5g5C4BDoxaejlIr4r_8cV6jDYXzN8n1-JkIW3LgPUuA=',
                                        product['name'],
                                        product['id'],
                                        product['minimalVariantPrice']['amount']
                                            .floor()),
                                  ),
                                ),
                              ),
                            ),
                            triggerWidget: Card(
                              color: Colors.blueGrey,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        height: 100,
                                        width: 100,
                                        child: product['images'].length > 0
                                            ? Image.network(
                                                product['images'][0]['url'],
                                                fit: BoxFit.contain,
                                              )
                                            : Image.network(
                                                'https://media.istockphoto.com/photos/delicious-meal-on-a-black-plate-top-view-copy-space-picture-id1165399909?k=20&m=1165399909&s=612x612&w=0&h=5g5C4BDoxaejlIr4r_8cV6jDYXzN8n1-JkIW3LgPUuA=')),
                                  ),
                                  FittedBox(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(
                                        product['name'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  FittedBox(
                                    child: Text(
                                      product['minimalVariantPrice']['amount']
                                              .floor()
                                              .toString() +
                                          '円',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        })),
                CupertinoButton(
                    child: Text(fetchMoreCursor.toString()),
                    onPressed: () {
                      fetchMore!(opts);
                      // fetchMore!(options);
                    }),
              ],
            );
          }),
    );
  }

  Widget popCard(String src, String productName, String productId, unitPrice) {
    return Column(
      children: [
        Image.network(
          src,
          height: 200,
        ),
        FittedBox(
            child: Text(productName, style: TextStyle(color: Colors.white))),
        CupertinoButton.filled(
            child: const Text('カートへ追加'),
            onPressed: () {
              cart.addToCart(
                  productId: productId,
                  unitPrice: unitPrice,
                  productName: productName);
              setState(() {});
              Navigator.pop(context);
            })
      ],
    );
  }
}
