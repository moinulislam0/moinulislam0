import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../alerts/screen/view/alart_screen.dart';
import '../../home/presentation/view/screen/home_screen.dart';
import '../../map/screen/view/map_screen.dart';
import '../../profile/presentation/view/screens/profile_screen.dart';
import '../../shout/presentation/views/screens/create_shout_screen.dart';
import '../../widget_custom/custom_app_bar_provider.dart';
import '../model_view/parent_screen_provider.dart';

class ParentScreen extends StatelessWidget {
  const ParentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ParentScreenProvider>(context);
    final customAppBarProvider = Provider.of<CustomAppBarProvider>(context);

    final userId = customAppBarProvider.data?.id ?? '';

    // List of screens
    List<Widget> _screens = [
      HomeScreen(),
      MapScreen(),
      CreateShoutScreen(),
      AlertScreen(),
      ProfileScreen(userId: userId,),
    ];

    return Scaffold(
      body: _screens[provider.selectIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xff030F08),
        currentIndex: provider.selectIndex,
        onTap: (index) {
          provider.setIndex(index); // update selectIndex in provider
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xff38E07B),
        unselectedItemColor: Colors.white,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: "Shout"),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            label: "Alerts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
