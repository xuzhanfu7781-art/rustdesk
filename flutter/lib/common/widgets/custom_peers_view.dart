import 'package:flutter/material.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/common/widgets/peer_card.dart';
import 'package:flutter_hbb/common/widgets/peers_view.dart';
import 'package:flutter_hbb/models/custom_host_model.dart';
import 'package:flutter_hbb/models/peer_tab_model.dart';
import 'package:get/get.dart';

class CustomPeersView extends StatelessWidget {
  final EdgeInsets? menuPadding;
  const CustomPeersView({Key? key, this.menuPadding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CustomHostModel model = Get.put(CustomHostModel());
    return Obx(() {
      if (model.isLoading.value && model.groups.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (model.error.value.isNotEmpty && model.groups.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(model.error.value),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: model.fetch,
                child: Text(translate('Retry')),
              ),
            ],
          ),
        );
      }
      if (model.groups.isEmpty) {
        return Center(child: Text(translate('Empty')));
      }

      return ListView.builder(
        itemCount: model.groups.length,
        itemBuilder: (context, index) {
          final group = model.groups[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  group.site,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              PeersView(
                peers: Peers(
                  name: 'custom',
                  getInitPeers: () => group.hosts.obs,
                  loadEvent: 'load_custom_peers',
                ),
                peerTabIndex: PeerTabIndex.custom,
                peerCardBuilder: (peer) => PeerCard(
                  peer: peer,
                  menuPadding: menuPadding,
                  onDoubleTap: () {
                    final password = bind.mainGetLocalOption(key: 'custom-host-list-password');
                    if (password.isNotEmpty) {
                      bind.setPeerPassword(id: peer.id, password: password);
                    }
                    connect(context, peer.id);
                  },
                ),
              ),
            ],
          );
        },
      );
    });
  }
}
