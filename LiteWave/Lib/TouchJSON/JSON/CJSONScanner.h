//
//  CJSONScanner.h
//  Client
//


#import "CDataScanner.h"

/// CDataScanner subclass that understands JSON syntax natively. You should generally use CJSONDeserializer instead of this class. (TODO - this could have been a category?)
@interface CJSONScanner : CDataScanner {
}

- (BOOL)scanJSONObject:(id *)outObject error:(NSError **)outError;
- (BOOL)scanJSONDictionary:(NSDictionary **)outDictionary error:(NSError **)outError;
- (BOOL)scanJSONArray:(NSArray **)outArray error:(NSError **)outError;
- (BOOL)scanJSONStringConstant:(NSString **)outStringConstant error:(NSError **)outError;
- (BOOL)scanJSONNumberConstant:(NSNumber **)outNumberConstant error:(NSError **)outError;

@end

extern NSString *const kJSONScannerErrorDomain /* = @"CJSONScannerErrorDomain" */;
