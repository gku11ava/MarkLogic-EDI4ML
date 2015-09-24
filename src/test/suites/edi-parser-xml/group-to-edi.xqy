xquery version "1.0-ml";
(:~
 : Verifies that a functional group XML snippet and its children can be successfully converted into
 : an EDI delimited string.  This depends on the functions to convert transaction set snippets to an EDI string
 : and convert segment snippets into an EDI string.
 :)
import module namespace epx = "http://edi4ml/edi/parser/xml" at "/modules/edi-parser/edi-parser-xml.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import module namespace epc = "http://edi4ml/edi/parser/commons" at "/modules/edi-parser/edi-parser-commons.xqy";

declare namespace ex = "http://edi4ml/edi/xml#";

declare variable $EDI-XML := fn:doc("/test-data/sample999-specific.xml")/ex:edi-document;
declare variable $EDI-DOC := fn:string-join(
    fn:subsequence(fn:tokenize(fn:doc("/test-data/sample999.edi"), "~"), 2, 8), "~");


(: Convert functional group snippet to EDI :)
declare function local:main() {
    test:assert-equal($EDI-DOC, 
        epx:group-to-edi($EDI-XML/ex:interchanges/ex:interchange/ex:functional-groups/ex:functional-group,
            epc:build-delimiter-map(())))
};

local:main()