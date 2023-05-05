

@echo off
echo ======================

set "protocpath=%~dp0.\protoc-22.3-win64\bin\protoc.exe"
echo protocpath=%protocpath%

set "dartoutpath=%~dp0.\mobile\lib\generated"
echo dartoutpath=%dartoutpath%

%protocpath% --proto_path=./pc ^
             --go_out=./pc --go_opt=paths=source_relative ^
             --go-grpc_out=./pc --go-grpc_opt=paths=source_relative ^
             --dart_out=grpc:%dartoutpath% ^
             helloworld/helloworld.proto

rem robocopy . %dartoutpath% *.dart

echo ======================
