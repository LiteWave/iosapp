// AFNetworking.h
//


#import <Foundation/Foundation.h>
#import <Availability.h>

#ifndef _AFNETWORKING_
#define _AFNETWORKING_

#import "AFURLConnectionOperation.h"

#import "AFHTTPRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "AFXMLRequestOperation.h"
#import "AFPropertyListRequestOperation.h"
#import "AFHTTPClient.h"

#import "AFImageRequestOperation.h"
#import "AFImagecache.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED
#import "AFNetworkActivityIndicatorManager.h"
#import "UIImageView+AFNetworking.h"
#endif

#endif /* _AFNETWORKING_ */