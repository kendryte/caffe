# These lists are later turned into target properties on main caffe library target
set(Caffe_LINKER_LIBS "")
set(Caffe_INCLUDE_DIRS "")
set(Caffe_DEFINITIONS "")
set(Caffe_COMPILE_OPTIONS "")

# ---[ Boost
find_package(Boost REQUIRED COMPONENTS)
list(APPEND Caffe_LINKER_LIBS PUBLIC Boost::Boost)

# ---[ Threads
find_package(Threads REQUIRED)
list(APPEND Caffe_LINKER_LIBS PRIVATE ${CMAKE_THREAD_LIBS_INIT})

# ---[ OpenMP
if(USE_OPENMP)
  # Ideally, this should be provided by the BLAS library IMPORTED target. However,
  # nobody does this, so we need to link to OpenMP explicitly and have the maintainer
  # to flick the switch manually as needed.
  #
  # Moreover, OpenMP package does not provide an IMPORTED target as well, and the
  # suggested way of linking to OpenMP is to append to CMAKE_{C,CXX}_FLAGS.
  # However, this naïve method will force any user of Caffe to add the same kludge
  # into their buildsystem again, so we put these options into per-target PUBLIC
  # compile options and link flags, so that they will be exported properly.
  find_package(OpenMP REQUIRED)
  list(APPEND Caffe_LINKER_LIBS PRIVATE ${OpenMP_CXX_FLAGS})
  list(APPEND Caffe_COMPILE_OPTIONS PRIVATE ${OpenMP_CXX_FLAGS})
endif()

# ---[ Google-glog
find_package(glog REQUIRED)
list(APPEND Caffe_LINKER_LIBS PUBLIC glog::glog)

# ---[ Google-gflags
find_package(gflags REQUIRED)
list(APPEND Caffe_LINKER_LIBS PUBLIC gflags::gflags)

# ---[ Google-protobuf
include(cmake/ProtoBuf.cmake)

# ---[ HDF5
find_package(HDF5 COMPONENTS HL REQUIRED)
list(APPEND Caffe_LINKER_LIBS PUBLIC HDF5::C HDF5::HL)
list(APPEND Caffe_DEFINITIONS PRIVATE -DUSE_HDF5)

# This code is taken from https://github.com/sh1r0/caffe-android-lib
#if(USE_HDF5)
#  find_package(HDF5 COMPONENTS HL REQUIRED)
#  include_directories(SYSTEM ${HDF5_INCLUDE_DIRS} ${HDF5_HL_INCLUDE_DIR})
#  list(APPEND Caffe_LINKER_LIBS ${HDF5_LIBRARIES} ${HDF5_HL_LIBRARIES})
#  add_definitions(-DUSE_HDF5)
#endif()

# ---[ LMDB
if(USE_LMDB)
  find_package(lmdb REQUIRED)
  list(APPEND Caffe_LINKER_LIBS PUBLIC lmdb::lmdb)
  list(APPEND Caffe_DEFINITIONS PUBLIC -DUSE_LMDB)
  if(ALLOW_LMDB_NOLOCK)
    list(APPEND Caffe_DEFINITIONS PRIVATE -DALLOW_LMDB_NOLOCK)
  endif()
endif()

# ---[ LevelDB
if(USE_LEVELDB)
  find_package(leveldb REQUIRED)
  list(APPEND Caffe_LINKER_LIBS PUBLIC leveldb::leveldb)
  list(APPEND Caffe_DEFINITIONS PUBLIC -DUSE_LEVELDB)
endif()

# ---[ Snappy
if(USE_LEVELDB)
  find_package(Snappy REQUIRED)
  list(APPEND Caffe_INCLUDE_DIRS PRIVATE ${Snappy_INCLUDE_DIR})
  list(APPEND Caffe_LINKER_LIBS PRIVATE ${Snappy_LIBRARIES})
endif()

# ---[ CUDA
include(cmake/Cuda.cmake)
if(NOT HAVE_CUDA)
  if(CPU_ONLY)
    message(STATUS "-- CUDA is disabled. Building without it...")
  else()
    message(WARNING "-- CUDA is not detected by cmake. Building without it...")
  endif()

  list(APPEND Caffe_DEFINITIONS PUBLIC -DCPU_ONLY)
endif()

if(USE_NCCL)
  find_package(NCCL REQUIRED)
  include_directories(SYSTEM ${NCCL_INCLUDE_DIR})
  list(APPEND Caffe_LINKER_LIBS ${NCCL_LIBRARIES})
  add_definitions(-DUSE_NCCL)
endif()

# ---[ OpenCV
if(USE_OPENCV)
  find_package(OpenCV QUIET COMPONENTS core highgui imgproc imgcodecs)
  if(NOT OpenCV_FOUND) # if not OpenCV 3.x, then imgcodecs are not found
    find_package(OpenCV REQUIRED COMPONENTS core highgui imgproc)
  endif()
  list(APPEND Caffe_LINKER_LIBS PUBLIC opencv::core opencv::highgui opencv::imgproc opencv::imgcodecs)
  message(STATUS "OpenCV found (${OpenCV_CONFIG_PATH})")
  list(APPEND Caffe_DEFINITIONS PUBLIC -DUSE_OPENCV)
endif()

# ---[ BLAS
if(NOT APPLE)
  set(BLAS "Open" CACHE STRING "Selected BLAS library")
  set_property(CACHE BLAS PROPERTY STRINGS "Atlas;Open;MKL")

  if(BLAS STREQUAL "Open" OR BLAS STREQUAL "open")
    set(BLA_VENDOR OpenBLAS)
  elseif(BLAS STREQUAL "MKL" OR BLAS STREQUAL "mkl")
    set(BLA_VENDOR Intel10_64lp)
    list(APPEND Caffe_DEFINITIONS PUBLIC -DUSE_MKL)
  endif()
elseif(APPLE)
  set(BLA_VENDOR Apple)
endif()

if(APPLE)
  if(NOT BLAS_LIBRARIES MATCHES "^/System/Library/Frameworks/vecLib.framework.*")
    list(APPEND Caffe_DEFINITIONS PUBLIC -DUSE_ACCELERATE)
  endif()
endif()

find_package(BLAS REQUIRED)
list(APPEND Caffe_LINKER_LIBS PRIVATE BLAS::BLAS)

# ---[ Python
find_package(Python3 COMPONENTS Interpreter Development NumPy REQUIRED)

if(BUILD_python)
 #if(NOT "${python_version}" VERSION_LESS "3")
 #  # use python3
 #  find_package(PythonInterp)
 #  find_package(PythonLibs)
 #  find_package(NumPy)
 #  # Find the matching boost python implementation
 #  set(version ${PYTHONLIBS_VERSION_STRING})

 #  STRING( REGEX REPLACE "[^0-9]" "" boost_py_version ${version} )
 #  find_package(Boost COMPONENTS "python-py${boost_py_version}")
 #  set(Boost_PYTHON_FOUND ${Boost_PYTHON-PY${boost_py_version}_FOUND})

 #  while(NOT "${version}" STREQUAL "" AND NOT Boost_PYTHON_FOUND)
 #    STRING( REGEX REPLACE "([0-9.]+).[0-9]+" "\\1" version ${version} )

 #    STRING( REGEX REPLACE "[^0-9]" "" boost_py_version ${version} )
 #    find_package(Boost COMPONENTS "python-py${boost_py_version}")
 #    set(Boost_PYTHON_FOUND ${Boost_PYTHON-PY${boost_py_version}_FOUND})

 #    STRING( REGEX MATCHALL "([0-9.]+).[0-9]+" has_more_version ${version} )
 #    if("${has_more_version}" STREQUAL "")
 #      break()
 #    endif()
 #  endwhile()
  set(HAVE_PYTHON TRUE)
  if(BUILD_python_layer)
    list(APPEND Caffe_DEFINITIONS PRIVATE -DWITH_PYTHON_LAYER)
    list(APPEND Caffe_LINKER_LIBS PRIVATE Python3::Module Python3::NumPy)
  endif()
endif()

# ---[ Matlab
if(BUILD_matlab)
  find_package(MatlabMex)
  if(MATLABMEX_FOUND)
    set(HAVE_MATLAB TRUE)
  endif()

  # sudo apt-get install liboctave-dev
  find_program(Octave_compiler NAMES mkoctfile DOC "Octave C++ compiler")

  if(HAVE_MATLAB AND Octave_compiler)
    set(Matlab_build_mex_using "Matlab" CACHE STRING "Select Matlab or Octave if both detected")
    set_property(CACHE Matlab_build_mex_using PROPERTY STRINGS "Matlab;Octave")
  endif()
endif()

# ---[ Doxygen
if(BUILD_docs)
  find_package(Doxygen)
endif()
