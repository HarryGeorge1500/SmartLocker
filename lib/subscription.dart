import 'package:flutter/material.dart';
import 'home.dart';
import 'main.dart';

class TimerService {
  DateTime? startTime;
  DateTime? endTime;

  void startTimer() {
    startTime = DateTime.now();
    print('hi');
  }

  void stopTimer() {
    endTime = DateTime.now();
  }

  Duration getElapsedTime() {
    if (startTime != null && endTime != null) {
      return endTime!.difference(startTime!);
    } else {
      return Duration.zero;
    }
  }
}
TimerService timerService = TimerService();

class SubscriptionPage extends StatefulWidget {
  final String name;
  final String user;

  const SubscriptionPage({required this.name, super.key, required this.user});

  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  bool isLocked = false;
  bool plug = false;
  String lockStatus = 'Unlocked';
  String plugStatus = 'OFF';

  @override
  void initState() {
    super.initState();
    updateStatus();
    timerService.startTimer();
  }

  void updateStatus() {
    lockStatus = isLocked ? 'Locked' : 'Unlocked';
    plugStatus = plug ? 'ON' : 'OFF';
  }

  Future<List> extraction() async {
      final data = await supabase
          .from('DeviceStatus')
          .select('ampere,voltage')
          .eq('device', widget.name);
      return [data[0]['ampere'],data[0]['voltage']];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(widget.user),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: ElevatedButton(
              onPressed: () async {
                await supabase
                    .from('DeviceStatus')
                    .update({'status': 0, 'current_user': null, 'plug':0,'availability':1})
                    .match({'device': widget.name});
                timerService.stopTimer();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EndPage(user: widget.user,),
                  ),
                );
              },
              child: const Text('Unsubscribe'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 160),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: FutureBuilder<List>(
                      future: extraction(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator(); // Show a loading indicator
                        } else if (snapshot.hasError) {
                          return const Text('Error fetching data'); // Display an error message
                        } else if (snapshot.hasData) {
                          // Display the fetched values
                          return Column(
                            children: [
                              Text('Current: ${snapshot.data?[0] ?? 'N/A'} Amps'),
                              Text('Voltage: ${snapshot.data?[1] ?? 'N/A'} Volts'),
                            ],
                          );
                        } else {
                          return const Text('No data available');
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Text('Locker State: $lockStatus'),
                  ElevatedButton(
                    onPressed: () async {
                      if(!plug){
                        setState(() {
                          isLocked = !isLocked;
                          updateStatus(); // Update status when isLocked changes
                        });
                        await supabase
                            .from('DeviceStatus')
                            .update({'status': isLocked ? 1 : 0})
                            .match({'device': widget.name});
                      }
                    },
                    child: Text(isLocked ? 'Unlock' : 'Lock'),
                  ),
                  Text('Power Plug: $plugStatus'),
                  ElevatedButton(
                    onPressed: () async {
                      if(isLocked){
                        setState(() {
                          plug = !plug;
                          updateStatus(); // Update status when plug changes
                        });
                        await supabase
                            .from('DeviceStatus')
                            .update({'plug': plug ? 1 : 0})
                            .match({'device': widget.name});
                      }
                    },
                    child: Text(plug ? 'OFF' : 'ON'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EndPage extends StatelessWidget {
  final String user;
  EndPage({super.key, required this.user});
  Duration elapsedTime = timerService.getElapsedTime();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UnSubscribed'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text('Hello $user, you have successfully unsubscribed from your locker'),
          ),
          const Text('Total time used: '),
          Text('${elapsedTime.inMinutes} min ${elapsedTime.inSeconds % 60} sec',
          style: const TextStyle(fontWeight: FontWeight.bold),),
          ElevatedButton(
              onPressed: (){
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FindLocker(email: user,),
                  ),
                );
              },
              child: const Text('OK'),
          )
        ],
      ),
    );
  }
}
