import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/utils/locale/language_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translate.getString("app_info.title", context),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.white, size: 35),
          onPressed: () => Navigator.pop(context),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Image.asset('assets/images/ai_cms.png', height: 40),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  Translate.getString("app_info.version", context),
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(width: 5),
                Text(
                  "1.0.0",
                  style: TextStyle(
                    color: AppColors.accentColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              Translate.getString("app_info.description", context),
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}
