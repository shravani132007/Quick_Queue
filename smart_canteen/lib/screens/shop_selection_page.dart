import 'package:flutter/material.dart';
import 'student_order_pages.dart';

class ShopSelectionPage extends StatelessWidget {
  const ShopSelectionPage({super.key});

  // Temporary shop data.
  // Later this will come from the Flask backend/database.
  final List<Map<String, dynamic>> shops = const [
    {
      'name': 'KIT Main Canteen',
      'location': 'Main College Campus',
      'icon': Icons.restaurant,
      'available': true,
    },
    {
      'name': 'Royal Canteen',
      'location': 'Near Engineering Block',
      'icon': Icons.store,
      'available': true,
    },
    {
      'name': 'Campus Cafe',
      'location': 'Library Area',
      'icon': Icons.local_cafe,
      'available': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0D9488),
        elevation: 0,
        title: const Row(
          children: [
            Icon(
              Icons.restaurant,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Text(
              'Smart Canteen',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(
                  Icons.account_circle,
                  color: Colors.white,
                ),
                SizedBox(width: 5),
                Text(
                  'Student Portal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 800,
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  'Choose a Canteen',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Select the shop or canteen from which you want to order food.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),

                const SizedBox(height: 25),

                ListView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),

                  itemCount: shops.length,

                  itemBuilder: (context, index) {
                    final shop = shops[index];

                    return Card(
                      margin: const EdgeInsets.only(
                        bottom: 15,
                      ),

                      elevation: 1,

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),

                        side: const BorderSide(
                          color: Color(0xFFE2E8F0),
                        ),
                      ),

                      child: Padding(
                        padding: const EdgeInsets.all(18),

                        child: Row(
                          children: [

                            Container(
                              width: 55,
                              height: 55,

                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFFE6F4F1),

                                borderRadius:
                                    BorderRadius.circular(12),
                              ),

                              child: Icon(
                                shop['icon'],
                                color:
                                    const Color(0xFF0D9488),
                                size: 28,
                              ),
                            ),

                            const SizedBox(width: 15),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,

                                children: [

                                  Text(
                                    shop['name'],
                                    style:
                                        const TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                          FontWeight.bold,
                                      color:
                                          Color(0xFF1E293B),
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 14,
                                        color:
                                            Color(0xFF64748B),
                                      ),

                                      const SizedBox(width: 4),

                                      Text(
                                        shop['location'],
                                        style:
                                            const TextStyle(
                                          fontSize: 12,
                                          color:
                                              Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 7),

                                  Row(
                                    children: [

                                      Container(
                                        padding:
                                            const EdgeInsets
                                                .symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),

                                        decoration:
                                            BoxDecoration(
                                          color:
                                              Colors.green
                                                  .withOpacity(
                                                      0.1),
                                          borderRadius:
                                              BorderRadius
                                                  .circular(6),
                                        ),

                                        child: const Text(
                                          'Open',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color:
                                                Colors.green,
                                            fontWeight:
                                                FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CanteenHomePage(),
                                  ),
                                );
                              },

                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF0D9488),
                                foregroundColor:
                                    Colors.white,

                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),

                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                          8),
                                ),
                              ),

                              child: const Text(
                                'View Menu',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}