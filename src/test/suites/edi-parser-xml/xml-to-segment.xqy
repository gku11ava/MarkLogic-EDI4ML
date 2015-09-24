xquery version "1.0-ml";
(:~
 :  Tests conversion from the generic XML back to an EDI segment.  These tests depend on correct
 :  functioning of the xml-to-string function.  The segment-to-xml function is used to produce 
 :  a concatenated string with the appropriate delimiters for fields, components and sub-components
 :  that represents a segment within an EDI document
 :
 :  This tests building a segment string from a segment that contains text fields, empty fields and 
 :  fields with components.  Components will contain text values, empty components and sub-components.
 :  Sub-components will contain text values or be empty.
 :)
import module namespace epc = "http://edi4ml/edi/parser/commons" at "/modules/edi-parser/edi-parser-commons.xqy";
import module namespace epx = "http://edi4ml/edi/parser/xml" at "/modules/edi-parser/edi-parser-xml.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

declare namespace ex = "http://edi4ml/edi/xml#";

(: Delimiters used to build the EDI segment :)
declare variable $DELIMITERS := epc:build-delimiter-map((), (), (), ";");
(: Source file containing the segments used for testing 
 : Two scenarios are defined.
 :   Conversion of a segment XML snippet without the set-position attribute
 :   Conversion of a segment XML snippet with the set-position attribute
 :)
declare variable $TEST-FIELDS := fn:doc("/test-data/mock-edi-xml-segments.xml")/segments/sample[./@test = "xml-to-segment"];
(: File containing the expected EDI segment that will be produced 
 : The two scenarios above should produce the same output as the set-position attribute is only
 : used to help the data consumer parse/process the EDI content
 :)
declare variable $EXPECTED-RESULT := fn:doc("/test-data/mock-edi-segment.edi")/fn:string();


declare function local:main() {
    for $segment in $TEST-FIELDS
    return test:assert-equal($EXPECTED-RESULT, epx:xml-to-segment($segment/ex:segment, $DELIMITERS))
};

local:main()