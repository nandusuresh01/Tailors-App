import 'package:flutter/material.dart';
import 'package:tailor_app/login.dart';
import 'package:tailor_app/main.dart';
import 'package:tailor_app/mybookings.dart';
import 'package:tailor_app/mymaterial.dart';
import 'package:tailor_app/profilepage.dart';
import 'package:fl_chart/fl_chart.dart'; // Add this package for charts
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  final primaryColor = Color(0xFF6A1B9A); // Deep purple for fashion theme
  final accentColor = Color(0xFFE91E63); // Pink accent
  
  // Sample data for dashboard stats - in a real app, fetch this from your database
  final Map<String, dynamic> dashboardStats = {
    'newOrders': 5,
    'ongoingOrders': 8,
    'completedOrders': 23,
    'totalEarnings': 12580,
    'pendingPayments': 3200,
    'materialsCount': 15,
  };
  
  // Sample data for weekly earnings chart
  final List<FlSpot> weeklyEarnings = [
    FlSpot(0, 500),
    FlSpot(1, 850),
    FlSpot(2, 600),
    FlSpot(3, 1200),
    FlSpot(4, 750),
    FlSpot(5, 900),
    FlSpot(6, 1100),
  ];
  
  // Sample data for recent orders
  final List<Map<String, dynamic>> recentOrders = [
    {
      'customerName': 'John Doe',
      'orderType': 'Shirt',
      'dueDate': DateTime.now().add(Duration(days: 2)),
      'status': 'In Progress',
      'amount': 1200,
      'profileImage': null,
    },
    {
      'customerName': 'Sarah Smith',
      'orderType': 'Evening Gown',
      'dueDate': DateTime.now().add(Duration(days: 5)),
      'status': 'Measurement Taken',
      'amount': 3500,
      'profileImage': null,
    },
    {
      'customerName': 'Mike Johnson',
      'orderType': 'Suit Alteration',
      'dueDate': DateTime.now().add(Duration(days: 1)),
      'status': 'Ready for Fitting',
      'amount': 800,
      'profileImage': null,
    },
  ];
  
  // Sample data for tailor profile
  Map<String, dynamic> tailorProfile = {
    'name': 'Shaji',
    'expertise': 'Shirts & Pants',
    'rating': 4.8,
    'completedOrders': 152,
    'profileImage': 'assets/tailor.png',
  };
  
  @override
  void initState() {
    super.initState();
    // In a real app, fetch tailor profile and dashboard stats here
    _fetchTailorProfile();
    _fetchDashboardStats();
  }
  
  Future<void> _fetchTailorProfile() async {
    // In a real app, fetch this from Supabase
    // For now, we'll use the sample data
  }
  
  Future<void> _fetchDashboardStats() async {
    // In a real app, fetch this from Supabase
    // For now, we'll use the sample data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom App Bar
            _buildAppBar(),
            
            // Main Content
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16),
                    
                    // Tailor Profile Card
                    _buildProfileCard(),
                    
                    SizedBox(height: 24),
                    
                    // Quick Stats Cards
                    _buildQuickStats(),
                    
                    SizedBox(height: 24),
                    
                    // Weekly Earnings Chart
                    _buildWeeklyEarningsChart(),
                    
                    SizedBox(height: 24),
                    
                    // Recent Orders
                    _buildRecentOrders(),
                    
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      
    );
  }
  
  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      title: Text(
        "Tailor Dashboard",
        style: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevation: 0,
      actions: [
        
        IconButton(
          icon: Icon(Icons.logout, color: primaryColor),
          onPressed: () async {
            // Show confirmation dialog
            bool confirm = await _showLogoutConfirmationDialog();
            if (confirm) {
              await supabase.auth.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => Login(),
                ),
                (route) => false,
              );
            }
          },
        ),
      ],
    );
  }
  
  Widget _buildProfileCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Profile Image
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    image: DecorationImage(
                      image: AssetImage(tailorProfile['profileImage']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                
                // Profile Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tailorProfile['name'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          _buildProfileStat(Icons.star, "${tailorProfile['rating']}"),
                          SizedBox(width: 16),
                          _buildProfileStat(Icons.check_circle, "${tailorProfile['completedOrders']} orders"),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Edit Button
                
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildProfileStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Stats",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard(
              "New Orders",
              "${dashboardStats['newOrders']}",
              Icons.shopping_bag_outlined,
              accentColor,
            ),
            SizedBox(width: 12),
            _buildStatCard(
              "Ongoing",
              "${dashboardStats['ongoingOrders']}",
              Icons.access_time,
              Colors.orange,
            ),
            SizedBox(width: 12),
            _buildStatCard(
              "Completed",
              "${dashboardStats['completedOrders']}",
              Icons.check_circle_outline,
              Colors.green,
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard(
              "Earnings",
              "₹${NumberFormat('#,###').format(dashboardStats['totalEarnings'])}",
              Icons.account_balance_wallet_outlined,
              Colors.blue,
              isWide: true,
            ),
            SizedBox(width: 12),
            _buildStatCard(
              "Pending",
              "₹${NumberFormat('#,###').format(dashboardStats['pendingPayments'])}",
              Icons.payment_outlined,
              Colors.red,
              isWide: true,
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color, {bool isWide = false}) {
    return Expanded(
      flex: isWide ? 2 : 1,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: isWide ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWeeklyEarningsChart() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Weekly Earnings",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "This Week",
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 500,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (value >= 0 && value < days.length) {
                          return Text(
                            days[value.toInt()],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          );
                        }
                        return Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 500,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '₹${value.toInt()}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 1500,
                lineBarsData: [
                  LineChartBarData(
                    spots: weeklyEarnings,
                    isCurved: true,
                    color: accentColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: accentColor.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecentOrders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Orders",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MyBooking()));
              },
              child: Text(
                "View All",
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        ...recentOrders.map((order) => _buildOrderCard(order)).toList(),
      ],
    );
  }
  
  Widget _buildOrderCard(Map<String, dynamic> order) {
    Color statusColor;
    switch (order['status']) {
      case 'In Progress':
        statusColor = Colors.orange;
        break;
      case 'Ready for Fitting':
        statusColor = Colors.blue;
        break;
      case 'Measurement Taken':
        statusColor = Colors.purple;
        break;
      case 'Completed':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to order details
            Navigator.push(context, MaterialPageRoute(builder: (context) => MyBooking()));
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                // Customer Image
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey[200],
                  child: order['profileImage'] != null
                      ? null
                      : Icon(Icons.person, color: Colors.grey[400]),
                ),
                SizedBox(width: 12),
                
                // Order Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['customerName'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        order['orderType'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            "Due: ${DateFormat('MMM dd').format(order['dueDate'])}",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Status and Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order['status'],
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "₹${NumberFormat('#,###').format(order['amount'])}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 5,
      child: SizedBox(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(Icons.home, "Home", true),
            _buildBottomNavItem(Icons.shopping_bag_outlined, "Orders", false),
            _buildBottomNavItem(Icons.design_services_outlined, "Materials", false),
            _buildBottomNavItem(Icons.person_outline, "Profile", false),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBottomNavItem(IconData icon, String label, bool isSelected) {
    return InkWell(
      onTap: () {
        // Handle navigation
        if (label == "Orders") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => MyBooking()));
        } else if (label == "Profile") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
        } else if (label == "Materials") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => MyMaterialPage()));
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? primaryColor : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? primaryColor : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  Future<bool> _showLogoutConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Logout"),
            ),
          ],
        );
      },
    ) ?? false;
  }
}