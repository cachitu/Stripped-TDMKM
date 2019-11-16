//
//  TendermintSigner.h
//  TendermintSigner
//
//  Created by Calin Chitu on 14/11/2019.
//  Copyright © 2019 Calin Chitu. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for TendermintSigner.
FOUNDATION_EXPORT double TendermintSignerVersionNumber;

//! Project version string for TendermintSigner.
FOUNDATION_EXPORT const unsigned char TendermintSignerVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <TendermintSigner/PublicHeader.h>

#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif


#import "secp256k1.h"
#import "secp256k1_ecdh.h"
#import "secp256k1_recovery.h"

FOUNDATION_EXPORT double secp256k1VersionNumber;
FOUNDATION_EXPORT const unsigned char secp256k1VersionString[];
