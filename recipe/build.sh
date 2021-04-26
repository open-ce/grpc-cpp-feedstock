#!/bin/bash
# *****************************************************************
# (C) Copyright IBM Corp. 2019, 2021. All Rights Reserved.
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

if [[ "${target_platform}" == osx* ]]; then
  export CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_CXX_STANDARD=14"
else
  export CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_CXX_STANDARD=17"
fi

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == 1 ]]; then

    mkdir -p build-host
    pushd build-host

    # Store original flags
    export CC_ORIG=$CC
    export CXX_ORIG=$CXX
    export LDFLAGS_ORIG=$LDFLAGS
    export CFLAGS_ORIG=$CFLAGS
    export CXXFLAGS_ORIG=$CXXFLAGS

    export CC=$CC_FOR_BUILD
    export CXX=$CXX_FOR_BUILD
    export LDFLAGS=${LDFLAGS//$PREFIX/$BUILD_PREFIX}

    # Unset them as we're ok with builds that are either slow or non-portable
    unset CFLAGS
    unset CXXFLAGS

    cmake ${CMAKE_ARGS} ..  \
          -GNinja \
          -DBUILD_SHARED_LIBS=OFF \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_PREFIX_PATH=$BUILD_PREFIX \
          -DCMAKE_INSTALL_PREFIX=$BUILD_PREFIX \
          -DgRPC_CARES_PROVIDER="package" \
          -DgRPC_GFLAGS_PROVIDER="package" \
          -DgRPC_PROTOBUF_PROVIDER="package" \
          -DProtobuf_ROOT=$BUILD_PREFIX \
          -DgRPC_SSL_PROVIDER="package" \
          -DgRPC_ZLIB_PROVIDER="package" \
          -DgRPC_ABSL_PROVIDER="package" \
          -DgRPC_RE2_PROVIDER="package" \
          -DProtobuf_PROTOC_EXECUTABLE=$BUILD_PREFIX/bin/protoc \
          -DgRPC_BUILD_CODEGEN=ON \
          -DgRPC_BUILD_CSHARP_EXT=OFF \
          -DgRPC_BUILD_GRPC_CSHARP_PLUGIN=OFF \
          -DgRPC_BUILD_GRPC_NODE_PLUGIN=OFF \
          -DgRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN=OFF \
          -DgRPC_BUILD_GRPC_PHP_PLUGIN=OFF \
          -DgRPC_BUILD_GRPC_PYTHON_PLUGIN=OFF \
          -DgRPC_BUILD_GRPC_RUBY_PLUGIN=OFF
    ninja grpc_cpp_plugin
    cp grpc_cpp_plugin $BUILD_PREFIX/bin/grpc_cpp_plugin

    # Restore original flags
    export CC=$CC_ORIG
    export CXX=$CXX_ORIG
    export LDFLAGS=$LDFLAGS_ORIG
    export CFLAGS=$CFLAGS_ORIG
    export CXXFLAGS=$CXXFLAGS_ORIG

    popd

fi

mkdir -p build-cpp
pushd build-cpp

cmake ${CMAKE_ARGS} ..  \
      -GNinja \
      -DBUILD_SHARED_LIBS=ON \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DgRPC_CARES_PROVIDER="package" \
      -DgRPC_GFLAGS_PROVIDER="package" \
      -DgRPC_PROTOBUF_PROVIDER="package" \
      -DProtobuf_ROOT=$PREFIX \
      -DgRPC_SSL_PROVIDER="package" \
      -DgRPC_ZLIB_PROVIDER="package" \
      -DgRPC_ABSL_PROVIDER="package" \
      -DgRPC_RE2_PROVIDER="package" \
      -DProtobuf_PROTOC_EXECUTABLE=$BUILD_PREFIX/bin/protoc

ninja install
popd
