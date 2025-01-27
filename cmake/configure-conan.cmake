function(_SET_CONANOPT OUT_VAR OPT_NAME OPT_VALUE)
    if (${OPT_VALUE})
        set(PY_OPT_VALUE "True")
    else ()
        set(PY_OPT_VALUE "False")
    endif ()
    set(${OUT_VAR} "${${OUT_VAR}};${OPT_NAME}=${PY_OPT_VALUE}" PARENT_SCOPE)
endfunction()

function(_SET_CONANSETTING OUT_VAR SET_NAME SET_VALUE)
    set(${OUT_VAR} "${${OUT_VAR}};${SET_NAME}=${SET_VALUE}" PARENT_SCOPE)
endfunction()

_SET_CONANOPT(CONAN_OPTS "tests" BUILD_TESTING)

if(NOT DEFINED CMAKE_CXX_STANDARD)
    if(MSVC)
        set(CMAKE_CXX_STANDARD 14)
    else()
        set(CMAKE_CXX_STANDARD 11)
    endif()
endif()

_SET_CONANSETTING(CONAN_SETTINGS "compiler.cppstd" ${CMAKE_CXX_STANDARD})
