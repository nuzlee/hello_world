import 'package:flutter/material.dart';
import 'package:hello_world/screens/news_list.dart';

class CategoriesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> allCategories = [
    {
      'title': 'Technology',
      'icon': Icons.computer,
      'color': Colors.blue,
      'count': 45,
    },
    {
      'title': 'Sports',
      'icon': Icons.sports_soccer,
      'color': Colors.green,
      'count': 32,
    },
    {
      'title': 'Business',
      'icon': Icons.business,
      'color': Colors.orange,
      'count': 28,
    },
    {
      'title': 'Health',
      'icon': Icons.health_and_safety,
      'color': Colors.red,
      'count': 23,
    },
    {
      'title': 'Science',
      'icon': Icons.science,
      'color': Colors.purple,
      'count': 19,
    },
    {
      'title': 'Entertainment',
      'icon': Icons.movie,
      'color': Colors.pink,
      'count': 37,
    },
    {
      'title': 'Travel',
      'icon': Icons.flight,
      'color': Colors.teal,
      'count': 15,
    },
    {
      'title': 'Food',
      'icon': Icons.restaurant,
      'color': Colors.brown,
      'count': 21,
    },
    {
      'title': 'Politics',
      'icon': Icons.how_to_vote,
      'color': Colors.indigo,
      'count': 41,
    },
    {
      'title': 'Education',
      'icon': Icons.school,
      'color': Colors.cyan,
      'count': 18,
    },
    {
      'title': 'Environment',
      'icon': Icons.eco,
      'color': Colors.lightGreen,
      'count': 12,
    },
    {
      'title': 'Fashion',
      'icon': Icons.style,
      'color': Colors.deepPurple,
      'count': 16,
    },
    {
      'title': 'Automotive',
      'icon': Icons.directions_car,
      'color': Colors.grey,
      'count': 14,
    },
    {
      'title': 'Gaming',
      'icon': Icons.games,
      'color': Colors.deepOrange,
      'count': 25,
    },
    {
      'title': 'Music',
      'icon': Icons.music_note,
      'color': Colors.amber,
      'count': 20,
    },
    {'title': 'Art', 'icon': Icons.palette, 'color': Colors.lime, 'count': 13},
  ];

CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'All Categories',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black87),
            onPressed: () {
              // Handle search functionality
              _showSearchDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header info
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Explore News by Category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Discover ${allCategories.length} different categories with thousands of articles',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Categories grid
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: allCategories.length,
                itemBuilder: (context, index) {
                  final category = allCategories[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewsListScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon container
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: category['color'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                category['icon'],
                                color: category['color'],
                                size: 28,
                              ),
                            ),
                            SizedBox(height: 12),
                            // Category title
                            Text(
                              category['title'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2),
                            // Article count
                            Text(
                              '${category['count']} articles',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 6),
                            // Trending indicator for some categories
                            if (category['count'] > 30)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Trending',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search Categories'),
          content: TextField(
            decoration: InputDecoration(
              hintText: 'Enter category name...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Search functionality coming soon!')),
                );
              },
              child: Text('Search'),
            ),
          ],
        );
      },
    );
  }
}
