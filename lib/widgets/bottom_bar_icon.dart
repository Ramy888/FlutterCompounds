import 'package:flutter/material.dart';

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  CustomBottomBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bottomBar/footer_bg.png'),
          fit: BoxFit.fill,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CustomBottomBarItem(
            icon: 'assets/bottomBar/icon1.png',
            activeIcon: 'assets/bottomBar/icon_home_active.png',
            isActive: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          CustomBottomBarItem(
            icon: 'assets/bottomBar/icon3.png',
            activeIcon: 'assets/bottomBar/icon_contact_active.png',
            isActive: currentIndex == 4,
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }
}

class CustomBottomBarItem extends StatelessWidget {
  final String icon;
  final String activeIcon;
  final bool isActive;
  final VoidCallback onTap;

  CustomBottomBarItem({
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              isActive ? activeIcon : icon,
              height: 50,
              width: 50,
            ),
            if (isActive)
              Ink(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: SizedBox(
                  height: 50,
                  width: 50,
                ),
              ),
          ],
        ),
      ),
    );
  }
}