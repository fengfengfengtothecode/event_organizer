import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../model/event.dart';


class EventDialog extends StatefulWidget {
  final DateTime selectedDate;
  final Function(Event) onSave;

  EventDialog({required this.selectedDate, required this.onSave});

  @override
  _EventDialogState createState() => _EventDialogState(selectedDate);
}

class _EventDialogState extends State<EventDialog> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;

  _EventDialogState(DateTime selectedDate){
    this._selectedDate = selectedDate;
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _dateController = TextEditingController(text: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}');
    _timeController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _selectDate() async{
    final DateTime? newDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2050));
    if (newDate != null) {
      setState(() {
        _selectedDate = newDate.toUtc();
        _dateController.text = '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
      });
    }
  }

  void _selectTime() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (newTime != null) {
      setState(() {
        _timeController.text=newTime.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Create Event"),
      content: SingleChildScrollView(
      scrollDirection: Axis.vertical,
        child:Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "Title"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Title is required";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: "Description"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Description is required";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(labelText: "Time",
                  suffixIcon: Align(
                    widthFactor: 1.0,
                    heightFactor: 1.0,
                    child: IconButton(
                      icon:Icon(Icons.event,),
                      onPressed: _selectDate,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Date is required";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _timeController,
                readOnly: true,
                decoration: InputDecoration(labelText: "Time",
                  suffixIcon: Align(
                    widthFactor: 1.0,
                    heightFactor: 1.0,
                    child: IconButton(
                      icon:Icon(Icons.schedule,),
                      onPressed: _selectTime,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Time is required";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),

      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: Text("Save"),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final title = _titleController.text;
              final description = _descriptionController.text;
              final time = _timeController.text;
              final event = Event(
                title: title,
                description: description,
                date: _selectedDate,
                time: time,
                index: 0
              );
              widget.onSave(event);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}

