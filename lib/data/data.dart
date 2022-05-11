import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:noteapp/data/note_model/get_all_notes_resp.dart';
import 'package:noteapp/data/note_model/note_model.dart';
import 'package:noteapp/data/url.dart';
import 'package:flutter/src/foundation/change_notifier.dart';



import 'package:dio/dio.dart';

abstract class ApiCalls{

Future<NoteModel?> createNote(NoteModel value);
Future<List<NoteModel>> getAllNotes();
Future<NoteModel?> updateNote(NoteModel value);
Future<void> deleteNote(String id);

}

class NoteDB extends ApiCalls{

  NoteDB._internal();

  static NoteDB instance = NoteDB._internal();

  //==singleton

  NoteDB factory(){
    return instance;
  }

  // singleton end

  final dio = Dio();
  final url = Url();

  ValueNotifier<List<NoteModel>> noteListNotifier = ValueNotifier([]);

  NoteDB() {
    dio.options = BaseOptions(
      baseUrl: url.baseUrl,
      responseType: ResponseType.plain,
    );
  }

  @override
  Future<NoteModel?> createNote(NoteModel value) async{
    try {
      final _result = await dio.post(
        url.createNote,
        data: value.toJson(),
      );
     final _resultAsJson = jsonDecode(_result.data);
     final note = NoteModel.fromJson(_resultAsJson as Map<String, dynamic>);
     noteListNotifier.value.insert(0, note);
     noteListNotifier.notifyListeners();
     return note;
    }on DioError catch (e) {
      return null;
    }catch (e){
      return null;
    }
  }

  @override
  Future<void> deleteNote(String id) async{
    final _result = await dio.delete(url.deleteNote.replaceFirst('{id}', id));
    if(_result.data == null){
      return;
    }
    final _index = noteListNotifier.value.indexWhere((note) => note.id == id);
    if(_index == -1) {
      return;
    }
    noteListNotifier.value.removeAt(_index);
    noteListNotifier.notifyListeners();

  }

  @override
  Future<List<NoteModel>> getAllNotes() async{
    final _result = await dio.get(url.getAllNotes);
    if(_result.data != null) {
      final getNoteResp = GetAllNotesResp.fromJson(_result.data);
      noteListNotifier.value.clear();
      noteListNotifier.value.addAll(getNoteResp.data.reversed);
      noteListNotifier.notifyListeners();
      return getNoteResp.data;
    }else{
      noteListNotifier.value.clear();
      return [];
    }
  }

  @override
  Future<NoteModel?> updateNote(NoteModel value) async{
    final _result = await dio.put(url.updateNote, data: value.toJson());
    if(_result.data == null){
      return null;
    }
    //find index =
    final index =
    noteListNotifier.value.indexWhere((note) => note.id == value.id);
    if(index == -1){
      return null;
    }

    //remove from index

    noteListNotifier.value.removeAt(index);

    //add note in that index

    noteListNotifier.value.insert(index, value);
    noteListNotifier.notifyListeners();
    return value;

  }

  NoteModel? getNoteByID(String id) {
    try {
      noteListNotifier.value.firstWhere((note) => note.id == id);
    } catch (_) {
      return null;
    }
  }
}