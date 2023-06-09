///
//  Generated code. Do not modify.
//  source: helloworld/helloworld.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'helloworld.pb.dart' as $0;
export 'helloworld.pb.dart';

class GreeterClient extends $grpc.Client {
  static final _$sayHello = $grpc.ClientMethod<$0.HelloRequest, $0.HelloReply>(
      '/helloworld.Greeter/SayHello',
      ($0.HelloRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.HelloReply.fromBuffer(value));
  static final _$sayHelloAgain =
      $grpc.ClientMethod<$0.HelloRequest, $0.HelloReply>(
          '/helloworld.Greeter/SayHelloAgain',
          ($0.HelloRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.HelloReply.fromBuffer(value));
  static final _$getAllFiles = $grpc.ClientMethod<$0.Empty, $0.FilesReply>(
      '/helloworld.Greeter/GetAllFiles',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.FilesReply.fromBuffer(value));

  GreeterClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.HelloReply> sayHello($0.HelloRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$sayHello, request, options: options);
  }

  $grpc.ResponseFuture<$0.HelloReply> sayHelloAgain($0.HelloRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$sayHelloAgain, request, options: options);
  }

  $grpc.ResponseFuture<$0.FilesReply> getAllFiles($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getAllFiles, request, options: options);
  }
}

abstract class GreeterServiceBase extends $grpc.Service {
  $core.String get $name => 'helloworld.Greeter';

  GreeterServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.HelloRequest, $0.HelloReply>(
        'SayHello',
        sayHello_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.HelloRequest.fromBuffer(value),
        ($0.HelloReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.HelloRequest, $0.HelloReply>(
        'SayHelloAgain',
        sayHelloAgain_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.HelloRequest.fromBuffer(value),
        ($0.HelloReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.FilesReply>(
        'GetAllFiles',
        getAllFiles_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.FilesReply value) => value.writeToBuffer()));
  }

  $async.Future<$0.HelloReply> sayHello_Pre(
      $grpc.ServiceCall call, $async.Future<$0.HelloRequest> request) async {
    return sayHello(call, await request);
  }

  $async.Future<$0.HelloReply> sayHelloAgain_Pre(
      $grpc.ServiceCall call, $async.Future<$0.HelloRequest> request) async {
    return sayHelloAgain(call, await request);
  }

  $async.Future<$0.FilesReply> getAllFiles_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return getAllFiles(call, await request);
  }

  $async.Future<$0.HelloReply> sayHello(
      $grpc.ServiceCall call, $0.HelloRequest request);
  $async.Future<$0.HelloReply> sayHelloAgain(
      $grpc.ServiceCall call, $0.HelloRequest request);
  $async.Future<$0.FilesReply> getAllFiles(
      $grpc.ServiceCall call, $0.Empty request);
}
