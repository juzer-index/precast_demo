import 'package:flutter/material.dart';

class IndexAppBar extends StatelessWidget implements PreferredSizeWidget {

  final String title;

  const IndexAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return AppBar(

      leading: width>600?SizedBox(
        width: 0,
        height: 0,

      ):null,
      backgroundColor: Theme.of(context).primaryColor,
      title: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(color: Colors.white)),
            // ClipOval(
            //   child: Image.network(
            //     'https://media.licdn.com/dms/image/D4D03AQFpmZgzpRLrhg/profile-displayphoto-shrink_800_800/0/1692612499698?e=1711584000&v=beta&t=Ho-Wta1Gpc-aiWZMJrsni_83CG16TQeq_gtbIJBM7aI',
            //     height: 35,
            //     width: 35,
            //   ),
            // )
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
