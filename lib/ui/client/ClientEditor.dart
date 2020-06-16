import 'package:eventtracker/bloc/ClientBloc.dart';
import 'package:eventtracker/model/model.dart';
import 'package:eventtracker/ui/project/ProjectEditor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
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
    ClientBloc clientBloc = BlocProvider.of<ClientBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Opdrachtgever",),
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
              icon: Icon(Icons.delete),
              onPressed: () async {
                clientBloc.add(
                  DeleteClient(widget.client.id),
                );
                Navigator.pop(context);
              },
            ),
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              bool valid = _formKey.currentState.validate();
              if (!valid) return;

                clientBloc.add(
                  EditClient(
                      widget.client.id,
                      _nameController.text.trim(),
                      _colour,
                      widget.client.projects),
                );

              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: BlocBuilder<ClientBloc, ClientState>(
        bloc: clientBloc,
        builder: (context, clientState) {
          return Padding(
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
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  MaterialColorPicker(
                    physics: const NeverScrollableScrollPhysics(),
                    selectedColor: _colour,
                    shrinkWrap: true,
                    onColorChange: (Color color) => _colour = color,
                  ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 24, 0, 16),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  title: Text(
                    "Projecten",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  children: getProductList(),
                ),
              ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> getProductList() {
    var clientProjects = widget?.client?.projects ?? [];
    var projects = clientProjects
        .map((project) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
              ),
              margin:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: ListTile(
                title: Text(project.name),
                subtitle: Text(
                    "€ ${project.centsToDouble().toStringAsFixed(2)} per uur"),
                trailing: Text( project.billable ? "Factureerbaar" : "",
                ),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => ProjectEditor(
                            project: project,
                            client: widget.client,
                          ));
                },
              ),
            ))
        .toList();
    projects.add(
      Container(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
          child: FlatButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                  child: Icon(Icons.add),
                ),
                Text("Project toevoegen"),
              ],
            ),
            textColor: Colors.deepPurple,
            onPressed: () {
              if (widget?.client != null) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => ProjectEditor(
                          project: null,
                          client: widget.client,
                        ));
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => Dialog(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                            child: Text(
                                "Eerst de opdrachtgever opslaan voordat je projecten kan toevoegen."),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              FlatButton(
                                child: Text("Ok"),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );

    return projects;
  }
}
