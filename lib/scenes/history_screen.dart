import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ponto_app/db/time_entry.dart';

class HistoryScreen extends StatelessWidget {
  final TimeEntries _timeEntries = TimeEntries();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Histórico"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _timeEntries.clearTable(),
          )
        ],
      ),
      body: FutureBuilder<Map<DateTime, List<TimeEntry>>>(
        initialData: {},
        future: _timeEntries.listGroupedByDate(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final Map<DateTime, List<TimeEntry>> resultMap = snapshot.data;

            if (resultMap != null && resultMap.isNotEmpty) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: resultMap.keys.length,
                itemBuilder: (context, index) {
                  DateTime key = resultMap.keys.elementAt(index);

                  return _HistoryCell(
                    dateTitle: key,
                    timeEntries: resultMap[key],
                  );
                },
              );
            } else {
              return Center(child: Text("Nenhuma entrada encontrada"));
            }
          } else {
            return SizedBox(
              child: CircularProgressIndicator(),
              width: 60,
              height: 60,
            );
          }
        },
      ),
    );
  }
}

class _HistoryCellViewModel {
  final DateTime _dateTime;
  final List<TimeEntry> _timeEntries;

  _HistoryCellViewModel(this._dateTime, this._timeEntries);

  final DateFormat _timeFormatter = DateFormat.Hm();
  final DateFormat _dateFormatter = DateFormat.yMd();

  // Título da célula
  String get title => '${_dateFormatter.format(_dateTime.toLocal())} '
      '- $formattedCompletedDuration';

  // Tempos dos pontos formatados
  List<String> get items => _timeEntries
      .map((item) => _timeFormatter.format(item.createdAt.toLocal()))
      .toList();

  // Duração da jornada de trabalho cumprida no grupo de pontos
  Duration get _completedDuration {
    Duration completedDuration = Duration.zero;
    // 1. orderna do mais anterior para o mais recente
    var sortedByOlder = List<TimeEntry>.from(_timeEntries);
    sortedByOlder.sort(
      (a, b) => a.createdAt.compareTo(b.createdAt),
    );

    // 2. iterar de 2 em 2 pra conseguir pegar a diferença dos tempos
    for (var i = 0; i < sortedByOlder.length; i += 2) {
      var actualDatetime = sortedByOlder[i].createdAt;
      var nextDatetime = sortedByOlder.length > (i + 1)
          ? sortedByOlder[i + 1].createdAt
          : DateTime.now().toUtc();
      completedDuration += nextDatetime.difference(actualDatetime);
    }

    return completedDuration;
  }

  String get formattedCompletedDuration {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes =
        twoDigits(_completedDuration.inMinutes.remainder(60));
    return "${twoDigits(_completedDuration.inHours)}:$twoDigitMinutes";
  }
}

class _HistoryCell extends StatelessWidget {
  final _HistoryCellViewModel _viewModel;

  _HistoryCell({
    Key key,
    DateTime dateTitle,
    List<TimeEntry> timeEntries,
  })  : this._viewModel = _HistoryCellViewModel(dateTitle, timeEntries),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(
          _viewModel.title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        children: _viewModel.items
            .map((title) => ListTile(
                  onTap: null,
                  title: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
