import 'package:birthday_book/BirthdayEntry.dart';
import 'package:birthday_book/change_notifiers/settings.dart';
import 'package:birthday_book/model/birthday.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils.dart';

import '../main_screen.dart';

var _textHeader =
    Typography.blackMountainView.headline1?.apply(fontSizeDelta: 12);

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  double _scrollOffset = 0;
  double buttonLeftOpacity = 0;
  CarouselController carouselController = CarouselController();
  late SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    Settings.loadPrefs();

    var screens = [
      _WelcomeSlide(),
      _ContactsSlide(),
      _MessengerSlide(),
      _DoneSlide(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: [
          CarouselSlider(
            options: CarouselOptions(
                height: MediaQuery.of(context).size.height,
                viewportFraction: 1,
                initialPage: 0,
                enableInfiniteScroll: false,
                onScrolled: (val) {
                  setState(() {
                    _scrollOffset = val!;
                    if (_scrollOffset < .5) {
                      buttonLeftOpacity = 0;
                    } else {
                      buttonLeftOpacity = 1;
                    }
                  });
                }),
            items: screens,
            carouselController: carouselController,
          ),
          Positioned.fill(
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    child: SmoothIndicator(
                      offset: _scrollOffset,
                      count: screens.length,
                      effect: const WormEffect(
                        dotColor: Color(0x33111111),
                        activeDotColor: Colors.white,
                      ),
                    ),
                  ))),
          Positioned.fill(
              child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                      padding: const EdgeInsets.all(40),
                      child: AnimatedOpacity(
                        opacity: buttonLeftOpacity,
                        duration: Duration(milliseconds: 200),
                        child: IconButton(
                          icon: Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                          ),
                          iconSize: 40,
                          onPressed: _scrollOffset < .5
                              ? null
                              : () {
                                  setState(() {
                                    carouselController.previousPage();
                                  });
                                },
                        ),
                      )))),
          Positioned.fill(
              child: Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                      padding: const EdgeInsets.all(40),
                      child: IconButton(
                        icon: Icon(
                          _scrollOffset < screens.length - 1.5
                              ? Icons.chevron_right
                              : Icons.done,
                          color: Colors.white,
                        ),
                        iconSize: 40,
                        onPressed: () {
                          if (_scrollOffset < screens.length - 1) {
                            carouselController.nextPage();
                          } else {
                            openMainScreen(context);
                          }
                        },
                      ))))
        ],
      ),
    );
  }
}

class _WelcomeSlide extends StatelessWidget {
  const _WelcomeSlide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: Center(
            child: Container(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Icon(
                        Icons.waving_hand,
                        color: Colors.white.withAlpha(180),
                        size: 80,
                      ),
                      Text("Hi!",
                          style: Theme.of(context).textTheme.headlineLarge),
                      Text("Thank you for downloading this app!",
                          style: Theme.of(context).textTheme.headlineSmall),
                    ],
                  ),
                ))));
  }
}

class _ContactsSlide extends StatelessWidget {
  const _ContactsSlide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: Center(
            child: Container(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Container(
                          padding: EdgeInsets.all(24),
                          child: Icon(
                            Icons.contacts,
                            color: Colors.white.withAlpha(180),
                            size: 80,
                          )),
                      Text(
                          "Do you want to import your contacts and their saved birthdays?",
                          style: Theme.of(context).textTheme.headlineSmall),
                      Container(
                          padding: EdgeInsets.only(top: 32),
                          child: Row(
                            children: [
                              Expanded(
                                  child: OutlinedButton(
                                onPressed: () async {
                                  var permissionStatus =
                                      await Permission.contacts.request();
                                  if (permissionStatus.isDenied) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "Please grant contact permissions to link to a contact.")));
                                    return;
                                  }

                                  var contacts = await Utils.loadContacts();

                                  await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return SimpleDialog(
                                          title: Text("Import results"),
                                          children: [
                                            ListView.builder(
                                              itemCount: contacts.length,
                                              shrinkWrap: true,
                                              itemBuilder: (context, index) {
                                                return BirthdayEntry(
                                                  birthday: contacts[index],
                                                  ageCalcDate: DateTime.now(),
                                                  smallView: true,
                                                  canClick: false,
                                                );
                                              },
                                            ),
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text("Ok"))
                                          ],
                                        );
                                      });
                                  contacts.forEach((element) {
                                    Birthday.insert(element);
                                  });
                                },
                                child: Text("Import contacts"),
                                style: OutlinedButton.styleFrom(
                                    primary: Colors.white,
                                    side: BorderSide(color: Colors.white)),
                              ))
                            ],
                          )),
                    ],
                  ),
                ))));
  }
}

class _DoneSlide extends StatelessWidget {
  const _DoneSlide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: Center(
            child: Container(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Container(
                          padding: EdgeInsets.all(24),
                          child: Icon(
                            Icons.done,
                            color: Colors.white.withAlpha(180),
                            size: 80,
                          )),
                      Text("Setup done",
                          style: Theme.of(context).textTheme.headlineLarge),
                      Text("Never forget a birthday again",
                          style: Theme.of(context).textTheme.headlineSmall),
                    ],
                  ),
                ))));
  }
}

class _MessengerSlide extends StatefulWidget {
  const _MessengerSlide({Key? key}) : super(key: key);

  @override
  State<_MessengerSlide> createState() => _MessengerSlideState();
}

class _MessengerSlideState extends State<_MessengerSlide> {
  PreferredMessenger preferredMessenger = PreferredMessenger.values[0];

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: Center(
            child: Container(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Container(
                          padding: EdgeInsets.all(24),
                          child: Icon(
                            Icons.message,
                            color: Colors.white.withAlpha(180),
                            size: 80,
                          )),
                      Text("Messenger",
                          style: Theme.of(context).textTheme.headlineLarge),
                      Text("Please select a messenger you want to use",
                          style: Theme.of(context).textTheme.headlineSmall),
                      Container(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var msnger in PreferredMessenger.values)
                                Container(
                                  padding: EdgeInsets.all(16),
                                  child: IconButton(
                                    tooltip: msnger.humanReadable,
                                    onPressed: () {
                                      setState(() {
                                        preferredMessenger = msnger;
                                      });
                                      Settings.preferredMessenger = msnger;
                                    },
                                    icon: Icon(msnger.icon, color: preferredMessenger == msnger ? Colors.white : Colors.white.withAlpha(150),),
                                    iconSize: 48,
                                  ),
                                )
                            ],
                          )
                      )
                    ],
                  ),
                ))));
  }
}


void openMainScreen(BuildContext context) async {
  var prefs = await SharedPreferences.getInstance();
  prefs.setBool("firstStartFinished", true);
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => const MainScreen()));
}
