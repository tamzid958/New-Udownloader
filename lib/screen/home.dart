import 'package:flutter/material.dart';
import 'package:udownloaderz/constants.dart';
import 'package:udownloaderz/service/youtube.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String url = '';
  String dir = '';
  String filename = '';
  double stats = 0.0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _linkcontroller = TextEditingController();
  String _downloadFileType = "audio";

  @override
  void initState() {
    super.initState();
  }

  void _showToast(BuildContext context, String text) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(text),
        action: SnackBarAction(
            label: 'ok', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Developed by Tamzid"),
      ),
      persistentFooterButtons: [
        Text(
          'Only for ritu ❤️',
          textAlign: TextAlign.center,
          style: TextStyle(
            letterSpacing: 1,
          ),
        )
      ],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width / 1.1,
        child: FloatingActionButton.extended(
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              url = _linkcontroller.text;
              if (!await download(url, _downloadFileType)) {
                _showToast(context, 'Download failed');
              } else {
                _showToast(context, 'Download successful');
              }
              setState(() {
                _formKey.currentState!.reset();
              });
            }
          },
          label: Text(
            "Submit",
          ),
        ),
      ),
      body: Container(
        child: Padding(
          padding: EdgeInsets.all(KdefaultPaddin),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownButtonFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    value: _downloadFileType,
                    items: [
                      DropdownMenuItem<String>(
                        child: Text('Video'),
                        value: 'video',
                      ),
                      DropdownMenuItem<String>(
                        child: Text('Audio'),
                        value: 'audio',
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.toString().isEmpty) {
                        return 'Choose Something';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _downloadFileType = value as String;
                      });
                    }),
                SizedBox(
                  height: 5,
                ),
                TextFormField(
                  controller: _linkcontroller,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.content_paste),
                    border: OutlineInputBorder(),
                    hintText: 'Enter YouTube Link',
                    helperText:
                        "Hit the share icon and select copy url in the youtube.",
                  ),
                  validator: (value) {
                    if (value == null || value.toString().isEmpty) {
                      return 'Enter Valid Youtube Url';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
