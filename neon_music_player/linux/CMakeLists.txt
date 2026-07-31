cmake_minimum_required(VERSION 3.10)
project(runner LANGUAGES CXX)

set(BINARY_NAME "neon_music_player")
set(APPLICATION_ID "com.neonmusic.player")

cmake_policy(SET CMP0063 NEW)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Flutter build mode" FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Profile" "Release")
endif()

set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

function(APPLY_STANDARD_SETTINGS TARGET)
  target_compile_features(${TARGET} PUBLIC cxx_std_14)
  target_compile_options(${TARGET} PRIVATE -Wall -Werror)
  target_compile_options(${TARGET} PRIVATE "$<$<NOT:$<CONFIG:Debug>>:-O3>")
  target_compile_definitions(${TARGET} PRIVATE "$<$<NOT:$<CONFIG:Debug>>:NDEBUG>")
endfunction()

set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
add_subdirectory(${FLUTTER_MANAGED_DIR})

add_subdirectory("runner")

apply_standard_settings(${BINARY_NAME})

add_dependencies(${BINARY_NAME} flutter_assemble)

include(flutter/generated_plugins.cmake)

set(BUILD_BUNDLE_DIR "${PROJECT_BINARY_DIR}/bundle")
install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${BUILD_BUNDLE_DIR}"
  COMPONENT Runtime)
