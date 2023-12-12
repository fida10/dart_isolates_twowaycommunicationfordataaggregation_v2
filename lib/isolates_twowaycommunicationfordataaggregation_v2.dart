/// Support for doing something awesome.
///
/// More dartdocs go here.
library;

import 'dart:async';
import 'dart:isolate';

export 'src/isolates_twowaycommunicationfordataaggregation_v2_base.dart';

/*
Practice Question 3: Two-Way Communication for Data Aggregation

Task:

Implement a function aggregateDataInIsolate that takes numerical data 
and performs various aggregations (sum, average, max, min) 
in a separate isolate using two-way communication. 
The main isolate can send data along with the aggregation command.
 */

class DataAggregationMainIsolate {
  Isolate? worker;
  final receivedFromWorker = ReceivePort();
  SendPort? sendToWorker;
  Stream? resultsFromWorker;

  DataAggregationMainIsolate() {
    resultsFromWorker = receivedFromWorker.asBroadcastStream();
  }

  Future<dynamic> sendAndReceive(Map<String, dynamic> input) async {
    final completer = Completer();
    worker ??= await Isolate.spawn(
        aggregateDataInWorkerIsolate, receivedFromWorker.sendPort);

    if(sendToWorker != null) {
      sendToWorker?.send(input);
    }

    StreamSubscription? sub;
    sub = resultsFromWorker?.listen((event) {
      if (event is SendPort) {
        sendToWorker = event;
        sendToWorker?.send(input);
      }
      if (event is num) {
        completer.complete(event);
        sub?.cancel();
      }
    });

    return completer.future;
  }

  shutdown(){
    receivedFromWorker.close();
    worker?.kill;
    worker = null;
  }
}

Future<void> aggregateDataInWorkerIsolate(SendPort sendToMain) async {
  final receiveFromMain = ReceivePort();
  sendToMain.send(receiveFromMain.sendPort);

  receiveFromMain.listen((message) {
    if (message is Map<String, dynamic>) {
      final result = aggregateMultipleCommands(message);
      sendToMain.send(result);
    }
  });
}

aggregateMultipleCommands(Map<String, dynamic> input) {
  final command = input['command'];
  final data = (input['data'] as List);
  if (command == 'sum') {
    return data.fold(
        0, (previousValue, element) => previousValue + element as int);
  } else if (command == 'average') {
    return data.fold(
            0, (previousValue, element) => previousValue + element as int) /
        (input['data'] as List).length;
  } else if (command == 'max') {
    data.sort();
    return data.last;
  } else if (command == 'min') {
    data.sort();
    return data.first;
  }
}

Future<DataAggregationMainIsolate> setupDataAggregationIsolate() async {
  return DataAggregationMainIsolate();
}
