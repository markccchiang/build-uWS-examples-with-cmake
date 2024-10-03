macro(install_uWebSockets USOCKETS_VERSION UWEBSOCKETS_VERSION)
    # Avoid the warning about DOWNLOAD_EXTRACT_TIMESTAMP
    if (CMAKE_VERSION VERSION_GREATER_EQUAL "3.24.0")
        cmake_policy(SET CMP0135 NEW)
    endif ()

    # Check if build folder exists for uSocket and uWebsockets
    execute_process(
            COMMAND bash ./check_folders.sh uSockets uWebSockets
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/src
            OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    include(FetchContent)

    # Build uSockets
    set(USOCKETS_SOURCE_DIR ${CMAKE_SOURCE_DIR}/src/uSockets)

    FetchContent_Declare(
            uSockets-build
            URL https://github.com/uNetworking/uSockets/archive/refs/tags/v${USOCKETS_VERSION}.zip
            SOURCE_DIR ${USOCKETS_SOURCE_DIR}
    )

    FetchContent_GetProperties(uSockets-build)
    if (NOT uSockets-build_POPULATED)
        FetchContent_Populate(uSockets-build)
    endif ()

    include_directories(${USOCKETS_SOURCE_DIR}/src)

    aux_source_directory(${USOCKETS_SOURCE_DIR}/src USOCKETS_FILES)
    aux_source_directory(${USOCKETS_SOURCE_DIR}/src/crypto USOCKETS_CRYPTO_FILES)
    aux_source_directory(${USOCKETS_SOURCE_DIR}/src/eventing USOCKETS_EVENTING_FILES)

    # Set C std version and C_FLAGS
    set(CMAKE_C_STANDARD 11)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DLIBUS_NO_SSL -O3 -c")

    add_library(uSockets
            ${USOCKETS_FILES}
            ${USOCKETS_CRYPTO_FILES}
            ${USOCKETS_EVENTING_FILES})

    # Build uWebSockets
    set(UWEBSOCKETS_SOURCE_DIR ${CMAKE_SOURCE_DIR}/src/uWebSockets)

    FetchContent_Declare(
            uWebSockets-build
            URL https://github.com/uNetworking/uWebSockets/archive/refs/tags/v${UWEBSOCKETS_VERSION}.zip
            SOURCE_DIR ${UWEBSOCKETS_SOURCE_DIR}
    )

    FetchContent_GetProperties(uWebSockets-build)
    if (NOT uWebSockets-build_POPULATED)
        FetchContent_Populate(uWebSockets-build)
    endif ()

    include_directories(${UWEBSOCKETS_SOURCE_DIR}/src)
endmacro()
