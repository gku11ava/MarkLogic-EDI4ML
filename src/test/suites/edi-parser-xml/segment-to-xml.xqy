xquery version "1.0-ml";
(:~
 : Tests conversion of an EDI segment into XML.  The sample segment should contain multiple fields.
 : Some of the fields should be empty, some of the fields should contain repeating sections (components) and
 : the remainder should contain text.
 : Some of the components should be empty, some of the components should contain repeating sections (sub-components)
 : and the remainder should contain text.
 : Sub-components should either contain text or be empty.
 :
 : EDI segments can be parsed 2 different ways.  In the first case, the set-position attribute is not set.  This is
 : done as part of basic parsing without context and loops are not known.  In the second case, the set position
 : attribute is calculated using the segment index of the loop parent.  The position of the segment relative to
 : other segments in the document (segment index) and relative to other segments within the same loop (set position)
 : are then known.
 :
 : Successful execution of these tests depends on successful execution of the string-to-xml function tests.
 :)
import module namespace epc = "http://edi4ml/edi/parser/commons" at "/modules/edi-parser/edi-parser-commons.xqy";
import module namespace epx = "http://edi4ml/edi/parser/xml" at "/modules/edi-parser/edi-parser-xml.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

declare namespace ex = "http://edi4ml/edi/xml#";

(: File containing mock EDI segment to parse :)
declare variable $TEST-SEGMENT := fn:doc("/test-data/mock-edi-segment.edi")/text();
(: File containing expected test results for comparison :)
declare variable $TEST-RESULTS := fn:doc("/test-data/test-results.xml")/test-results/result[./test = "segment-to-xml"];

declare function local:main() {
    (: Test basic segment parsing :)
    local:parse-segment((), $TEST-SEGMENT, $TEST-RESULTS[./case-id = 1]/ex:segment),
    (: Test parsing with the set position attribute :)
    local:parse-segment(1, $TEST-SEGMENT, $TEST-RESULTS[./case-id = 2]/ex:segment)
};

declare private function local:parse-segment($parent-index as xs:int?, $segment-text as xs:string, $expected-results as element(ex:segment)) {
    let $segment := epx:segment-to-xml($parent-index, 2, $segment-text, epc:build-delimiter-map(()))
    return (
        test:assert-equal($expected-results/@ex:index/xs:int(.), $segment/@ex:index/xs:int(.)),
        test:assert-equal($expected-results/@ex:set-position, $segment/@ex:set-position),
        test:assert-equal($expected-results/ex:segment-identifier/fn:string(.), $segment/ex:segment-identifier/fn:string(.)),
        local:test-fields($segment/ex:fields, $expected-results/ex:fields)
    )
};

(: Check that the count of fields for a segment are correct and that each field is correctly parsed.
 : This checks the field index/position within the segment and the field value.  If the field is 
 : composed of repeating values, this will instead check the components
 :)
declare private function local:test-fields($fields as element(ex:fields), $expected-fields as element(ex:fields)) {
    if($expected-fields) then (
        test:assert-equal($expected-fields/@ex:count, $fields/@ex:count),
        for $field at $i in $expected-fields/ex:field
        let $test-field := $fields/ex:field[$i]
        return 
            if($field/ex:components) then local:test-components($test-field/ex:components, $expected-fields/ex:components)
            else (
                test:assert-equal($field/@ex:index/xs:int(.), $test-field/@ex:index/xs:int(.)),
                test:assert-equal($field/fn:string(.), $test-field/fn:string(.)
            )
            
        ) 
    )
    else ()
};

(: Check the count of components within a field are correct and that each component was correctly parsed.
 : This checks the component index/position within the field and the component value.  If the component is
 : composed of repeating values, this will check the sub-components.
 :)
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

(: Check the count of sub-components within a field are correct and that each sub-component was correctly parsed.
 : This checks the sub-component index/position within the field and the sub-component value.  
 :)
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