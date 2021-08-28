# Copyright 2019-2021 Canaan Inc.
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
# pylint: disable=invalid-name, unused-argument, import-outside-toplevel

from conans import ConanFile, CMake, tools


class caffeConan(ConanFile):
    settings = "os", "compiler", "build_type", "arch"
    generators = "cmake", "cmake_find_package", "cmake_paths"
    options = {
        "shared": [True, False],
        "fPIC": [True, False],
        "tests": [True, False]
    }
    default_options = {
        "shared": False,
        "fPIC": True,
        "tests": False
    }

    def requirements(self):
        self.requires('opencv/4.5.1')
        self.requires('boost/1.76.0')
        self.requires('hdf5/1.12.0')
        self.requires('lmdb/0.9.29')
        self.requires('leveldb/1.22')
        self.requires('glog/0.5.0')
        self.requires('gflags/2.2.2')
        self.requires('protobuf/3.17.1')

        if self.settings.os != 'Macos':
            self.requires('openblas/0.3.17')

        if self.options.tests:
            self.requires('gtest/1.10.0')

    def build_requirements(self):
        pass

    def configure(self):
        self.options["glog"].with_gflags = False
        self.options["opencv"].contrib = False
        self.options["opencv"].with_webp = False
        self.options["opencv"].with_openexr = False
        self.options["opencv"].with_eigen = False
        self.options["opencv"].with_quirc = False
        self.options["opencv"].dnn = False
        self.options["boost"].shared = False
        self.options["boost"].without_python = False
        if self.settings.os == 'Linux':
            self.options["opencv"].with_gtk = False
        if self.settings.os == 'Macos': # workaround for https://github.com/conan-io/conan-center-index/issues/4950
            self.options["boost"].numa = False

    def cmake_configure(self):
        cmake = CMake(self)
        cmake.configure()
        return cmake

    def build(self):
        cmake = self.cmake_configure()
        cmake.build()
