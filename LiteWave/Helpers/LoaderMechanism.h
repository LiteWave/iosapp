//
//  LoaderMechanism.h
//  Client
//


#import <Foundation/Foundation.h>

typedef enum {
    LoaderMechanismNone = 0,
    LoaderMechanismNSURLConnection = 1,
    LoaderMechanismASIHTTPRequest = 2,
    LoaderMechanismAFNetworking = 3,
    LoaderMechanismSOAP = 4
} LoaderMechanism;
