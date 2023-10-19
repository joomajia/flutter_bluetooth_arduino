import 'package:flutter/material.dart';
import 'package:bluet_app/HomePage.dart';
import 'package:bluet_app/provider/StatusConexaoProvider.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? Title;
  final bool? isBluetooth;
  final bool? isDiscovering;
  final Function? onPress;

  const CustomAppBar({
    Key? key,
    @required this.Title,
    this.isBluetooth,
    this.isDiscovering,
    this.onPress,
  }) : super(key: key);
  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    DisconnectarBluetooth() {
      Provider.of<StatusConexaoProvider>(context, listen: false)
          .setDevice(null);
    }

    return AppBar(
      toolbarHeight: 100.0,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(5))),
      title: Center(
          child: Row(
        children: [
          Text(Title!, textAlign: TextAlign.center),
        ],
      )),
      backgroundColor: const Color.fromRGBO(237, 46, 39, 1),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: SizedBox(
            height: 60,
            width: 60,
            child: Consumer<StatusConexaoProvider>(
                builder: (context, StatusConnectionProvider, widget) {
              return (isBluetooth!
                  ? ElevatedButton(
                      onPressed: StatusConnectionProvider.device != null
                          ? () {
                              Provider.of<StatusConexaoProvider>(context,
                                      listen: false)
                                  .setDevice(null);
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      settings: const RouteSettings(name: '/'),
                                      builder: (context) =>
                                          const HomePage())); // push it back in
                            }
                          : onPress!(),
                      style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(), backgroundColor: StatusConnectionProvider.device != null
                              ? const Color.fromRGBO(15, 171, 118, 1)
                              : Colors.black),
                      child: Icon(StatusConnectionProvider.device != null
                          ? Icons.bluetooth_connected
                          : Icons.bluetooth_disabled),
                    )
                  : const SizedBox.shrink());
            }),
          ),
        )
      ],
    );
  }
}
