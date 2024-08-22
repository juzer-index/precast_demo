import 'package:flutter/material.dart';
import 'indexAppBar.dart';


class DetailsPage extends StatefulWidget {
  final String elementId;
  final Map<String, dynamic> elementDetails;
  final Color statusColor;
  const DetailsPage({super.key, required this.elementId, required this.elementDetails, required this.statusColor});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).shadowColor,
      appBar: IndexAppBar(title: 'Element Details',),
      body: Padding(

        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: SizedBox(

            height: MediaQuery.of(context).size.height * 0.8,
            width: MediaQuery.of(context).size.width ,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Element ID: ${widget.elementId}',
                    style:  TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).canvasColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                Row(children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        enabled: false,
                        decoration:  InputDecoration(
                          labelText: 'Part Num',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).canvasColor),
                          ),
                        ),
                        initialValue: widget.elementDetails
                        ['PartNum'],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Element ID',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        initialValue: widget.elementDetails
                        ['LotNum'],
                      ),
                    ),
                  ),
                ]),
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Element Desc',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        initialValue: widget.elementDetails
                        ['PartLotDescription'],
                      ),
                  ),
                ),
                Row(children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Project',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        initialValue: widget.elementDetails
                        ['Project_c'],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          fillColor: widget.statusColor,
                          filled: true,
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        initialValue: widget.elementDetails
                        ['ElementStatus_c'],
                      ),
                    ),
                  ),
                ]),
                Row(children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Erection Seq',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        initialValue: widget.elementDetails
                        ['ErectionSequence_c'].toString(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Erection Date',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        initialValue: widget.elementDetails
                        ['ErectionPlannedDate_c'],
                      ),
                    ),
                  ),
                ]),
                Row(children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'UOM',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        initialValue: widget.elementDetails
                        ['PartNumIUM'],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Weight',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        initialValue: widget.elementDetails
                        ['Ton_c'],
                      ),
                    ),
                  ),
                ]),
                Row(children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Volume',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        initialValue: widget.elementDetails
                        ['M3_c'],
                      ),
                    ),
                  ),
                ]),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Height',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      initialValue: widget.elementDetails
                      ['Height_c'],
                    ),
                  ),
                ),
                Row(children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Length',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        initialValue: widget.elementDetails
                        ['Length_c'],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Height',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        initialValue: widget.elementDetails
                        ['Width_c'],
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),

    );
  }
}