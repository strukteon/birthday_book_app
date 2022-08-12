import 'package:birthday_book/change_notifiers/birthday.dart';
import 'package:birthday_book/screens/all_bds_screen.dart';
import 'package:birthday_book/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'screens/main_calendar_screen.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Container(
            color: Theme.of(context).primaryColorDark,
            child: SafeArea(
                child: Column(
              children: [
                Expanded(child: Container()),
                const TabBar(indicatorColor: Colors.white, tabs: [
                  Tab(
                    icon: Icon(Icons.calendar_today),
                  ),
                  Tab(
                    icon: Icon(Icons.people),
                  ),
                  Tab(
                    icon: Icon(Icons.settings),
                  ),
                ])
              ],
            )),
          ),
        ),
        body: ChangeNotifierProvider(
          create: (context) => AllBirthdays(),
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              // remove overscroll glow on tab view
              if (overscroll.depth == 0) {
                overscroll.disallowIndicator();
              }
              return false;
            },
            child: const TabBarView(
              physics: ScrollPhysics(),
              children: <Widget>[
                CalenderWidget(),
                AllBdsScreen(),
                SettingsScreen(),
              ],
            ),
          )
        ),
      ),
    );
  }
}
