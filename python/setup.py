#! /usr/bin/env python

from distutils.core import setup
import setuptools

setup(
    name='warpctc-caffe',
    version='1.0.0',
    description='warpctc-caffe',
    packages=setuptools.find_packages(exclude=[]),
    package_data={'caffe': ['_caffe.so']},
)

