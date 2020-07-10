import 'package:eventtracker/bloc/ClientBloc.dart';
import 'package:eventtracker/model/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

class ClientEditor extends StatefulWidget {
  final Client client;

  ClientEditor({Key key, @required this.client}) : super(key: key);

  @override
  _ClientEditorState createState() => _ClientEditorState();
}

class _ClientEditorState extends State<ClientEditor> {
  TextEditingController _nameController;
  Color _colour;
  FocusNode _focus;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.client?.name);
    _colour = widget.client?.color ?? Colors.grey[50];
    _focus = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ClientBloc clientBloc = BlocProvider.of<ClientBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Opdrachtgever wijzigen",
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).accentColor
              ],
            ),
          ),
        ),
        actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              bool valid = _formKey.currentState.validate();
              if (!valid) return;
              clientBloc.add(
                EditClient(widget.client.id, _nameController.text.trim(),
                    _colour, widget.client.projects),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                child: Text(
                  "Vul een naam in",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              TextFormField(
                controller: _nameController,
                validator: (String value) =>
                    value.trim().isEmpty ? "Vul een naam in" : null,
                decoration: InputDecoration(hintText: "Client naam"),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 24, 0, 16),
                child: Text(
                  "Kies een kleur",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              MaterialColorPicker(
                physics: const NeverScrollableScrollPhysics(),
                selectedColor: _colour,
                shrinkWrap: true,
                onColorChange: (Color color) => _colour = color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
