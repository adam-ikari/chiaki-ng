
cmake_minimum_required(VERSION 3.2)

set(CMAKE_CXX_STANDARD 14)

add_library(chiaki-jni SHARED
        src/main/cpp/chiaki-jni.c
        src/main/cpp/log.h
        src/main/cpp/log.c
        src/main/cpp/video-decoder.h
        src/main/cpp/video-decoder.c
        src/main/cpp/audio-decoder.h
        src/main/cpp/audio-decoder.c
        src/main/cpp/audio-output.h
        src/main/cpp/audio-output.cpp
        src/main/cpp/circular-fifo.hpp)
target_link_libraries(chiaki-jni chiaki-lib)

find_library(ANDROID_LIB_LOG log)
find_library(ANDROID_LIB_MEDIANDK mediandk)
find_library(ANDROID_LIB_ANDROID android)
target_link_libraries(chiaki-jni "${ANDROID_LIB_LOG}" "${ANDROID_LIB_MEDIANDK}" "${ANDROID_LIB_ANDROID}")

add_subdirectory(src/main/cpp/oboe)
target_link_libraries(chiaki-jni oboe)
target_compile_definitions(oboe PRIVATE -D__STDC_VERSION__=201112L -D_GLIBCXX_USE_C99_ASSERT=1)
target_compile_options(oboe PRIVATE -Wno-error)
target_compile_definitions(oboe PRIVATE -DGLIBCXX_USE_C99=1)

# 设置环境变量以修复OpenSSL配置问题
set(ENV{ANDROID_NDK_ROOT} ${ANDROID_NDK})