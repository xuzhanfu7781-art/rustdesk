import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/models/peer_model.dart';
import 'package:get/get.dart';
import 'package:flutter_hbb/utils/http_service.dart';

class CustomHostGroup {
  final String site;
  final List<Peer> hosts;

  CustomHostGroup({required this.site, required this.hosts});

  factory CustomHostGroup.fromJson(Map<String, dynamic> json) {
    var list = json['hosts'] as List;
    List<Peer> hosts = list.map((i) => Peer.fromJson(i)).toList();
    return CustomHostGroup(site: json['site'] ?? '', hosts: hosts);
  }
}

class CustomHostModel extends GetxController {
  final RxList<CustomHostGroup> groups = <CustomHostGroup>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  CustomHostModel() {
    fetch();
  }

  Future<void> fetch() async {
    final url = bind.mainGetLocalOption(key: 'custom-host-list-url');
    final token = bind.mainGetLocalOption(key: 'custom-host-list-token');
    if (url.isEmpty) {
      groups.clear();
      return;
    }

    isLoading.value = true;
    error.value = '';
    try {
      final response = await HttpService().sendRequest(
        Uri.parse(url),
        HttpMethod.get,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        groups.value = data.map((i) => CustomHostGroup.fromJson(i)).toList();
      } else {
        error.value = 'HTTP Error ${response.statusCode}';
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
