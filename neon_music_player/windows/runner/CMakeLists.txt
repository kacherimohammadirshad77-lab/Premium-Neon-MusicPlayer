cmake_minimum_required(VERSION 3.14)

add_executable(${BINARY_NAME} WIN32
  "main.cpp"
  "flutter_window.cpp"
  "win32_window.cpp"
  "utils.cpp"
  "resources/app_icon.ico"
  "runner.exe.manifest"
  "Runner.rc"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
)

apply_standard_settings(${BINARY_NAME})
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION=\"1.0.0\"")
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_link_libraries(${BINARY_NAME} PRIVATE "dwmapi.lib")
add_dependencies(${BINARY_NAME} flutter_assemble)
