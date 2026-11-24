import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_admin/core/errors/failure.dart';
import 'package:aqd_admin/core/widgets/admin_data_table.dart';
import 'package:aqd_admin/core/widgets/confirm_dialog.dart';

import '../support/test_app.dart';

class Row1 {
  const Row1(this.id, this.name);
  final String id;
  final String name;
}

void main() {
  final rows = [const Row1('1', 'Ahmad'), const Row1('2', 'Layla')];

  Widget table({
    List<Row1>? data,
    Object? error,
    bool isLoading = false,
    Set<String> selected = const {},
    ValueChanged<Set<String>>? onSelect,
    ValueChanged<int>? onPage,
    void Function(String, {required bool ascending})? onSort,
    int page = 1,
    int total = 45,
  }) {
    return testApp(
      SingleChildScrollView(
        child: AdminDataTable<Row1>(
          columns: [
            AdminColumn<Row1>(label: 'Name', sortKey: 'name', cell: (r) => Text(r.name)),
          ],
          rows: data ?? rows,
          page: page,
          limit: 20,
          total: total,
          isLoading: isLoading,
          error: error,
          idOf: (r) => r.id,
          selectedIds: selected,
          onSelectionChanged: onSelect,
          bulkActions: [TextButton(onPressed: () {}, child: const Text('Suspend all'))],
          sortKey: 'name',
          ascending: true,
          onSort: onSort,
          onPageChanged: onPage ?? (_) {},
          onLimitChanged: (_) {},
          filters: const Text('FILTERS'),
        ),
      ),
    );
  }

  group('AdminDataTable', () {
    testWidgets('shows rows, filters, total and pager', (tester) async {
      await tester.pumpWidget(table());
      expect(find.text('Ahmad'), findsOneWidget);
      expect(find.text('FILTERS'), findsOneWidget);
      expect(find.text('Total: 45'), findsOneWidget);
      expect(find.text('Page 1 of 3'), findsOneWidget);
    });

    testWidgets('pager moves pages and is disabled at the ends', (tester) async {
      int? requested;
      await tester.pumpWidget(table(onPage: (p) => requested = p));
      await tester.tap(find.byTooltip('Next page'));
      expect(requested, 2);

      final previous = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.chevron_left));
      expect(previous.onPressed, isNull);
    });

    testWidgets('empty, loading and error states', (tester) async {
      await tester.pumpWidget(table(data: const [], total: 0));
      expect(find.text('No data'), findsOneWidget);

      await tester.pumpWidget(table(data: const [], isLoading: true));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpWidget(table(data: const [], error: const NetworkFailure()));
      expect(find.textContaining('Cannot reach the server'), findsOneWidget);
      expect(find.text('Try again'), findsNothing);
    });

    testWidgets('selecting rows reports ids; the bulk bar replaces the filters', (tester) async {
      Set<String> selected = {};
      await tester.pumpWidget(table(onSelect: (s) => selected = s));
      await tester.tap(find.byType(Checkbox).at(1));
      expect(selected, {'1'});

      await tester.pumpWidget(table(selected: {'1', '2'}, onSelect: (s) => selected = s));
      expect(find.text('2 selected'), findsOneWidget);
      expect(find.text('Suspend all'), findsOneWidget);
      expect(find.text('FILTERS'), findsNothing);

      await tester.tap(find.text('Clear selection'));
      expect(selected, isEmpty);
    });

    testWidgets('tapping a sortable header asks the server to sort', (tester) async {
      String? key;
      bool? asc;
      await tester.pumpWidget(table(onSort: (k, {required ascending}) {
        key = k;
        asc = ascending;
      }));
      await tester.tap(find.text('Name'));
      expect(key, 'name');
      expect(asc, isFalse);
    });
  });

  group('showConfirmDialog', () {
    Future<bool?> open(WidgetTester tester, {String? confirmWord}) async {
      bool? result;
      await tester.pumpWidget(testApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await showConfirmDialog(context, title: 'Suspend?', message: 'Sure?', destructive: true, confirmWord: confirmWord),
            child: const Text('open'),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('confirm returns true, cancel returns false', (tester) async {
      await open(tester);
      expect(find.text('Suspend?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Suspend?'), findsNothing);
    });

    testWidgets('a confirm word keeps the button disabled until typed', (tester) async {
      await open(tester, confirmWord: 'DELETE');
      FilledButton button() => tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Confirm'));
      expect(button().onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'delete');
      await tester.pump();
      expect(button().onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'DELETE');
      await tester.pump();
      expect(button().onPressed, isNotNull);
    });
  });
}
