import 'package:flutter/material.dart';
import 'package:lane_dane/views/introscreens/introscreen1.dart';
import 'package:lane_dane/views/introscreens/introscreen2.dart';
import 'package:lane_dane/views/introscreens/introscreen3.dart';
import 'package:lane_dane/views/pages/authentication/enter_phone_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroMain extends StatefulWidget {
  static const routeName = 'intro-main';
  const IntroMain({Key? key}) : super(key: key);

  @override
  State<IntroMain> createState() => __IntroMainState();
}

class __IntroMainState extends State<IntroMain> {
  PageController _controller = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        PageView(
          controller: _controller,
          children: [
            IntroScreen1(),
            IntroScreen2(),
            IntroScreen3(),
          ],
        ),
        Container(
          alignment: Alignment(-0.82, 0.65),
          child: SmoothPageIndicator(
            controller: _controller,
            count: 3,
            effect: ExpandingDotsEffect(
              dotColor: Color(0xff26D367),
              activeDotColor: Color(0xff26D367),
            ),
          ),
        ),
        Positioned(
          child: ElevatedButton(
              onPressed: () {
                if (_controller.page == 2)
                  Navigator.of(context)
                      .pushReplacementNamed(EnterPhoneScreen.routeName);
                else
                  _controller.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.linear);
              },
              child: Text('Next ->'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff00A884),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                fixedSize: Size(119, 50),
              )),
          bottom: 40,
          right: 20,
        )
      ],
    ));
  }
}
