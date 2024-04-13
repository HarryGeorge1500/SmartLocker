import 'package:flutter/material.dart';
import 'package:locker/maps.dart';
import 'package:locker/subscription.dart';
import 'main.dart';

class Availability extends StatefulWidget {
  final String currentUser;
  final String country;
  final String state;
  final String district;

  const Availability({
    super.key, required this.currentUser, required this.country, required this.state, required this.district
  });

  @override
  _AvailabilityState createState() => _AvailabilityState();
}

class _AvailabilityState extends State<Availability> {
  late Future<List<Map<String, dynamic>>> deviceStatus;

  @override
  void initState() {
    super.initState();
    deviceStatus = _fetchDeviceStatus();
  }

  Future<List<Map<String, dynamic>>> _fetchDeviceStatus() async {
    final response = await supabase
        .from('DeviceStatus')
        .select('device,location')
        .eq('country',widget.country)
        .eq('state', widget.state)
        .eq('district', widget.district);


    final List<Map<String, dynamic>> data = (response).cast<Map<String, dynamic>>();
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Locker'),
        actions: [
          IconButton(
            onPressed: (){
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context)=>Filter(user: widget.currentUser,),
                ),
              );
            },
            icon: const Icon(Icons.filter_alt_outlined),
          ),
        ],
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
          const SizedBox(height: 8.0),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(widget.currentUser,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black, // Customize the color if needed
          ),
        ),
      ),
      Expanded(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: deviceStatus,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No locks available at this moment. Please try again later');
            } else {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final deviceData = snapshot.data![index];
                    final deviceName = deviceData['device'].toString();
                    final location = deviceData['location'].toString();

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AnotherPage(
                              deviceName: deviceName,
                              location: location,
                              currentUser: widget.currentUser,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Device Name:',
                                textScaleFactor: 1.5,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(deviceName),
                              const SizedBox(height: 16.0),
                              const Text(
                                'Location:',
                                textScaleFactor: 1.5,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(location),
                              // You can add additional information or details if needed
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
      ),
          ],
      )
    );
  }
}


class Filter extends StatefulWidget {
  final String user;
  Filter({super.key, required this.user});

  @override
  State<Filter> createState() => _FilterState();
}
enum SingingCharacter { first, second, third}

class _FilterState extends State<Filter> {
  String _country='Country';
  String _state='State';
  String _district='District';
  SingingCharacter? _character = SingingCharacter.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Locker'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(_country),
              items: <String>['India'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (val) {
                setState(
                      () {
                    _country = val!;
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: DropdownButton<String>(
              isExpanded:true,
              hint: Text(_state),
              items: <String>['Kerala'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (val) {
                setState(
                      () {
                    _state = val!;
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(_district),
              items: <String>['Kannur','Calicut'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (val) {
                setState(
                      () {
                    _district = val!;
                  },
                );
              },
            ),
          ),
          ElevatedButton(
              onPressed: (){
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Availability(
                      currentUser: widget.user, country: _country, state: _state, district: _district
                    ),
                  ),
                );
              },
              child: const Text('Search'),
          ),
          const SizedBox(height: 60),
          Column(
            children: <Widget>[
              ListTile(
                title: const Text('Near 200m'),
                leading: Radio<SingingCharacter>(
                  value: SingingCharacter.first,
                  groupValue: _character,
                  onChanged: (SingingCharacter? value) {
                    setState(() {
                      _character = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Near 500m'),
                leading: Radio<SingingCharacter>(
                  value: SingingCharacter.second,
                  groupValue: _character,
                  onChanged: (SingingCharacter? value) {
                    setState(() {
                      _character = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Near 1Km'),
                leading: Radio<SingingCharacter>(
                  value: SingingCharacter.third,
                  groupValue: _character,
                  onChanged: (SingingCharacter? value) {
                    setState(() {
                      _character = value;
                    });
                  },
                ),
              ),
              //TODO: filter
              ElevatedButton(
                onPressed: (){},
                child: const Text('Filter'),
              )
            ],
          ),
        ],
      ),
    );
  }
}


class AnotherPage extends StatelessWidget {
  final String deviceName;
  final String location;
  final String currentUser;

  const AnotherPage({super.key, required this.deviceName, required this.location, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(deviceName),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(currentUser),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 160),
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(25),
                    child: ElevatedButton(onPressed: (){
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context)=>MyMap(device:deviceName),
                        ),
                      );
                    }, child: const Text('Location'),),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(25),
                    child: ElevatedButton(onPressed: () async {
                      await supabase
                          .from('DeviceStatus')
                          .update({ 'current_user': currentUser,'availability':0})
                          .match({ 'device': deviceName });
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context)=>SubscriptionPage(name: deviceName,user: currentUser),
                        ),
                      );
                    },
                      child: const Text('Subscribe'),),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Text('**Usage Rate: Rs.10/- per hour'),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
