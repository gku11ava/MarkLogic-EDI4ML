xquery version "1.0-ml";
(:~
 : Tests conversion of a EDI Fields, Components and Subcomponents into XML.  
 : This test executes the string-to-xml tests defined in the test-case-definitions.xml document.
 : Each test case runs against a field in the mock-edi-segment.edi document and the expected results 
 : are found in the test-results.xml document.
 :
 : The purpose of these tests are to check that the string-to-xml function can correctly parse a
 : field into the correct generic XML structure based upon the source data and the specified delimiters.
 :
 :)
import module namespace epc = "http://marklogic.com/edi/parser/commons" at "/modules/edi-parser/edi-parser-commons.xqy";
import module namespace epx = "http://marklogic.com/edi/parser/xml" at "/modules/edi-parser/edi-parser-xml.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

declare namespace ex = "http://marklogic.com/edi/xml#";

(: Source file containing test fields to parse :)
declare variable $TEST-FIELDS := fn:tokenize(fn:doc("/test-data/mock-edi-segment.edi")/text(), "\*");
(: Test cases defining the field and delimiters that will be used with each case :)
declare variable $TEST-CASES := fn:doc("/test-data/test-case-definitions.xml")/test-cases/test-case[./@test = "string-to-xml"];
(: Results document with the expected XML output for each test case :)
declare variable $TEST-RESULTS := <results>{fn:doc("/test-data/test-results.xml")/test-results/result[./test = "string-to-xml"]}</results>;

declare function local:main() {
    for $case in $TEST-CASES
    return local:string-to-xml($case)
};

declare private function local:string-to-xml($test-case as element(test-case)) {
    local:test-field(epx:string-to-xml(1, $TEST-FIELDS[$test-case/segment-index/xs:int(.)], $epc:TYPE-FIELD, 
        local:build-delimiter-map($test-case/delimiters)), $TEST-RESULTS/result[./case-id = $test-case/@id]/ex:field) 
};

declare private function local:build-delimiter-map($delimiters as xs:string?) as map:map {
    if($delimiters) then
        let $tokens := fn:tokenize($delimiters, ",")
        return epc:build-delimiter-map(
            if(fn:string-length($tokens[1]) > 0) then $tokens[1] else (),
            if(fn:string-length($tokens[2]) > 0) then $tokens[2] else (),
            if(fn:string-length($tokens[3]) > 0) then $tokens[3] else (),
            if(fn:string-length($tokens[4]) > 0) then $tokens[4] else ()
        )
    else epc:build-delimiter-map(())
};

declare private function local:test-field($result as element(ex:field), $expected as element(ex:field)) {
    test:assert-equal($expected/@ex:index/xs:int(.), 1),
    if($expected/ex:components) then
        local:test-components($result/ex:components, $expected/ex:components)
    else test:assert-equal($expected/fn:string(.), $result/fn:string(.))
};

declare private function local:test-components($result as element(ex:components), $expected as element(ex:components)) {
    test:assert-equal($expected/@ex:count/xs:int(.), fn:count($result/ex:component)),
    for $component at $i in $expected/ex:component
    let $test-component := $result/ex:component[$i]
    return
        if($component/ex:sub-components) then 
            local:test-subcomponents($test-component/ex:sub-components, $component/ex:sub-components)
        else (
            test:assert-equal($component/@ex:index/xs:int(.), $test-component/@ex:index/xs:int(.)),
            test:assert-equal($component/fn:string(.), $test-component/fn:string(.))
        )
};

declare private function local:test-subcomponents($result as element(ex:sub-components), $expected as element(ex:sub-components)) {
    test:assert-equal($expected/@ex:count/xs:int(.), fn:count($result/ex:sub-component)),
    for $sub-component at $i in $expected/ex:sub-component
    let $test-subcomponent := $result/ex:sub-component[$i]
    return (
        test:assert-equal($sub-component/@ex:index/xs:int(.), $test-subcomponent/@ex:index/xs:int(.)),
        test:assert-equal($sub-component/fn:string(.), $test-subcomponent/fn:string(.))
    )
};

local:main()