#pragma once

#ifdef __cplusplus
extern "C" {
#endif

// 导出符号声明
#ifdef __APPLE__
    #define RIFE_API __attribute__((visibility("default")))
#else
    #define RIFE_API
#endif

// 前向声明
typedef struct RifeProcessor RifeProcessor;

// 接口函数声明
RIFE_API RifeProcessor* createProcessor();
RIFE_API void destroyProcessor(RifeProcessor* processor);
RIFE_API int processFrames(RifeProcessor* processor,
                          const unsigned char* in0Data,
                          const unsigned char* in1Data,
                          float timestep,
                          unsigned char* outData);
RIFE_API void setFrameSize(RifeProcessor* processor, int width, int height);

#ifdef __cplusplus
}
#endif