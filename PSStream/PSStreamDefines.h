//
//  PSStreamDefines.h
//  PSStream
//
//  Created by PoiSon on 16/2/19.
//  Copyright © 2016年 PoiSon. All rights reserved.
//

#ifndef PSStreamDefines_h
#define PSStreamDefines_h

#if defined(__cplusplus)
#define PSSTREAM_EXTERN extern "C"
#else
#define PSSTREAM_EXTERN extern
#endif

#define PSSTREAM_EXTERN_STRING(KEY, COMMENT) PSSTREAM_EXTERN NSString * const _Nonnull KEY;
#define PSSTREAM_EXTERN_STRING_IMP(KEY) NSString * const KEY = @#KEY;
#define PSSTREAM_EXTERN_STRING_IMP2(KEY, VAL) NSString * const KEY = VAL;

#define PSSTREAM_ENUM_OPTION(ENUM, VAL, COMMENT) ENUM = VAL

#define PSSTREAM_API_UNAVAILABLE(INFO) __attribute__((unavailable(INFO)))

#endif /* PSStreamDefines_h */
