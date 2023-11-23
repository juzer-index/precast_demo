import 'package:flutter/material.dart';
import 'package:precast_demo/indexAppBar.dart';

class ElementMaster extends StatefulWidget {
  const ElementMaster({super.key});

  @override
  State<ElementMaster> createState() => _ElementMasterState();
}

class _ElementMasterState extends State<ElementMaster> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IndexAppBar(title: 'Element Master',),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.12,
                    child: Card(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      elevation: 1,
                      color: Colors.lightBlue.shade100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  suffixIcon: Icon(Icons.search, color: Colors.blue,),
                                  fillColor: Colors.white,
                                    filled: true,
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.blue),
                                    ),
                                    labelText: "Part Number"),
          
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                    suffixIcon: Icon(Icons.search, color: Colors.blue,),
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.blue),
                                    ),
                                    labelText: "Element ID"),
          
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              onPressed: () {
          
                              },
                              icon: Icon(
                                  Icons.refresh_sharp,
                                color: Colors.blueGrey.shade800,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: Card(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero
                      ),
                      color: Colors.lightBlue.shade100,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
