import 'package:flutter/material.dart';
import 'package:ponto_app/db/time_entry.dart';
import 'package:ponto_app/scenes/history_screen.dart';

class HomeScreen extends StatelessWidget {
  final TimeEntries _timeEntries = TimeEntries();

  AppBar _buildAppBar() {
    return AppBar(
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(Icons.settings),
        )
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bem vindo usuário",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "Empresa: tarara",
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
        ),
      ),
    );
  }

  _onCenterButtonPressed() {
    var timeEntry = TimeEntry();
    timeEntry.isActive = true;
    timeEntry.createdAt = DateTime.now().toUtc();

    _timeEntries.insert(timeEntry);
  }

  _showHistoryScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HistoryScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                color: Colors.green,
                child: InkWell(
                  onTap: _onCenterButtonPressed,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Fechar o ponto",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FeatureItem(
                      name: "Histórico",
                      icon: Icons.format_list_bulleted_rounded,
                      onPressed: () => _showHistoryScreen(context),
                    ),
                    _FeatureItem(
                      name: "Solicitar Abono",
                      icon: Icons.remove_circle_outline_rounded,
                      onPressed: null,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final Function onPressed;

  const _FeatureItem({
    Key key,
    this.name,
    this.icon,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        child: Material(
          color: Colors.green,
          child: InkWell(
            onTap: onPressed,
            child: Container(
              width: 120,
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 24.0,
                  ),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
