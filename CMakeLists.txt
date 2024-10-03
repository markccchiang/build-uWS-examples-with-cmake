cmake_minimum_required(VERSION 3.20)
project(build_uWS_examples_with_cmake)

# Set options
option(WITH_LTO "Use LTO" ON)
option(WITH_ZLIB "Use zlib" ON)
option(WITH_PROXY "Enables PROXY Protocol v2 support" ON)
option(WITH_OPENSSL "Enables OpenSSL 1.1+ support" ON)
option(WITH_LIBUV "Builds with libuv as event-loop" ON)
option(WITH_ASIO "Builds with ASIO as event-loop" ON)

# To do options
option(WITH_QUIC "Enables experimental Http3 examples" OFF)
option(WITH_BORINGSSL "Use boringssl over openssl" OFF)
option(WITH_WOLFSSL "Enables WolfSSL 4.2.0 support (mutually exclusive with OpenSSL)" OFF)
option(WITH_ASAN "Builds with sanitizers" OFF)

# Set CXX std version and CXX_FLAGS
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=native")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wpedantic -Wall -Wextra -Wsign-conversion -Wconversion")

if (WITH_LTO)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -flto")
endif ()

if (!WITH_ZLIB)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DUWS_NO_ZLIB")
else ()
    set(LINK_LIBS ${LINK_LIBS} z)
endif ()

if (WITH_PROXY)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DUWS_WITH_PROXY")
endif ()

# Link build-in headers and libraries (You may change it dependents on your system)
include_directories(/usr/local/include)
link_directories(/usr/local/lib)
link_directories(/opt/homebrew/lib)

# Download uWebSockets and uSockets source codes and build uSockets library
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR})
include(uWebSockets)
install_uWebSockets(0.8.8 20.67.0) # Input variables: uSockets and uWebSockets versions

# Copy example codes
file(COPY ${CMAKE_SOURCE_DIR}/src/uWebSockets/examples DESTINATION ${CMAKE_SOURCE_DIR})
file(GLOB example_files "${CMAKE_SOURCE_DIR}/examples/*.cpp")

# This example is problematic when compiling
list(REMOVE_ITEM example_files "${CMAKE_SOURCE_DIR}/examples/HelloWorldThreaded.cpp")

# These two examples are not included in the build of official examples
list(REMOVE_ITEM example_files "${CMAKE_SOURCE_DIR}/examples/HttpServer.cpp")
list(REMOVE_ITEM example_files "${CMAKE_SOURCE_DIR}/examples/SmokeTest.cpp")

# Link libraries
set(LINK_LIBS ${LINK_LIBS} uSockets)

if (WITH_OPENSSL)
    set(LINK_LIBS ${LINK_LIBS} ssl crypto)
endif ()

if (WITH_LIBUV)
    set(LINK_LIBS ${LINK_LIBS} uv)
endif ()

if (WITH_ASIO)
    find_package(Threads REQUIRED)
    set(LINK_LIBS ${LINK_LIBS} Threads::Threads)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread")
endif ()

# Build uWebSockets examples
foreach (example_file ${example_files})
    get_filename_component(filename ${example_file} NAME)
    string(REPLACE ".cpp" "" exec_file ${filename})
    add_executable(${exec_file} examples/${filename})
    target_link_libraries(${exec_file} ${LINK_LIBS})
endforeach ()
