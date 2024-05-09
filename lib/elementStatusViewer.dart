import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:IIT_precast_app/indexAppBar.dart';



typedef GetElementStatus = Pointer<Utf16> Function();

class ElementStatusViewer extends StatefulWidget {
  const ElementStatusViewer({super.key});

  @override
  State<ElementStatusViewer> createState() => _ElementStatusViewerState();

}

class _ElementStatusViewerState extends State<ElementStatusViewer> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IndexAppBar(title: 'Element Master',),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text('Element Status Viewer'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {

                },
                child: const Text('Retrieve Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


