import 'package:flutter/material.dart';
import 'package:hello_world/screens/news_detail.dart';

class NewsListScreen extends StatelessWidget {
  final List<Map<String, String>> allNewsList = [
    {
      'title': 'Breaking: Major Technology Breakthrough',
      'subtitle':
          'Scientists discover revolutionary quantum computing method that could change everything.',
    },
    {
      'title': 'Global Climate Summit Reaches Agreement',
      'subtitle':
          'World leaders unite on ambitious climate action plan for the next decade.',
    },
    {
      'title': 'Space Exploration Milestone Achieved',
      'subtitle':
          'New Mars rover discovers potential signs of ancient microbial life.',
    },
    {
      'title': 'Economic Markets Show Strong Recovery',
      'subtitle':
          'Financial analysts predict continued growth following recent policy changes.',
    },
    {
      'title': 'Medical Research Advances Cancer Treatment',
      'subtitle':
          'New immunotherapy shows promising results in clinical trials.',
    },
    {
      'title': 'Tech Giants Announce AI Partnership',
      'subtitle':
          'Major companies collaborate on ethical AI development standards.',
    },
    {
      'title': 'Renewable Energy Reaches New Milestone',
      'subtitle':
          'Solar and wind power now account for 50% of global electricity generation.',
    },
    {
      'title': 'Education System Embraces Digital Learning',
      'subtitle': 'Schools worldwide adopt innovative teaching technologies.',
    },
    {
      'title': 'Sports Championship Draws Record Viewership',
      'subtitle':
          'International tournament breaks all previous audience records.',
    },
    {
      'title': 'Cultural Festival Celebrates Diversity',
      'subtitle': 'Annual event showcases traditions from around the world.',
    },
    {
      'title': 'Transportation Revolution Takes Shape',
      'subtitle':
          'Electric vehicles and autonomous driving technology advance rapidly.',
    },
    {
      'title': 'Health Initiative Promotes Community Wellness',
      'subtitle':
          'New public health program focuses on preventive care and fitness.',
    },
  ];

  NewsListScreen({super.key});

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
          'All News',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black87),
            onPressed: () {
              // Handle search functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Search functionality coming soon!')),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.black87),
            onPressed: () {
              // Handle filter functionality
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('All', true),
                _buildFilterChip('Technology', false),
                _buildFilterChip('Science', false),
                _buildFilterChip('Sports', false),
                _buildFilterChip('Business', false),
                _buildFilterChip('Health', false),
              ],
            ),
          ),
          // News count
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${allNewsList.length} articles found',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Spacer(),
                Icon(Icons.sort, color: Colors.grey[600], size: 20),
                SizedBox(width: 4),
                Text(
                  'Latest first',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          // News list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: allNewsList.length,
              itemBuilder: (context, index) {
                final news = allNewsList[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Card(
                    elevation: 2,
                    shadowColor: Colors.grey.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewsDetailScreen(
                              title: news['title']!,
                              subtitle: news['subtitle']!,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // News image placeholder
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        'https://www.dummyimage.co.uk/160x160/4a90e2/ffffff/News',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                // News content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        news['title']!,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        news['subtitle']!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            // Meta information
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Colors.grey[500],
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${index + 1} hours ago',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Icon(
                                  Icons.visibility,
                                  size: 14,
                                  color: Colors.grey[500],
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${(index + 1) * 127} views',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                Spacer(),
                                Icon(
                                  Icons.bookmark_border,
                                  size: 16,
                                  color: Colors.grey[500],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 14,
          ),
        ),
        selected: isSelected,
        onSelected: (bool selected) {
          // Handle filter selection
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        showCheckmark: false,
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter News'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Sort by Date'),
                leading: Radio(value: 1, groupValue: 1, onChanged: (value) {}),
              ),
              ListTile(
                title: Text('Sort by Popularity'),
                leading: Radio(value: 2, groupValue: 1, onChanged: (value) {}),
              ),
              ListTile(
                title: Text('Sort by Relevance'),
                leading: Radio(value: 3, groupValue: 1, onChanged: (value) {}),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}
