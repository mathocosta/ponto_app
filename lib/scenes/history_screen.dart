import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ponto_app/db/time_entry.dart';
import 'package:ponto_app/scenes/history_content.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TimeEntries _timeEntries = TimeEntries();

  Future<Map<DateTime, List<TimeEntry>>> _allEntriesDataFuture;
  Future<List<TimeEntry>> _filteringDataFuture;

  DateTime _dateTimeToFilter;
  bool get _isFilteringByDate => _dateTimeToFilter != null;

  @override
  void initState() {
    super.initState();

    _allEntriesDataFuture = _timeEntries.listGroupedByDate();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("Histórico"),
          actions: _appBarActions(context),
          bottom: _isFilteringByDate ? _buildAppBarBottom(context) : null,
        ),
        body: _isFilteringByDate
            ? _FilteringEntriesContent(
                dataFuture: _filteringDataFuture,
                filteringDateTime: _dateTimeToFilter,
              )
            : _AllEntriesContent(dataFuture: _allEntriesDataFuture),
      );

  _onSelectDateToFilter(BuildContext context) async {
    _dateTimeToFilter = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().add(Duration(days: -1)),
      lastDate: DateTime.now(),
    );

    if (_dateTimeToFilter != null) {
      setState(() {
        _filteringDataFuture = _timeEntries.listOnDate(_dateTimeToFilter);
      });
    }
  }

  _onDeleteAction(BuildContext context) {
    setState(() {
      _timeEntries.clearTable();
      _allEntriesDataFuture = _timeEntries.listGroupedByDate();
    });
  }

  List<Widget> _appBarActions(BuildContext context) => [
        IconButton(
          icon: Icon(Icons.calendar_today_rounded),
          onPressed: () => _onSelectDateToFilter(context),
        ),
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () => _onDeleteAction(context),
        )
      ];

  PreferredSizeWidget _buildAppBarBottom(BuildContext context) {
    final DateFormat formatter = DateFormat.yMMMMd();

    return PreferredSize(
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formatter.format(_dateTimeToFilter),
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            IconButton(
              icon: Icon(
                Icons.cancel_rounded,
                color: Colors.white,
              ),
              onPressed: () => setState(() => _dateTimeToFilter = null),
            )
          ],
        ),
      ),
      preferredSize: Size.fromHeight(50),
    );
  }
}

class _FilteringEntriesContent extends StatelessWidget {
  const _FilteringEntriesContent({
    Key key,
    @required Future<List<TimeEntry>> dataFuture,
    @required DateTime filteringDateTime,
  })  : _dataFuture = dataFuture,
        _filteringDateTime = filteringDateTime,
        super(key: key);

  final DateTime _filteringDateTime;
  final Future<List<TimeEntry>> _dataFuture;

  Widget _buildListView(HistoryContentViewModel viewModel) => ListView.builder(
        itemCount: viewModel.items.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(viewModel.items[index].titleText),
          subtitle: Text(viewModel.items[index].subtitleText),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TimeEntry>>(
      initialData: [],
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<TimeEntry> resultList = snapshot.data;

          if (resultList != null && resultList.isNotEmpty) {
            return _buildListView(
              HistoryContentViewModel(_filteringDateTime, resultList),
            );
          } else {
            return Center(child: Text("Nenhuma entrada encontrada"));
          }
        } else {
          return Center(
            child: SizedBox(
              child: CircularProgressIndicator(),
              width: 60,
              height: 60,
            ),
          );
        }
      },
    );
  }
}

class _AllEntriesContent extends StatelessWidget {
  const _AllEntriesContent({
    Key key,
    @required Future<Map<DateTime, List<TimeEntry>>> dataFuture,
  })  : _dataFuture = dataFuture,
        super(key: key);

  final Future<Map<DateTime, List<TimeEntry>>> _dataFuture;

  Widget buildCard(HistoryContentViewModel viewModel) => Card(
        child: ExpansionTile(
          title: Text(
            viewModel.title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          children: viewModel.items
              .map((itemViewModel) => ListTile(
                    onTap: null,
                    title: Text(
                      itemViewModel.titleText,
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    subtitle: Text(itemViewModel.subtitleText),
                  ))
              .toList(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<DateTime, List<TimeEntry>>>(
      initialData: {},
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final Map<DateTime, List<TimeEntry>> resultMap = snapshot.data;

          if (resultMap != null && resultMap.isNotEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: resultMap.keys.length,
              itemBuilder: (context, index) {
                DateTime key = resultMap.keys.elementAt(index);

                return buildCard(HistoryContentViewModel(key, resultMap[key]));
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
    );
  }
}
