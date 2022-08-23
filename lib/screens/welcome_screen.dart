import 'package:birthday_book/model/settings.dart';
import 'package:birthday_book/utilities/utils.dart';
import 'package:birthday_book/utilities/widgets/welcome_logic.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  double _scrollOffset = 0;
  double buttonLeftOpacity = 0;
  CarouselController carouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    Settings.loadPrefs();

    var screens = [
      const _WelcomeSlide(),
      const _ContactsSlide(),
      const _MessengerSlide(),
      const _DoneSlide(),
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
                        duration: const Duration(milliseconds: 200),
                        child: IconButton(
                          icon: const Icon(
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
    return const _SlideContainer(
        icon: Icons.waving_hand,
        title: "Hi!",
        subtitle: "Thank you for downloading this app!");
  }
}

class _ContactsSlide extends StatelessWidget {
  const _ContactsSlide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _SlideContainer(
      icon: Icons.contacts,
      subtitle:
          "Do you want to import your contacts and their saved birthdays?",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Container(
            padding: const EdgeInsets.only(top: 32),
            child: Row(
              children: [
                Expanded(
                    child: OutlinedButton(
                      onPressed: onImportContactsTap(context),
                      style: OutlinedButton.styleFrom(
                          primary: Colors.white,
                          side: const BorderSide(color: Colors.white)),
                      child: const Text("Import contacts"),
                    )),
              ],
            )),

        Text("None of your contacts will be shared with us.", style: Theme.of(context).textTheme.displaySmall),
        GestureDetector(child: Text("Privacy Policy", style: Theme.of(context).textTheme.displaySmall?.copyWith(
          decoration: TextDecoration.underline,
        )),
        onTap: () {
          launchUrlString(StaticValues.privacyPolicyUrl);
        },)
      ],),
    );
  }
}

class _DoneSlide extends StatelessWidget {
  const _DoneSlide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _SlideContainer(
        icon: Icons.done,
        title: "Setup done",
        subtitle: "Never forget a birthday again");
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
    return _SlideContainer(
      icon: Icons.message,
      title: "Messenger",
      subtitle: "Please select the messenger you want to use",
      child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var msnger in PreferredMessenger.values)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: IconButton(
                    tooltip: msnger.humanReadable,
                    onPressed: () {
                      setState(() {
                        preferredMessenger = msnger;
                      });
                      Settings.preferredMessenger = msnger;
                    },
                    icon: Icon(
                      msnger.icon,
                      color: preferredMessenger == msnger
                          ? Colors.white
                          : Colors.white.withAlpha(150),
                    ),
                    iconSize: 48,
                  ),
                )
            ],
          )),
    );
  }
}

class _SlideContainer extends StatelessWidget {
  final IconData icon;
  final String? title;
  final String subtitle;
  final Widget? child;

  const _SlideContainer(
      {Key? key,
      required this.icon,
      this.title,
      required this.subtitle,
      this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Center(
            child: Container(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Icon(
                        Icons.waving_hand,
                        color: Colors.white.withAlpha(180),
                        size: 80,
                      ),
                      if (title != null)
                        Text(title!,
                            style: Theme.of(context).textTheme.headlineLarge),
                      Text(subtitle,
                          style: Theme.of(context).textTheme.headlineSmall),
                      if (child != null) child!
                    ],
                  ),
                ))));
  }
}
