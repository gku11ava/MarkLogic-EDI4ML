xquery version "1.0-ml";
(:~
 :  Tests conversion from the generic XML back to an EDI document.  These tests depend on correct
 :  functioning of the xml-to-string and xml-to-segment functions.  
 :
 :  The xml-to-edi function is used to produce a string of delimited values that represent an EDI
 :  document.
 :
 :  This tests building and concatening individual segments into a document.  Each segment string
 :  can contain multiple fields that may contain text, empty fields or components.  Components may
 :  contain text values, empty space or sub-components.  Sub-components may contain text values or
 :  empty space.
 :)
import module namespace epc = "http://marklogic.com/edi/parser/commons" at "/modules/edi-parser/edi-parser-commons.xqy";
import module namespace epx = "http://marklogic.com/edi/parser/xml" at "/modules/edi-parser/edi-parser-xml.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

declare namespace ex = "http://marklogic.com/edi/xml#";

declare function local:main() {
    let $text := fn:normalize-space(epx:xml-to-edi(fn:doc("/test-data/sample999-generic.xml")/ex:edi-document))
    let $expected-doc := fn:normalize-space(fn:doc("/test-data/sample999.edi"))
    return test:assert-equal($expected-doc, $text),
    
    let $text := fn:normalize-space(epx:xml-to-edi(fn:doc("/test-data/sample999-specific.xml")/ex:edi-document))
    let $expected-doc := fn:normalize-space(fn:doc("/test-data/sample999.edi"))
    return test:assert-equal($expected-doc, $text)
};

local:main()