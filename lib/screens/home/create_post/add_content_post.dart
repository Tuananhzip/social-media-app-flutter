import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class AddContentPost extends StatefulWidget {
  const AddContentPost({
    super.key,
    required this.fileList,
    required this.widgetList,
  });
  final List<File> fileList;
  final List<Widget> widgetList;

  @override
  State<AddContentPost> createState() => _AddContentPostState();
}

class _AddContentPostState extends State<AddContentPost> {
  final TextEditingController contentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(children: [
          if (widget.widgetList.isNotEmpty)
            CarouselSlider.builder(
              itemCount: widget.widgetList.length,
              itemBuilder: (context, index, realIndex) {
                return widget.widgetList[index];
              },
              options: CarouselOptions(
                height: 300.0,
                viewportFraction: 1,
                enlargeCenterPage: true,
                enlargeStrategy: CenterPageEnlargeStrategy.height,
                enableInfiniteScroll: false,
                scrollDirection: Axis.horizontal,
              ),
            ),
          if (widget.widgetList.isEmpty)
            Container(
              width: 400.0,
              height: 300.0,
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              margin: const EdgeInsets.symmetric(horizontal: 12.0),
            ),
          TextField(
            controller: contentController,
          )
        ]),
      ),
    );
  }
}
