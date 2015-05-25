//
//  DataFormat.h
//  Client
//


#import <Foundation/Foundation.h>

typedef enum {
    DeserializerTypeNone = 0,
    DeserializerTypeTouchJSON = 1,
    DeserializerTypeSBJSON = 2,
    DeserializerTypeJSONKit = 3,
    DeserializerTypeYAJL = 4,
    DeserializerTypeBSJSON = 5,
    DeserializerTypeNextiveJson = 6,
    DeserializerTypeNSJSONSerialization = 7,
    DeserializerTypeYAML = 8,
    DeserializerTypeBinaryPlist = 9,
    DeserializerTypeXMLPlist = 10,
    DeserializerTypeXMLFormattedPlist = 11,
    DeserializerTypeNSXMLParser = 12,
    DeserializerTypeTouchXML = 13,
    DeserializerTypeLibXMLDOM = 14,
    DeserializerTypeLibXMLSAX = 15,
    DeserializerTypeCSV = 16,
    DeserializerTypeTBXML = 17,
    DeserializerTypeKissXML = 18,
    DeserializerTypeTinyXML = 19,
    DeserializerTypeGoogleXML = 20,
    DeserializerTypeAPXML = 21,
    DeserializerTypeProtocolBuffer = 22,
    DeserializerTypeAQXMLParser = 23,
    DeserializerTypeSOAP = 24
} DeserializerType;
