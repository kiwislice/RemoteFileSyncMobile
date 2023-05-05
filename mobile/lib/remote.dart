import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:grpc/grpc.dart';

import 'generated/helloworld/helloworld.pbgrpc.dart';

class RemoteGrpcServer {
  final String ip;
  final int port;

  const RemoteGrpcServer(this.ip, this.port);

  /// 取得遠端所有檔案路徑
  Future<List<String>> getRemoteFiles() async {
    final channel = _newClientChannel(ip, port);
    final greeterClient = GreeterClient(channel);

    try {
      final response = await greeterClient.getAllFiles(
        Empty(),
      );
      debugPrint('getRemoteFiles: ${response.files}');
      return response.files;
    } catch (e) {
      debugPrint('Caught error: $e');
      return [];
    } finally {
      await channel.shutdown();
    }
  }

  /// 取得遠端所有檔案路徑
  Future<String> sayHello(String name) async {
    final channel = _newClientChannel(ip, port);
    final greeterClient = GreeterClient(channel);

    try {
      final response = await greeterClient.sayHello(
        HelloRequest()..name = name,
      );
      debugPrint('sayHello: ${response.message}');
      return response.message;
    } catch (e) {
      debugPrint('Caught error: $e');
      return 'Caught error: $e';
    } finally {
      await channel.shutdown();
    }
  }
}

ClientChannel _newClientChannel(String ip, int port) {
  final channel = ClientChannel(
    ip,
    port: port,
    options: ChannelOptions(
      credentials: const ChannelCredentials.insecure(),
      codecRegistry:
          CodecRegistry(codecs: const [GzipCodec(), IdentityCodec()]),
    ),
  );
  return channel;
}
