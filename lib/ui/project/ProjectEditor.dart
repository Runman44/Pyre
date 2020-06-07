import 'package:eventtracker/bloc/ClientBloc.dart';
import 'package:eventtracker/model/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class ProjectEditor extends StatefulWidget {
  final Project project;
  final Client client;

  ProjectEditor({Key key, @required this.project, @required this.client}) : super(key: key);

  @override
  _ProjectEditorState createState() => _ProjectEditorState();
}

class _ProjectEditorState extends State<ProjectEditor> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController;
  MoneyMaskedTextController _rateController;
  bool _isSwitched = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name);
    _rateController =  MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.', initialValue: widget.project?.centsToDouble() ?? 0.0);
    _isSwitched = widget.project?.billable ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Project",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: TextFormField(
                  controller: _nameController,
                  validator: (String value) =>
                      value.trim().isEmpty ? "Vul een naam in" : null,
                  decoration: InputDecoration(hintText: "Project naam"),
                ),
              ),
              TextFormField(
                controller: _rateController,
                keyboardType: TextInputType.number,
                validator: (String value) =>
                    value.trim().isEmpty ? "Vul een rate in" : null,
                decoration: InputDecoration(hintText: "Uurloon"),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Factureerbaar"),
                    Switch(
                      value: _isSwitched,
                      onChanged: (value) {
                        setState(() {
                          _isSwitched = value;
                        });
                      }),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FlatButton(
                    child: Text("Annuleren"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Visibility(
                    visible: widget.project != null,
                    child: FlatButton(
                      child: Text("Verwijderen", style: TextStyle(color: Colors.red),),
                      onPressed: () {
                        final ClientBloc clientBloc = BlocProvider.of<ClientBloc>(context);
                        clientBloc.add(DeleteProject(widget.client, widget.project.id));
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  FlatButton(
                    child: Text("Opslaan"),
                    onPressed: () async {
                      bool valid = _formKey.currentState.validate();
                      if(!valid) return;
                      final ClientBloc clientBloc = BlocProvider.of<ClientBloc>(context);
                      assert(clientBloc != null);
                      if(widget.project != null) {
                        clientBloc.add(EditProject(widget.client, widget.project.id, _nameController.text.trim(), _rateController.numberValue, _isSwitched));
                      } else {
                        clientBloc.add(AddProject(widget.client, _nameController.text.trim(), _rateController.numberValue, _isSwitched));
                      }
                      Navigator.of(context).pop();
                    },
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

