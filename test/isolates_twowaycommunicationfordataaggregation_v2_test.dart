import 'package:isolates_twowaycommunicationfordataaggregation_v2/isolates_twowaycommunicationfordataaggregation_v2.dart';
import 'package:test/test.dart';

void main() {
  test(
      'aggregateDataInIsolate performs data aggregation with two-way communication',
      () async {
    var dataAggregationIsolate = await setupDataAggregationIsolate();

    expect(
        await dataAggregationIsolate.sendAndReceive({
          'command': 'sum',
          'data': [1, 2, 3, 4]
        }),
        equals(10));
    expect(
        await dataAggregationIsolate.sendAndReceive({
          'command': 'average',
          'data': [1, 2, 3, 4]
        }),
        equals(2.5));
    expect(
        await dataAggregationIsolate.sendAndReceive({
          'command': 'max',
          'data': [1, 2, 3, 4]
        }),
        equals(4));
    expect(
        await dataAggregationIsolate.sendAndReceive({
          'command': 'min',
          'data': [1, 2, 3, 4]
        }),
        equals(1));

    await dataAggregationIsolate.shutdown();
  });
}
