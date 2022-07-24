
import 'package:flutter/material.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     const double height = 240;
//     return Container(
//         height: height,
//         child: Stack(
//             children: const [
//               Align(
//                   alignment: Alignment.topCenter,
//                   child: _HeaderBackGround()
//               ),
//               // Align(
//               //     alignment: Alignment.topCenter,
//               //     child: _HeaderCircles(height: height),
//               // ),
//               Align(
//                   alignment: Alignment.topCenter,
//                   child: Padding(
//                     padding: EdgeInsets.only(top: 70),
//                     child: _HeaderTitle(),
//                   ),
//               )
//             ]
//         )
//     );
//   }
// }
class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double height = 240;
    return Container(
        width: MediaQuery.of(context).size.width,
        height: height,
        child: Stack(
            children: const [
              Align(
                  alignment: Alignment.topCenter,
                  child: _HeaderImage()
              ),
              // Align(
              //     alignment: Alignment.topCenter,
              //     child: _HeaderCircles(height: height),
              // ),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: 120),
                  child: _HeaderTitle(),
                ),
              )
            ]
        )
    );
  }
}

class _HeaderBackGround extends StatelessWidget {
  const _HeaderBackGround({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: MyClipper(),
      child: Container(
        padding: const EdgeInsets.only(left: 40, top: 50, right: 20),
        height: MediaQuery.of(context).size.height/3,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFFFD9766),
              Color(0xFFFF7362)
            ]
          )
        ),
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
 @override
 Path getClip(Size size){
   return Path()
       ..lineTo(0, size.height - 50)
       ..quadraticBezierTo(
           size.width/2,
           size.height,
           size.width,
           size.height -60)
       ..lineTo(size.width, 0)
       ..close();
 }
 @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
   return false;
 }
}

class _HeaderCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
        ..color = Colors.white.withOpacity(.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6;
    
    canvas.drawCircle(
        Offset(size.width * 0.22, size.height * 0.5),
        12,
        paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.2),
      12,
      paint,
    );
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class _HeaderCircles extends StatelessWidget {
  const _HeaderCircles({Key? key, required this.height}) : super(key: key);

  final double height;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HeaderCirclePainter(),
      child: Container(
        width: double.infinity,
        height: height,
      ),
    );
  }
}

class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
        'TRAINING TIMER',
        style: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.w900
        )
    );
  }
}


class _HeaderImage extends StatelessWidget {
  const _HeaderImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/header.jpeg'),
          fit: BoxFit.cover,
          opacity: 0.7
        ) ,
      ),
      width: MediaQuery.of(context).size.width,
    );
  }
}

