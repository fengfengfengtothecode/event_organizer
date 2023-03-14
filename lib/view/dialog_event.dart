import 'package:flutter/material.dart';

import '../model/event.dart';


class EventDialog extends StatefulWidget {
  final DateTime selectedDate;
  final Function(Event) onSave;
  final Event? toBeEditEvent;

  const EventDialog({super.key, required this.selectedDate, required this.onSave, this.toBeEditEvent});

  @override
  EventDialogState createState() => EventDialogState(selectedDate);
}

class EventDialogState extends State<EventDialog> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;

  EventDialogState(selectedDate){
    _selectedDate = selectedDate;
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text:widget.toBeEditEvent==null?'':'${widget.toBeEditEvent?.title}');
    _descriptionController = TextEditingController(text:widget.toBeEditEvent==null?'':'${widget.toBeEditEvent?.description}');
    _dateController = TextEditingController(text: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}');
    _timeController = TextEditingController(text:widget.toBeEditEvent==null?'':'${widget.toBeEditEvent?.time}');
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
    final DateTime? newDate = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2050));
    if (newDate != null) {
      setState(() {
        _selectedDate = DateTime.utc(newDate.year,newDate.month,newDate.day);
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
      title: const Text("Create Event"),
      content: SingleChildScrollView(
      scrollDirection: Axis.vertical,
        child:Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Title is required";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
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
                      icon:const Icon(Icons.event,),
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
                      icon:const Icon(Icons.schedule,),
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
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: const Text("Save"),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final title = _titleController.text;
              final description = _descriptionController.text;
              final time = _timeController.text;
              if(widget.toBeEditEvent==null) {
                final event = Event(
                  title: title,
                  description: description,
                  date: _selectedDate,
                  time: time,
                  index: 0,
                  status: Event_Status.TO_DO.name,
                );
                widget.onSave(event);
              }else{
                final event = widget.toBeEditEvent;
                event?.title = title;
                event?.description =description;
                event?.date = _selectedDate;
                event?.time = time;
                widget.onSave(event!);
              }
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}

