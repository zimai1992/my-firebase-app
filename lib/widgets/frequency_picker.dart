import 'package:flutter/material.dart';
import 'package:myapp/l10n/app_localizations.dart';

enum ScheduleType { evenlySpaced, pickTimes }

Future<Map<String, dynamic>?> showFrequencyPicker(BuildContext context) {
  return showModalBottomSheet<Map<String, dynamic>?>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return const _FrequencyPicker();
    },
  );
}

class _FrequencyPicker extends StatefulWidget {
  const _FrequencyPicker();

  @override
  _FrequencyPickerState createState() => _FrequencyPickerState();
}

class _FrequencyPickerState extends State<_FrequencyPicker> {
  int _selectedCount = 1;
  String _selectedInterval = 'Daily';
  ScheduleType _scheduleType = ScheduleType.evenlySpaced;
  List<TimeOfDay> _pickedTimes = [];

  final List<int> _counts = List.generate(10, (index) => index + 1);
  final List<String> _intervals = ['Daily', 'Weekly', 'Monthly'];

  @override
  void initState() {
    super.initState();
    _updatePickedTimes();
  }

  void _updatePickedTimes() {
    if (_selectedInterval == 'Daily' && _selectedCount > 1) {
      if (_scheduleType == ScheduleType.pickTimes) {
        if (_pickedTimes.length != _selectedCount) {
          setState(() {
            _pickedTimes =
                List.generate(_selectedCount, (index) => TimeOfDay.now());
          });
        }
      }
    }
  }

  List<TimeOfDay> _getEvenlySpacedTimes() {
    final List<TimeOfDay> times = [];
    const startTime = TimeOfDay(hour: 8, minute: 0);
    final interval = (24 / _selectedCount).floor();
    for (int i = 0; i < _selectedCount; i++) {
      times.add(
          TimeOfDay(hour: (startTime.hour + i * interval) % 24, minute: 0));
    }
    return times;
  }

  @override
  Widget build(BuildContext context) {
    _updatePickedTimes();
    final localizations = AppLocalizations.of(context)!;
    final showScheduleTimings =
        _selectedInterval == 'Daily' && _selectedCount > 1;
    final evenlySpacedTimes =
        showScheduleTimings ? _getEvenlySpacedTimes() : <TimeOfDay>[];

    final Map<String, String> intervalMap = {
      'Daily': localizations.frequency_daily,
      'Weekly': localizations.frequency_weekly,
      'Monthly': localizations.frequency_monthly,
    };

    final localizedIntervals = _intervals.map((i) => intervalMap[i]!).toList();
    final selectedLocalizedInterval = intervalMap[_selectedInterval]!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(localizations.select_frequency,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(localizations.how_many_times,
                          style: Theme.of(context).textTheme.titleMedium),
                      DropdownButton<int>(
                        isExpanded: true,
                        value: _selectedCount,
                        onChanged: (int? newValue) {
                          setState(() {
                            _selectedCount = newValue!;
                          });
                        },
                        items: _counts.map<DropdownMenuItem<int>>((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(localizations.how_often,
                          style: Theme.of(context).textTheme.titleMedium),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: selectedLocalizedInterval,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedInterval = intervalMap.entries
                                .firstWhere((entry) => entry.value == newValue)
                                .key;
                          });
                        },
                        items: localizedIntervals
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (showScheduleTimings) ...[
              const SizedBox(height: 20),
              Text(localizations.schedule_timings,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              SegmentedButton<ScheduleType>(
                segments: <ButtonSegment<ScheduleType>>[
                  ButtonSegment<ScheduleType>(
                      value: ScheduleType.evenlySpaced,
                      label: Text(localizations.evenly_spaced)),
                  ButtonSegment<ScheduleType>(
                      value: ScheduleType.pickTimes,
                      label: Text(localizations.pick_times)),
                ],
                selected: <ScheduleType>{_scheduleType},
                onSelectionChanged: (Set<ScheduleType> newSelection) {
                  setState(() {
                    _scheduleType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 20),
              if (_scheduleType == ScheduleType.evenlySpaced)
                Text(localizations.scheduled_at(evenlySpacedTimes
                    .map((time) => time.format(context))
                    .join(', ')))
              else
                ...List.generate(_selectedCount, (index) {
                  return ListTile(
                    title: Text(localizations.time_header(index + 1)),
                    trailing: Text(_pickedTimes[index].format(context)),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _pickedTimes[index],
                      );
                      if (time != null) {
                        setState(() {
                          _pickedTimes[index] = time;
                        });
                      }
                    },
                  );
                }),
            ],
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                child: Text(localizations.save_button),
                onPressed: () {
                  List<TimeOfDay> timesToSave;
                  if (showScheduleTimings) {
                    if (_scheduleType == ScheduleType.evenlySpaced) {
                      timesToSave = _getEvenlySpacedTimes();
                    } else {
                      timesToSave = _pickedTimes;
                    }
                  } else {
                    timesToSave = [const TimeOfDay(hour: 8, minute: 0)];
                  }

                  final result = {
                    'interval': _selectedInterval,
                    'count': _selectedCount,
                    'times': timesToSave,
                  };
                  Navigator.of(context).pop(result);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
