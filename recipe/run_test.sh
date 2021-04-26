#!/bin/bash
# *****************************************************************
# (C) Copyright IBM Corp. 2021. All Rights Reserved.
# (C) Copyright 2015-2021, conda-forge contributors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# *****************************************************************


set -ex

# Compile a trivial service definition to C++

protoc -I$RECIPE_DIR --plugin=protoc-gen-grpc=$PREFIX/bin/grpc_cpp_plugin --grpc_out=. hello.proto

test -f hello.grpc.pb.h
test -f hello.grpc.pb.cc

test -f $PREFIX/lib/libgrpc${SHLIB_EXT}
test -f $PREFIX/lib/libgrpc_unsecure${SHLIB_EXT}
test -f $PREFIX/lib/libgrpc++${SHLIB_EXT}
test -f $PREFIX/lib/libgrpc++_unsecure${SHLIB_EXT}
