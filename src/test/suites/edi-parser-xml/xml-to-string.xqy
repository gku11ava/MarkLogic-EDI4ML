xquery version "1.0-ml";
(:~
 :  Tests conversion from the generic XML back to an EDI string.  The xml-to-string function 
 :  is used to produce the concatenated fields/components/sub-components for an EDI segment using
 :  the appropriate delimiter characters.
 :
 :  This tests building a simple text field, a field with components and a field with components and
 :  sub-components.
 :)
import module namespace epc = "http://edi4ml/edi/parser/commons" at "/modules/edi-parser/edi-parser-commons.xqy";
import module namespace epx = "http://edi4ml/edi/parser/xml" at "/modules/edi-parser/edi-parser-xml.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

declare namespace ex = "http://edi4ml/edi/xml#";

(: Delimiters to used in the tests :)
declare variable $DELIMITERS := epc:build-delimiter-map((), (), (), ";");
(: Sample file containing the ex:field elements used in the test :)
declare variable $TEST-FIELDS := fn:doc("/test-data/mock-edi-xml-segments.xml")/segments/sample[./@test = "xml-to-string"];
(: File containing the expected test results for each test :)
declare variable $TEST-RESULTS := <results>{fn:doc("/test-data/test-results.xml")/test-results/result[./test = "xml-to-string"]}</results>;


declare function local:main() {
    for $field in $TEST-FIELDS
    return test:assert-equal($TEST-RESULTS/result[./case-id = $field/@case-id]/string/fn:string(.), 
        epx:xml-to-string($field/ex:field, $DELIMITERS))
};

local:main()