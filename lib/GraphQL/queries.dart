const String productsGraphQL = r'''
query readProducts($initialNum: Int!, $cursor: String, $price: Float!, $hprice: Float!, $query: String!){
  products(first:$initialNum ,after: $cursor, filter:{price:{lte: $price, gte: $hprice}}, query: $query) {
    totalCount
    edges{
      node{
        name
        isPublished
        id
        url
        images{
          url
        }
        isAvailable
        minimalVariantPrice{
          amount
          currency
        }
      }
      cursor
    }
    pageInfo{
      endCursor
      hasNextPage
    }
  }
}
''';

const String searchProducts = r'''
  query searchProducts($initialNum: Int!, $query: String!, $cursor: String!){
    products(first:$initialNum, query: $query, after: $cursor) {
    totalCount
    edges{
      node{
        name
        isPublished
        id
        url
        images{
          url
        }
        isAvailable
        minimalVariantPrice{
          amount
          currency
        }
      }
      cursor
    }
    pageInfo{
      endCursor
      hasNextPage
    }
  }
  }
''';
