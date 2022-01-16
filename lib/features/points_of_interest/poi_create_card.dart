import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:matchify/data/points_of_interest/model/point_of_interest.dart';
import 'package:matchify/data/points_of_interest/model/sports.dart';
import 'package:matchify/features/points_of_interest/poi_cubit.dart';

class PoiCreateCard extends StatefulWidget {
  final LatLng position;
  final Function()? onCancel;

  const PoiCreateCard({
    Key? key,
    required this.position,
    this.onCancel,
  }) : super(key: key);

  @override
  _PoiCreateCardState createState() => _PoiCreateCardState();
}

class _PoiCreateCardState extends State<PoiCreateCard> {
  final nameController = TextEditingController();
  List<bool> isSelected = [true, false, false];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Card(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Create place',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              const Divider(
                indent: 16,
                endIndent: 16,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ToggleButtons(
                  onPressed: (index) {
                    // Respond to button selection
                    setState(() {
                      for (int i = 0; i < isSelected.length; ++i) {
                        isSelected[i] = i == index;
                      }
                    });
                  },
                  children: const [
                    Icon(Icons.sports_soccer),
                    Icon(Icons.sports_basketball),
                    Icon(Icons.sports),
                  ],
                  isSelected: isSelected,
                ),
              ),
              ButtonBar(
                children: [
                  if (widget.onCancel != null)
                    TextButton(
                      child: const Text('CANCEL'),
                      onPressed: () {
                        widget.onCancel?.call();
                      },
                    ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _createPoi(context);
                    },
                    icon: const Icon(Icons.create),
                    label: const Text('CREATE'),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  void _createPoi(BuildContext context) async {
    final name = nameController.text;
    if (name.isEmpty) {
      return;
    }
    final sportIndex = isSelected.indexOf(true);
    final sport = Sports.values[sportIndex];

    final poi = PointOfInterest(
      id: '',
      name: name,
      latLng: widget.position,
      sport: sport,
    );

    final poiCubit = BlocProvider.of<PoiCubit>(context);
    await poiCubit.addPoi(poi);

    widget.onCancel?.call();
    poiCubit.reloadAll();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}
