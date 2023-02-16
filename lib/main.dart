import 'package:flutter/material.dart';
import 'package:http/http.dart'
    as http; // Import the http package to make HTTP requests
import 'dart:convert'; // Import the dart:convert library to parse JSON data

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Store App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BookList(),
    );
  }
}

class BookList extends StatefulWidget {
  @override
  _BookListState createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  List<dynamic> _books = []; // Define a list to store the book data
  List<dynamic> _cart = []; // Define a list to store the books in the cart

  @override
  void initState() {
    super.initState();
    _getBooks(); // Call the _getBooks() method when the app starts up
  }

  void _getBooks() async {
    final response = await http.get(
        Uri.parse('https://www.googleapis.com/books/v1/volumes?q=flutter'));
    // Make an HTTP GET request to the Google Books API, passing in the search term "flutter"
    if (response.statusCode == 200) {
      // If the request is successful (HTTP status code 200)
      setState(() {
        _books = json.decode(response.body)[
            'items']; // Parse the JSON response and store the book data in _books
      });
    }
  }

  void _addToCart(dynamic book) {
    setState(() {
      _cart.add(book); // Add the selected book to the cart
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book List'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Cart(cart: _cart),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _books.length,
        itemBuilder: (BuildContext context, int index) {
          final book = _books[index]; // Get the book data for the current index
          return ListTile(
            leading: Image.network(book['volumeInfo']['imageLinks'][
                'thumbnail']), // Display the book cover image as the leading widget
            title: Text(book['volumeInfo']['title']), // Display the book title
            subtitle: Text(book['volumeInfo']['authors']
                .join(', ')), // Display the book authors
            trailing: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                _addToCart(book); // Add the selected book to the cart
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookDetails(
                      book:
                          book), // Navigate to the BookDetails page and pass in the book data
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class Cart extends StatelessWidget {
  final List<dynamic> cart;

  Cart({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: ListView.builder(
        itemCount: cart.length,
        itemBuilder: (BuildContext context, int index) {
          final book = cart[index];
          return ListTile(
            leading:
                Image.network(book['volumeInfo']['imageLinks']['thumbnail']),
            title: Text(book['volumeInfo']['title']),
            subtitle: Text(book['volumeInfo']['authors'].join(', ')),
          );
        },
      ),
    );
  }
}

class BookDetails extends StatefulWidget {
  final dynamic book;

  BookDetails({required this.book});

  @override
  _BookDetailsState createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double imageSize = screenHeight * 0.3;
    final double fontSizeTitle = screenHeight * 0.04;
    final double fontSizeSubtitle = screenHeight * 0.03;
    final double fontSizeDescription = screenHeight * 0.025;
    final double fontSizeQuantity = screenHeight * 0.03;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book['volumeInfo']['title']),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.network(
                    widget.book['volumeInfo']['imageLinks']['thumbnail'],
                    height: imageSize,
                    width: imageSize * 0.6666,
                  ),
                  Text(
                    widget.book['volumeInfo']['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSizeTitle,
                    ),
                  ),
                  Text(
                    widget.book['volumeInfo']['authors'].join(', '),
                    style: TextStyle(
                      fontSize: fontSizeSubtitle,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    widget.book['volumeInfo']['description'],
                    style: TextStyle(
                      fontSize: fontSizeDescription,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.grey[200],
            height: screenHeight * 0.1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _count > 0
                      ? () {
                          setState(() {
                            _count--;
                          });
                        }
                      : null,
                  icon: Icon(Icons.remove),
                ),
                Text(
                  '$_count',
                  style: TextStyle(
                    fontSize: fontSizeQuantity,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _count++;
                    });
                  },
                  icon: Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
