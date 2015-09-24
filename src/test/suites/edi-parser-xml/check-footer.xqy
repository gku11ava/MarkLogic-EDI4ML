xquery version "1.0-ml";
(:~
 : The check footer function is used to validate information in the interchange/functional-group/transaction set
 : footer segments (IEA, GE, SE).  These footers are matched to the corresponding headers by a control number and
 : includes a count of child elements depending on the segment type the count will be:
 :
 :  Interchange: Count of functional groups
 :  Functional Group : Count of transaction sets
 :  Transaction Set : Count of segments, including the transaction set header and footer segments.
 :)
import module namespace epx = "http://edi4ml/edi/parser/xml" at "/modules/edi-parser/edi-parser-xml.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

declare namespace ex = "http://edi4ml/edi/xml#";

(: Sample EDI document :)
declare variable $EDI-SEGMENTS := fn:tokenize(fn:doc("/test-data/sample999.edi"), "~");
(: Test scenarios for check footer 
 :   Check IEA footer
 :   Check GE footer
 :   Check SE footer
 :   Check handling for segment identifier mismatch: Header = ST, Footer != SE
 :   Check handling for control number mismatch in header and footer
 :   Check handling for child count mismatch
 :   Check hadnling for child count and control number mismatch
 :   Check handling for segment, child count and control number mismatch
 :)
declare variable $TEST-CASES := fn:doc("/test-data/test-case-definitions.xml")/test-cases/test-case[./@test = "check-footer"];
(: Expected test scenario results :)
declare variable $TEST-RESULTS := fn:doc("/test-data/test-results.xml")/test-results/result[./test="check-footer"];
 
declare function local:main() {
    for $test in $TEST-CASES
    return local:run-test($test, $TEST-RESULTS[./case-id=$test/@id])
};

declare private function local:run-test($test-case as element(test-case), $test-results as element(result)) {
    let $footer-index := $test-case/footer-index/xs:int(.)
    let $results := epx:check-footer($footer-index, $EDI-SEGMENTS[$footer-index], $test-case/footer-identifier, 
        fn:tokenize($EDI-SEGMENTS[$test-case/header-index/xs:int(.)], "\*")[$test-case/control-number-index/xs:int(.)], 
        $test-case/group-count/xs:int(.), "*")
    return (
        test:assert-equal($test-results/next-index/xs:int(.), $results/next-index/xs:int(.)),
        test:assert-equal($test-results/warning-count/xs:int(.), fn:count($results//warning)),
        test:assert-equal($test-results/footer-text/xs:string(.), $results/ex:original-footer/fn:string(.))
    )
};

local:main()