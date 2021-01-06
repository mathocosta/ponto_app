import 'package:intl/intl.dart';
import 'package:ponto_app/db/time_entry.dart';

class HistoryItemViewModel {
  final String titleText;
  final String subtitleText;

  HistoryItemViewModel(this.titleText, this.subtitleText);
}

class HistoryContentViewModel {
  final DateTime _dateTime;
  final List<TimeEntry> _timeEntries;

  HistoryContentViewModel(this._dateTime, this._timeEntries);

  final DateFormat _timeFormatter = DateFormat.yMMMd().add_Hm();
  final DateFormat _dateFormatter = DateFormat.yMMMMd();

  // Título da célula
  String get title => '${_dateFormatter.format(_dateTime.toLocal())} '
      '- $formattedCompletedDuration';

  // Tempos dos pontos formatados
  List<HistoryItemViewModel> get items => _timeEntries
      .map((item) => HistoryItemViewModel(
            _timeFormatter.format(item.createdAt.toLocal()),
            "Identificador: ${item.id}",
          ))
      .toList();

  // Duração da jornada de trabalho cumprida no grupo de pontos
  Duration get _completedDuration {
    Duration completedDuration = Duration.zero;
    // 1. orderna do mais anterior para o mais recente
    var sortedByOlder = List<TimeEntry>.from(_timeEntries)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

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
