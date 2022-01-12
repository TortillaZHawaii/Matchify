import 'package:flutter/material.dart';
import 'package:matchify/data/points_of_interest/poi_source.dart';

class PoiFilter extends StatefulWidget {
  final PoiLocationArgument argument;

  const PoiFilter({
    Key? key,
    required this.argument,
  }) : super(key: key);

  @override
  _PoiFilterState createState() => _PoiFilterState();
}

class _PoiFilterState extends State<PoiFilter> {
  // first is distance, second is name
  final _isSelectedOrderType = <bool>[false, false];

  @override
  void initState() {
    super.initState();
    _isSelectedOrderType[widget.argument.order.index] = true;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          ToggleButtons(
            isSelected: _isSelectedOrderType,
            children: const [
              Text('Distance'),
              Text('Name'),
            ],
            onPressed: (int index) {
              setState(() {
                for (int i = 0; i < _isSelectedOrderType.length; i++) {
                  _isSelectedOrderType[i] = false;
                }
                _isSelectedOrderType[index] = true;
              });
            },
          )
        ],
      ),
    );
  }
}
