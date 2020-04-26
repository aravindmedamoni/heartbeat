import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:heartbeat/model/sensorvalue.dart';
import 'package:heartbeat/views/chart.dart';
import 'package:wakelock/wakelock.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin{
  //boolean value for showing appropriate actions
  bool _toggled=false;
  //list for storing the image process values data
  List<SensorValue> _data = [];
  //camera controller
  CameraController _controller;
  //alpa value
  double _alpha = 0.3;
  //variable to tell when to process images
 bool _processing = false;
 int _bpm = 0;

 //adding enimations to the fevorite icon button
  AnimationController _animController;
  Animation<double> _animation;

 @override
  void initState() {
   _animController = AnimationController(vsync: this,duration: Duration(seconds: 2));
   _animation = Tween<double>(begin: 0,end: 1).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInCubic));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        title: Center(
          child: RichText(text: TextSpan(
            children: [
              TextSpan(text: 'Heart',style: TextStyle(color: Colors.black54,fontSize: 24,fontWeight: FontWeight.bold)),
              TextSpan(text: ' Beat',style: TextStyle(color: Colors.blue,fontSize: 20,fontWeight: FontWeight.bold))
            ],
          )),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.0,vertical: 10.0),
                    decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(16.0)
                    ),
                    child: _controller!=null ? ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                        child: CameraPreview(_controller)):Container(
                      decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          borderRadius: BorderRadius.circular(16.0)
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Tap the favorite button and put your finger on the camera to know your heartbeat',style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600
                          ),),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.0,vertical: 10.0),
                    decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        borderRadius: BorderRadius.circular(16.0)
                    ),
                    child: Center(child: Text((_bpm > 30 && _bpm < 150 ? _bpm.round().toString() : "--"),
                      style: TextStyle(fontSize: 32, color:Colors.white,fontWeight: FontWeight.bold),)),
                  ),
                ),
              ],
            )),
            Expanded(
              child: Center(
                child: IconButton(
                  icon: Icon(_toggled ? Icons.favorite : Icons.favorite_border),
                  color: Colors.red,
                  iconSize: (_animation.value*60)+80,
                  onPressed: () {
                    if (_toggled) {
                      _unToggle();
                    } else {
                      _toggle();
                    }
                  },
                ),
              ),
            ),
            Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16.0)
                ),
                child: Chart(_data),
              ),
            ))
          ],
        ),
      ),
    );
  }

  void _unToggle() {
    //clear the chart data
    _data.clear();
    _disposeController();
    Wakelock.disable();
    setState(() {
      _toggled = false;
      _processing=false;
    });
  }

  void _toggle() {

  _animation.addStatusListener((animationStatus){
    if(animationStatus == AnimationStatus.completed){
      _animController.reverse();
    }else if(animationStatus == AnimationStatus.dismissed){
      _animController.forward();
    }
  });
  _animController.forward();
    _data.clear();
    _initController().then((_){
      Wakelock.enable();
      setState(() {
        _toggled = true;
        _processing=false;
      });
      _updateBPM();
    });

  }

  Future<void> _initController() async {
    try {
      List _cameras = await availableCameras();
      _controller = CameraController(_cameras.first, ResolutionPreset.low);
      await _controller.initialize();
      Future.delayed(Duration(milliseconds: 500)).then((_){
        _controller.flash(true);
      });
      _controller.startImageStream((CameraImage image){
        if(!_processing){
          setState(() {
            _processing = true;
          });
          _scanImage(image);
        }
      });
    } catch (Exception) {
      print(Exception);
    }
  }

  _disposeController() {
    _controller.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _disposeController();
    _animController.dispose();
    super.dispose();
  }

  void _scanImage(CameraImage image) {
    double _avg = image.planes.first.bytes.reduce((value,element)=>value+element)/image.planes.first.bytes.length;
    if(_data.length>=50){
      _data.removeAt(0);
    }
    setState(() {
      _data.add(SensorValue(value: _avg, time: DateTime.now()));
    });
    Future.delayed(Duration(milliseconds: 1000 ~/ 30)).then((onValue) {
      setState(() {
        _processing = false;
      });
    });
  }

  void _updateBPM() async{
    List<SensorValue> _values;
    double _avg;
    int _n;
    double _m;
    double _threshold;
    double _bpm;
    int _counter;
    int _previous;
    while (_toggled) {
      _values = List.from(_data);
      _avg = 0;
      _n = _values.length;
      _m = 0;
      _values.forEach((SensorValue value) {
        _avg += value.value / _n;
        if (value.value > _m) _m = value.value;
      });
      _threshold = (_m + _avg) / 2;
      _bpm = 0;
      _counter = 0;
      _previous = 0;
      for (int i = 1; i < _n; i++) {
        if (_values[i - 1].value < _threshold &&
            _values[i].value > _threshold) {
          if (_previous != 0) {
            _counter++;
            _bpm +=
                60000 / (_values[i].time.millisecondsSinceEpoch - _previous);
          }
          _previous = _values[i].time.millisecondsSinceEpoch;
        }
      }
      if (_counter > 0) {
        _bpm = _bpm / _counter;
        setState(() {
          this._bpm = ((1 - _alpha) * _bpm + _alpha * _bpm).round();
        });
      }
      await Future.delayed(Duration(milliseconds: (1000 * 50 / 30).round()));
    }
  }
}
