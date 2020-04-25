
import 'package:flutter/material.dart';
import 'package:heartbeat/model/sensorvalue.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class Chart extends StatelessWidget {
  final List<SensorValue> _data;

  Chart(this._data);
  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart([
      charts.Series<SensorValue, DateTime>(
        id: 'Values',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (SensorValue values, _) => values.time,
        measureFn: (SensorValue values, _) => values.value,
        data: _data,
      )
    ],
        animate: false,
        primaryMeasureAxis: charts.NumericAxisSpec(
          tickProviderSpec:
          charts.BasicNumericTickProviderSpec(zeroBound: false),
          renderSpec: charts.NoneRenderSpec(),
        ),
        domainAxis: charts.DateTimeAxisSpec(
            renderSpec: charts.NoneRenderSpec()));
  }
}
