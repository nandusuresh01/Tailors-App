import 'package:flutter/material.dart';
import 'package:userapp/booking.dart';
import 'package:userapp/complaints.dart';
import 'package:userapp/profilepage.dart';
import 'package:userapp/search_tailor.dart';
import 'package:userapp/main.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final primaryColor = const Color(0xFF6A1B9A); // Deep purple to match login theme
  String userName = "";
  String image = "";

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final user = await supabase
          .from('tbl_user')
          .select('user_name,user_photo')
          .eq('user_id', supabase.auth.currentUser!.id)
          .single();
      setState(() {
        userName = user['user_name'];
        image = user['user_photo'];
      });
    } catch (e) {
      print('Error loading user name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${userName.split(' ')[0]}! 👋',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        Text(
                          'What would you like to do today?',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileScreen()),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryColor,
                            width: 2,
                          ),
                        ),
                        child: image!="" ? CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(
                            image,
                          ),
                        ) : CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            color: primaryColor,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main Content
            SliverPadding(
              padding: const EdgeInsets.all(20.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildListDelegate([
                  _buildFeatureCard(
                    context,
                    title: 'Find a Tailor',
                    description: 'Search and connect with skilled tailors',
                    icon: Icons.search,
                    color: Colors.blue,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchTailor()),
                    ),
                  ),
                  _buildFeatureCard(
                    context,
                    title: 'Your Bookings',
                    description: 'Track your orders and appointments',
                    icon: Icons.calendar_today,
                    color: Colors.green,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserProfileBookingPage()),
                    ),
                  ),
                  _buildFeatureCard(
                    context,
                    title: 'Complaints',
                    description: 'Report issues and get support',
                    icon: Icons.support_agent,
                    color: Colors.orange,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserComplaintsPage()),
                    ),
                  ),
                  _buildFeatureCard(
                    context,
                    title: 'Profile',
                    description: 'View and edit your profile',
                    icon: Icons.person,
                    color: Colors.purple,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileScreen()),
                    ),
                  ),
                ]),
              ),
            ),

            // Promotional Banner
            SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.all(20.0),
    child: Container(
      height: 200,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/image.jpg'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.rotate(
                  angle: -0.1, // Slight tilt for a funky look
                  child: Text(
                    'Stitch Pro!',
                    style: TextStyle(
                      color: Colors.yellowAccent.withOpacity(0.9),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Transform.scale(
                  scale: 1.1, // Slight zoom effect
                  child: Text(
                    'Find & Book Epic Tailors!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      foreground: Paint()
                        ..color = Colors.pinkAccent
                        ..style = PaintingStyle.fill,
                      background: Paint()
                        ..color = Colors.purple.withOpacity(0.3)
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
