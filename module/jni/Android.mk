LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := pixelify_next
LOCAL_SRC_FILES := spoofing.cpp
LOCAL_STATIC_LIBRARIES := libcxx
LOCAL_LDLIBS := -llog
DOBBY_SOURCES := $(wildcard $(LOCAL_PATH)/Dobby/source/*.cc)
DOBBY_UNIX_SOURCES := $(wildcard $(LOCAL_PATH)/Dobby/source/Unix/*.cc)

LOCAL_SRC_FILES += \
    $(DOBBY_SOURCES:$(LOCAL_PATH)/%=%) \
    $(DOBBY_UNIX_SOURCES:$(LOCAL_PATH)/%=%)
LOCAL_C_INCLUDES := \
    $(LOCAL_PATH) \
    $(LOCAL_PATH)/Dobby
    LOCAL_LDLIBS := -llog
LOCAL_CPPFLAGS := -std=c++17
include $(BUILD_SHARED_LIBRARY)

include jni/libcxx/Android.mk

# If you do not want to use libc++, link to system stdc++
# so that you can at least call the new operator in your code

# include $(CLEAR_VARS)
# LOCAL_MODULE := example
# LOCAL_SRC_FILES := example.cpp
# LOCAL_LDLIBS := -llog -lstdc++
# include $(BUILD_SHARED_LIBRARY)
