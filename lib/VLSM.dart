import 'package:flutter/material.dart';
import 'package:subneter/utils/subneter.dart';

class VLSMPage extends StatefulWidget {
  @override
  _VLSMPageState createState() => _VLSMPageState();
}

final networkHint = InputDecoration(
  hintText: "{#Hosts}x{#Networks} -> Ej. 120x2"
);

class _VLSMPageState extends State<VLSMPage> {

  TextEditingController _network = new TextEditingController();
  List<TextEditingController> _desiredNetworks = [TextEditingController()];
  List<Subnet> _results;
  bool _subneted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: this._setFAB(),
        body: (this._subneted)?this._createDisplaySubnets():this._createInputBody(),
    );
  }

  FloatingActionButton _setFAB(){
    return (this._subneted) ? 
      FloatingActionButton.extended(onPressed: () => this._goToMainScreen(), label: Text("Subnet Again"),icon: Icon(Icons.arrow_back)) : 
      FloatingActionButton.extended(onPressed: () => this._addDesiredNetwork(), label: Text("Add network"),icon: Icon(Icons.add));
  }

  void _addDesiredNetwork(){
    final newNetwork = new TextEditingController();
    this._desiredNetworks.add(newNetwork);
    setState(() {});
  }

  void _goToMainScreen(){
    this._results.clear();
    this._network.text = "";
    this._desiredNetworks.clear();
    this._desiredNetworks.add(new TextEditingController());
    this._subneted = false;
    setState(() {});
  }

  Widget _createInputBody(){
    return Center(
      child: Container(
        // height: MediaQuery.of(context).size.height*9/10,
        width: MediaQuery.of(context).size.width*4/5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("VLSM Generator",style: TextStyle(color: Colors.blue,fontSize: 120),textAlign: TextAlign.center,),
            TextField(
              controller: this._network,
              decoration: InputDecoration(hintText: "Network to Subnet  ->  Ej.  127.0.0.0"),
            ),
            Container(height: MediaQuery.of(context).size.height*2/5, child: this._createDesiredNetworks(),),
            RaisedButton(onPressed: () {
              this._results = subnet(this._network.text, this._desiredNetworks);
              setState(() {
                this._subneted = true;
              });
            },child: Text("Subnet!",style: TextStyle(color: Colors.white),), color: Colors.blue,)
          ],
        ),
      ),
    );
  }

  Widget _createDisplaySubnets(){
    if(this._results.isEmpty){
      return Center(child: Text("No Data"),);
    } 
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width*4/5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("VLSM Generator",style: TextStyle(color: Colors.blue,fontSize: 120),textAlign: TextAlign.center,),
            Text("The Subnets generated where the following",style: TextStyle(color: Colors.blue[300],fontSize: 35)),
            SizedBox(height : 30),
            Container(height: MediaQuery.of(context).size.height*2.2/3,
              child: ListView.builder(itemCount: this._results.length,
                itemBuilder: (BuildContext context,int index){
                  final net = this._results[index];
                  final netsToDisplay = Row(children: [
                    Text("Network: ${net.id}"),
                    Text("Hosts: ${net.firstHost} - ${net.lastHost}"),
                    Text("Broadcast: ${net.broadcast}")
                  ],mainAxisAlignment: MainAxisAlignment.spaceBetween,);
                  return new ListTile(
                    title: Container(
                      child: netsToDisplay                    
                    ),
                    enabled: false,
                    leading: Text("$index",style : TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.indigo[600])),
                    subtitle: Text("Mask is ${net.mask} and desired Hosts = ${net.desiredHosts}"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListView _createDesiredNetworks() {
    return ListView.builder(
      itemCount: this._desiredNetworks.length,
      itemBuilder: (BuildContext ctxt, int index) {
        return new ListTile(
          leading: Icon(Icons.network_wifi),
          title: TextField(controller: this._desiredNetworks[index],decoration: networkHint,),
          subtitle: Text("Write the number of desired Hosts."),
        );
      }
    );
  }
}