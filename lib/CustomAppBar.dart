import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return 
 Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/f6.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.transparent.withOpacity(0.5),
                    BlendMode.dstATop,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: AppBar(
                  iconTheme: IconThemeData(
                  color: Colors.white, 
                ),
                backgroundColor: Colors.transparent,
                title: Text(
                  title,
                  style: GoogleFonts.quicksand(textStyle: TextStyle(color: Colors.white ))
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.help_outline),
                    onPressed: () {
                      if(ModalRoute.of(context)?.settings.name != '/spravka' )
                          Navigator.of(context).pushNamed('/spravka');
                    },
                  ),
                ],
              ),
            ),
          ],
        );
  
  }
}
