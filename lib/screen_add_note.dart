

import 'package:flutter/material.dart';
import 'package:noteapp/data/data.dart';
import 'package:noteapp/data/note_model/note_model.dart';


enum ActionType{
  addNote,
  editNote,
}


class ScreenAddNote extends StatelessWidget {
  final ActionType type;
  String? id;
   ScreenAddNote({
     Key? key,
     required this.type,
     this.id,
   }) : super(key: key);

   Widget get saveButton => TextButton.icon(
       onPressed: () {

     switch (type) {
       case ActionType.addNote:
         saveNote();
         break;
       case ActionType.editNote:
         saveEditedNote();
         break;
     }
   },
       icon: Icon(Icons.save,
       color: Colors.white,),
       label: Text(
         'Save',
         style: TextStyle(
           color: Colors.white
         ),
       ));

   final _titleController = TextEditingController();
   final _contentController = TextEditingController();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    if(type == ActionType.editNote){
      if(id == null){
        Navigator.of(context).pop();
      }
      final note = NoteDB.instance.getNoteByID(id!);
      if(note == null) {
        Navigator.of(context).pop();
      }

      _titleController.text = note?.title ?? 'No Title';
      _contentController.text = note?.content??'No content';
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          type.name.toUpperCase()
        ),
        actions: [
          saveButton,
        ],
      ),
      body: SafeArea(
        child: Padding(
        padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Title'
                ),
              ),
              TextFormField(
                controller: _contentController,
                maxLines: 4,
                maxLength: 100,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Content',
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveNote() async{
    final title = _titleController.text;
    final content = _contentController.text;

    final _newNote = NoteModel.create(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      content: content,
    );

   final newNote = await NoteDB().createNote(_newNote);
   if(newNote != null) {
     print('Note Saved');
     Navigator.of(_scaffoldKey.currentContext!).pop();
   }else{
     print('Error while saving note');
   }
  }

  Future<void> saveEditedNote() async{
    final _title = _titleController.text;
    final _content = _contentController.text;

    final editedNote = NoteModel.create(
      id: id,
      title: _title,
      content: _content,);
   final _note = NoteDB.instance.updateNote(editedNote);
   if(_note == null) {
     print('Unable to Update Note');
   }else{
     Navigator.of(_scaffoldKey.currentContext!).pop();
   }
  }
}
