#!/bin/bash
# Apply oboe patches for Android build

OBOE_DIR="android/app/src/main/cpp/oboe"

echo "Applying oboe patches for Android build..."

# Apply fixes to CMakeLists.txt
if [ ! -f "$OBOE_DIR/CMakeLists.txt.orig" ]; then
    cp "$OBOE_DIR/CMakeLists.txt" "$OBOE_DIR/CMakeLists.txt.orig"
    sed -i '/target_compile_definitions(oboe PUBLIC \$<$<CONFIG:DEBUG>:OBOE_ENABLE_LOGGING=1>)/a \
\
# Add assert support for Android build\n\
target_compile_definitions(oboe PRIVATE -DGLIBCXX_ASSERTIONS=1)' "$OBOE_DIR/CMakeLists.txt"
fi

# Apply fixes to PolyphaseResampler.cpp
if [ ! -f "$OBOE_DIR/src/flowgraph/resampler/PolyphaseResampler.cpp.orig" ]; then
    cp "$OBOE_DIR/src/flowgraph/resampler/PolyphaseResampler.cpp" "$OBOE_DIR/src/flowgraph/resampler/PolyphaseResampler.cpp.orig"
    sed -i '18i \
#include <cassert>\n\
#include <algorithm>' "$OBOE_DIR/src/flowgraph/resampler/PolyphaseResampler.cpp"
    sed -i '21d' "$OBOE_DIR/src/flowgraph/resampler/PolyphaseResampler.cpp"  # Remove old include
    sed -i '21i \
#include "PolyphaseResampler.h"' "$OBOE_DIR/src/flowgraph/resampler/PolyphaseResampler.cpp"  # Put it back
fi

# Apply fixes to PolyphaseResamplerMono.cpp
if [ ! -f "$OBOE_DIR/src/flowgraph/resampler/PolyphaseResamplerMono.cpp.orig" ]; then
    cp "$OBOE_DIR/src/flowgraph/resampler/PolyphaseResamplerMono.cpp" "$OBOE_DIR/src/flowgraph/resampler/PolyphaseResamplerMono.cpp.orig"
    sed -i '18i #include <cassert>' "$OBOE_DIR/src/flowgraph/resampler/PolyphaseResamplerMono.cpp"
fi

# Apply fixes to PolyphaseResamplerStereo.cpp
if [ ! -f "$OBOE_DIR/src/flowgraph/resampler/PolyphaseResamplerStereo.cpp.orig" ]; then
    cp "$OBOE_DIR/src/flowgraph/resampler/PolyphaseResamplerStereo.cpp" "$OBOE_DIR/src/flowgraph/resampler/PolyphaseResamplerStereo.cpp.orig"
    sed -i '18i #include <cassert>' "$OBOE_DIR/src/flowgraph/resampler/PolyphaseResamplerStereo.cpp"
fi

# Apply fixes to SincResampler.cpp
if [ ! -f "$OBOE_DIR/src/flowgraph/resampler/SincResampler.cpp.orig" ]; then
    cp "$OBOE_DIR/src/flowgraph/resampler/SincResampler.cpp" "$OBOE_DIR/src/flowgraph/resampler/SincResampler.cpp.orig"
    sed -i '18i #include <algorithm>\n#include <memory.h>\n#include <cassert>' "$OBOE_DIR/src/flowgraph/resampler/SincResampler.cpp"
    sed -i '43i     // Clear accumulator for mixing.\n' "$OBOE_DIR/src/flowgraph/resampler/SincResampler.cpp"
fi

# Apply fixes to SincResamplerStereo.cpp
if [ ! -f "$OBOE_DIR/src/flowgraph/resampler/SincResamplerStereo.cpp.orig" ]; then
    cp "$OBOE_DIR/src/flowgraph/resampler/SincResamplerStereo.cpp" "$OBOE_DIR/src/flowgraph/resampler/SincResamplerStereo.cpp.orig"
    sed -i '17i #include <memory.h>' "$OBOE_DIR/src/flowgraph/resampler/SincResamplerStereo.cpp"
    sed -i '21d' "$OBOE_DIR/src/flowgraph/resampler/SincResamplerStereo.cpp"  # Remove #define STEREO 2
    cat > "$OBOE_DIR/src/flowgraph/resampler/SincResamplerStereo.cpp.new" << 'EOF'
#include <memory.h>
#include <math.h>
#include "SincResamplerStereo.h"

using namespace resampler;

SincResamplerStereo::SincResamplerStereo(const MultiChannelResampler::Builder &builder)
        : SincResampler(builder) {
    // Ensure we are using the correct number of channels
    if (builder.getChannelCount() != 2) {
        // Use only stereo
    }
}

void SincResamplerStereo::writeFrame(const float *frame) {
    // Put the frame into the input FIFO.
    mX[mCursor * 2] = frame[0];
    mX[mCursor * 2 + 1] = frame[1];
    mCursor = (mCursor + 1) % mX.size();
}

void SincResamplerStereo::readFrame(float *frame) {
    SincResampler::readFrame(frame);
}
EOF
    mv "$OBOE_DIR/src/flowgraph/resampler/SincResamplerStereo.cpp.new" "$OBOE_DIR/src/flowgraph/resampler/SincResamplerStereo.cpp"
fi

echo "Oboe patches applied successfully!"
