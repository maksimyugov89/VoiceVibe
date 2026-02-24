import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/note.dart';
import '../services/audio_service.dart';

class CalendarScreen extends StatefulWidget {
  final AudioService audioService;
  final List<Note> notes;

  const CalendarScreen({super.key, required this.audioService, required this.notes});

  @override
  CalendarScreenState createState() => CalendarScreenState();
}

class CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isCalendarReady = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    initializeDateFormatting('ru_RU', null).then((_) {
      if (mounted) {
        setState(() {
          _isCalendarReady = true;
        });
      }
    });
  }

  List<Note> _getNotesForDay(DateTime day) {
    return widget.notes.where((note) => isSameDay(note.date, day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCalendarReady) {
      return const Center(child: CircularProgressIndicator());
    }

    final selectedNotes = _getNotesForDay(_selectedDay ?? _focusedDay);
    final theme = Theme.of(context);

    return Column(
      children: [
        TableCalendar<Note>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: _getNotesForDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarFormat: CalendarFormat.month,
          availableCalendarFormats: const {CalendarFormat.month: 'Месяц'},
          locale: 'ru_RU',
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            markerDecoration: BoxDecoration(
              color: theme.primaryColor,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: theme.primaryColor,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
        ),
        const Divider(),
        Expanded(
          child: selectedNotes.isEmpty
              ? const Center(
                  child: Text('Нет заметок за этот день'),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Заметки за ${_selectedDay?.day}.${_selectedDay?.month}.${_selectedDay?.year}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: selectedNotes.length,
                        itemBuilder: (context, index) {
                          final note = selectedNotes[index];
                          return Card(
                            color: theme.brightness == Brightness.dark ? const Color(0xFF252341) : Colors.white,
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: theme.primaryColor,
                                child: Text(
                                  '${note.date.hour.toString().padLeft(2, '0')}:${note.date.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    color: theme.brightness == Brightness.dark ? const Color(0xFF0F0E1C) : Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                              title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                note.text.isEmpty ? 'Нет текста' : note.text,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.play_arrow, color: Colors.green),
                                    onPressed: () => widget.audioService.playNote(note.path),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.share, color: Colors.blue),
                                    onPressed: () => widget.audioService.exportNote(note.path, note.title, note.text),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}