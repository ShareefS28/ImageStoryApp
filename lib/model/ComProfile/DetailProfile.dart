import 'package:flutter/material.dart';

class DetailProfile extends StatefulWidget {
  const DetailProfile({Key? key}) : super(key: key);

  @override
  State<DetailProfile> createState() => _DetailProfileState();
}

class _DetailProfileState extends State<DetailProfile> {

  String radioButtonItem = 'Male';
  int id = 1;

  TextEditingController yourNameController = TextEditingController();
  TextEditingController yourAgeController = TextEditingController();
  TextEditingController yourDetailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Enter Name
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
            child: TextFormField(
              validator:(value) {
                if(value == null || value.isEmpty){
                  return 'Please enter name';
                }
                return null;
              },
              controller: yourNameController,
              obscureText: false,
              cursorColor: Colors.black,
              style: TextStyle(color: Colors.red.withOpacity(0.8),),
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelText: 'Name',
                labelStyle: TextStyle(
                  color: Colors.black),
                hintText: 'Enter Your Name',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.red,
                    width: 1,),
                  borderRadius: BorderRadius.circular(50.0)
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.green.shade900,
                    width: 1,
                    ),
                  borderRadius: BorderRadius.circular(50.0)
                  ),
                ),
              ),
            ),
          //Enter Age
          inputForm(yourAgeController, 'Age', 'Enter Your Age', TextInputType.number),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  'Gender Identity',
                  style: TextStyle(color: Colors.black.withOpacity(0.5), fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
          //Radio Button
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20, 5, 20, 0),
            child: Row(
              //mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Radio(
                  activeColor: Colors.green,
                  value: 1, 
                  groupValue: id,
                  onChanged: (val){
                    setState(() {
                      radioButtonItem = 'Male';
                      id = 1;
                    });
                  },
                ),
                Text(
                  'Male',
                  style: TextStyle(color: Colors.black),
                ),
                Radio(
                  activeColor: Colors.red,
                  value: 2, 
                  groupValue: id,
                  onChanged: (val){
                    setState(() {
                      radioButtonItem = 'Female';
                      id = 2;
                    });
                  },
                ),
                Text(
                  'Female',
                  style: TextStyle(color: Colors.black),
                ),
                Radio(
                  activeColor: Colors.purple,
                  value: 3, 
                  groupValue: id,
                  onChanged: (val){
                    setState(() {
                      radioButtonItem = 'Other';
                      id = 3;
                    });
                  },
                ),
                Text(
                  'Other',
                  style: TextStyle(color: Colors.black),
                ),
              ]
            ),
          ),
      ],), 
    );
  }

  Widget inputForm(controllerName, labelname, hintname, Keyboardtypekey){
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
      child: TextFormField(
        keyboardType: Keyboardtypekey,
        controller: controllerName,
        obscureText: false,
        cursorColor: Colors.black,
        style: TextStyle(color: Colors.red.withOpacity(0.8),),
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelText: labelname,
          labelStyle: TextStyle(
            color: Colors.black),
            hintText: hintname,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red,
              width: 1,),
            borderRadius: BorderRadius.circular(50.0)
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.green.shade900,
              width: 1,
              ),
            borderRadius: BorderRadius.circular(50.0)
          ),
        ),
      ),
    );  
  }
}