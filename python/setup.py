#! /usr/bin/env python

from distutils.core import setup
import setuptools

try:
    from wheel.bdist_wheel import bdist_wheel as _bdist_wheel
    class bdist_wheel(_bdist_wheel):
        def finalize_options(self):
            _bdist_wheel.finalize_options(self)
            self.root_is_pure = False
except ImportError:
    bdist_wheel = None

setup(
    name='warpctc-caffe',
    version='1.0.0',
    description='warpctc-caffe',
    packages=setuptools.find_packages(exclude=[]),
    package_data={'caffe': ['_caffe.so']},
    cmdclass={'bdist_wheel': bdist_wheel}
)
