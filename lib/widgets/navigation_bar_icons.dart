import 'package:flutter/material.dart';

class MyNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  MyNavigationBar({required this.selectedIndex, required this.onItemSelected});

  @override
  _MyNavigationBarState createState() => _MyNavigationBarState();
}

class _MyNavigationBarState extends State<MyNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        5,
            (index) => NavBarItem(
          index: index,
          isSelected: widget.selectedIndex == index,
          onTap: () {
            widget.onItemSelected(index);
          },
        ),
      ),
    );
  }
}

class NavBarItem extends StatefulWidget {
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  NavBarItem({
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  _NavBarItemState createState() => _NavBarItemState();
}

class _NavBarItemState extends State<NavBarItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(_controller);

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant NavBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isSelected) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Transform.scale(
        scale: _animation.value,
        child: Container(
          width: MediaQuery.of(context).size.width / 4,
          child: Image.asset(
            'assets/bottomBar/icon${widget.index + 1}.png',
            width: 50,
            height: 50,
            color: widget.isSelected ? Colors.greenAccent : null,
          ),
        ),
      ),
    );
  }
}