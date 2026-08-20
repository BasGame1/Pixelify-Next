#include "errno.h"
#include "android/log.h"

#pragma once

#ifndef PIXELIFY_TAG
#define PIXELIFY_TAG "PixelifyNext"
#endif

#ifdef NDEBUG
#define LOGD(...)
#define LOGI(...)
#else
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, PIXELIFY_TAG, __VA_ARGS__)
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, PIXELIFY_TAG, __VA_ARGS__)
#endif

#define LOGW(...) __android_log_print(ANDROID_LOG_WARN, PIXELIFY_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, PIXELIFY_TAG, __VA_ARGS__)
