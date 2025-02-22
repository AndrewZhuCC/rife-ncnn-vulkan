#include <cstdio>
#ifdef __APPLE__
#include <iostream>
#include "rife.h"
#include "net.h"

// Export symbols for dynamic library
#define EXPORT __attribute__((visibility("default")))

class RifeProcessor {
public:
    EXPORT RifeProcessor() {
        ncnn::create_gpu_instance();
        // 初始化RIFE,使用默认参数
        rife = new RIFE(0, false, false, false, 1, false, true);  // GPU ID=0
        rife->load("/Users/anzhi.zhu/Downloads/test-rife/rife-ncnn-vulkan-20221029-macos/rife-v4"); // 加载模型
    }
    
    EXPORT ~RifeProcessor() {
        if(rife) {
            delete rife;
            rife = nullptr;
        }
        ncnn::destroy_gpu_instance();
    }
    
    EXPORT int process(const unsigned char* in0Data, const unsigned char* in1Data,
                      float timestep, unsigned char* outData) {
        try {
            // 将输入数据转换为ncnn::Mat格式
            ncnn::Mat in0(width, height, (void*)in0Data, 3, 3);
            ncnn::Mat in1(width, height, (void*)in1Data, 3, 3); 
            ncnn::Mat out = ncnn::Mat(width, height, (size_t)3, 3);

            // 调用RIFE处理
            printf("Processing frames...\n");
            int ret = rife->process(in0, in1, timestep, out);
            printf("Processing done %d \n", ret);
            if(ret != 0) {
                return ret;
            }

            // 拷贝输出结果
            printf("before memcpy\n");
            memcpy(outData, out.data, width * height * 3);
            printf("after memcpy\n");
            return 0;
        }
        catch(const std::exception& e) {
            std::cerr << "Error: " << e.what() << std::endl;
            return -1;
        }
    }

    EXPORT void setSize(int w, int h) {
        width = w;
        height = h; 
    }

private:
    RIFE* rife = nullptr;
    int width = 0;
    int height = 0;
};

extern "C" {
    // C-style interface for easier FFI
    EXPORT RifeProcessor* createProcessor() {
        return new RifeProcessor();
    }

    EXPORT void destroyProcessor(RifeProcessor* processor) {
        delete processor;
    }
    
    EXPORT int processFrames(RifeProcessor* processor,
                           const unsigned char* in0Data,
                           const unsigned char* in1Data, 
                           float timestep,
                           unsigned char* outData) {
        return processor->process(in0Data, in1Data, timestep, outData);
    }

    EXPORT void setFrameSize(RifeProcessor* processor, int width, int height) {
        processor->setSize(width, height);
    }
}
#endif