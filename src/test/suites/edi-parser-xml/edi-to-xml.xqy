xquery version "1.0-ml";
(:~
 :  Tests basic conversion of a sample EDI document into a generic XML format.
 :  This assumes that the segment-to-xml and string-to-xml functions are working correctly, but
 :  does replicate some of the segment and string conversion functions.
 :
 :  If all checks pass, the code is able to succesfully build a generic xml document that
 :  contains the delimiters used in the EDI document and correctly parse the document into
 :  its individual segments, fields and repeating elements and provide accurate counts
 :  for each of the components.
 :)
import module namespace epx = "http://edi4ml/edi/parser/xml" at "/modules/edi-parser/edi-parser-xml.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

declare namespace ex = "http://edi4ml/edi/xml#";

declare variable $EDI-DOC := fn:doc("/test-data/sample999.edi");
declare variable $GENERIC-XML := fn:doc("/test-data/sample999-generic.xml")/ex:edi-document;
declare variable $SPECIFIC-XML := fn:doc("/test-data/sample999-specific.xml")/ex:edi-document;

(: Parse the sample EDI document :)
declare function local:main() {
    local:check-generic-parsing(),
    local:check-special-parsing()
};

declare private function local:check-special-parsing() {
    let $xml := epx:edi-to-xml($EDI-DOC, (), (), (), (), fn:true())
    let $expected-doc := $SPECIFIC-XML
    return (
        local:check-delimiters($xml/ex:delimiters, $expected-doc/ex:delimiters),
        local:check-interchange($xml/ex:interchanges, $expected-doc/ex:interchanges)
    )
};

declare private function local:check-generic-parsing() {
    let $xml := epx:edi-to-xml($EDI-DOC, (), (), (), (), fn:false())
    let $expected-doc := $GENERIC-XML
    return (
        local:check-delimiters($xml/ex:delimiters, $expected-doc/ex:delimiters),
        local:check-segments($xml/ex:segments, $expected-doc/ex:segments)
    )
};

(: Check that the delimiters are correctly documented :)
declare private function local:check-delimiters($delimiters as element(ex:delimiters)?, $expected-delims as element(ex:delimiters)?) {
    test:assert-true((fn:exists($expected-delims) and fn:exists($delimiters)) or (fn:empty($expected-delims) and fn:empty($delimiters))),
    for $delimiter at $i in $expected-delims/ex:delimiter
    let $test-delim := $delimiters/ex:delimiter[$i]
    return (
        test:assert-equal($delimiter/@type, $test-delim/@type),
        test:assert-equal($delimiter/fn:string(.), $test-delim/fn:string(.))
    )
};

(: Check that the count of segments is correct and that each segment has been correctly parsed. 
 : This checks the segment index, set position (if included), segment identifier and segment fields
 : for each segment.
 :)
declare private function local:check-segments($segments as element(ex:segments)?, $expected-segments as element(ex:segments)?) {
    test:assert-equal($expected-segments/@ex:count/xs:int(.), $segments/@ex:count/xs:int(.)),
    for $segment at $i in $expected-segments/ex:segment
    let $test-segment := $segments/ex:segment[$i]
    return (
        test:assert-equal($segment/@ex:index/xs:int(.), $test-segment/@ex:index/xs:int(.)),
        test:assert-equal($segment/@ex:set-position, $test-segment/@ex:set-position),
        test:assert-equal($segment/ex:segment-identifier/fn:string(.), $test-segment/ex:segment-identifier/fn:string(.)),
        local:test-fields($segment/ex:fields, $expected-segments/ex:fields)
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
            if($field/ex:components) then local:test-components($test-field/ex:components, $field/ex:components)
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

declare private function local:check-interchange($result as element(ex:interchanges)?, $expected as element(ex:interchanges)?) {
    test:assert-equal($expected/@ex:count/xs:int(.), $result/@ex:count/xs:int(.)),
    for $interchange at $i in $expected/ex:interchange
    let $test-interchange := $result/ex:interchange[$i]
    return (
        test:assert-equal($interchange/@ex:start-index/xs:int(.), $test-interchange/@ex:start-index/xs:int(.)),
        test:assert-equal($interchange/@ex:end-index/xs:int(.), $test-interchange/@ex:end-index/xs:int(.)),
        test:assert-equal($interchange/ex:authorization/ex:qualifier/fn:string(.), $test-interchange/ex:authorization/ex:qualifier/fn:string(.)),
        test:assert-equal($interchange/ex:authorization/ex:information/fn:string(.), $test-interchange/ex:authorization/ex:information/fn:string(.)),
        test:assert-equal($interchange/ex:security/ex:qualifier/fn:string(.), $test-interchange/ex:security/ex:qualifier/fn:string(.)),
        test:assert-equal($interchange/ex:security/ex:information/fn:string(.), $test-interchange/ex:security/ex:information/fn:string(.)),
        test:assert-equal($interchange/ex:sender/ex:qualifier/fn:string(.), $test-interchange/ex:sender/ex:qualifier/fn:string(.)),
        test:assert-equal($interchange/ex:sender/ex:information/fn:string(.), $test-interchange/ex:sender/ex:information/fn:string(.)),
        test:assert-equal($interchange/ex:receiver/ex:qualifier/fn:string(.), $test-interchange/ex:receiver/ex:qualifier/fn:string(.)),
        test:assert-equal($interchange/ex:receiver/ex:information/fn:string(.), $test-interchange/ex:receiver/ex:information/fn:string(.)),
        test:assert-equal($interchange/ex:control-number/fn:string(.), $test-interchange/ex:control-number/fn:string(.)),
        test:assert-equal($interchange/ex:control-version/fn:string(.), $test-interchange/ex:control-version/fn:string(.)),
        test:assert-equal($interchange/ex:interchange-date/fn:string(.), $test-interchange/ex:interchange-date/fn:string(.)),
        test:assert-equal($interchange/ex:interchange-time/fn:string(.), $test-interchange/ex:interchange-time/fn:string(.)),
        test:assert-equal($interchange/ex:standard-identifier/fn:string(.), $test-interchange/ex:standard-identifier/fn:string(.)),
        test:assert-equal($interchange/ex:acknowledgement-required/fn:string(.), $test-interchange/ex:acknowledgement-required/fn:string(.)),
        test:assert-equal($interchange/ex:usage-indicator/fn:string(.), $test-interchange/ex:usage-indicator/fn:string(.)),
        test:assert-equal($interchange/ex:component-separator/fn:string(.), $test-interchange/ex:component-separator/fn:string(.)),
        local:check-groups($test-interchange/ex:functional-groups, $interchange/ex:functional-groups)
    )
};

declare private function local:check-groups($result as element(ex:functional-groups)?, $expected as element(ex:functional-groups)?) {
    test:assert-equal($expected/@ex:count/xs:int(.), $result/@ex:count/xs:int(.)),
    for $group at $i in $expected/ex:functional-group
    let $test-group := $result/ex:functional-group[$i]
    return (
        test:assert-equal($group/@ex:start-index/xs:int(.), $test-group/@ex:start-index/xs:int(.)),
        test:assert-equal($group/@ex:end-index/xs:int(.), $test-group/@ex:end-index/xs:int(.)),
        test:assert-equal($group/ex:control-number/fn:string(.), $test-group/ex:control-number/fn:string(.)),
        test:assert-equal($group/ex:functional-code/fn:string(.), $test-group/ex:functional-code/fn:string(.)),
        test:assert-equal($group/ex:application-sender/fn:string(.), $test-group/ex:application-sender/fn:string(.)),
        test:assert-equal($group/ex:application-receiver/fn:string(.), $test-group/ex:application-receiver/fn:string(.)),
        test:assert-equal($group/ex:date-format/fn:string(.), $test-group/ex:date-format/fn:string(.)),
        test:assert-equal($group/ex:time-format/fn:string(.), $test-group/ex:time-format/fn:string(.)),
        test:assert-equal($group/ex:responsible-agency/fn:string(.), $test-group/ex:responsible-agency/fn:string(.)),
        test:assert-equal($group/ex:document-identifier/fn:string(.), $test-group/ex:document-identifier/fn:string(.)),
        local:check-sets($test-group/ex:transaction-sets, $group/ex:transaction-sets)
    )
};

declare private function local:check-sets($result as element(ex:transaction-sets)?, $expected as element(ex:transaction-sets)?) {
    test:assert-equal($expected/@ex:count/xs:int(.), $result/@ex:count/xs:int(.)),
    for $set at $i in $expected/ex:transaction-set
    let $test-set := $result/ex:transaction-set[$i]
    return (
        test:assert-equal($set/@ex:start-index/xs:int(.), $test-set/@ex:start-index/xs:int(.)),
        test:assert-equal($set/@ex:end-index/xs:int(.), $test-set/@ex:end-index/xs:int(.)),
        test:assert-equal($set/ex:id/fn:string(.), $test-set/ex:id/fn:string(.)),
        test:assert-equal($set/ex:control-number/fn:string(.), $test-set/ex:control-number/fn:string(.)),
        test:assert-equal($set/ex:document-identifier/fn:string(.), $test-set/ex:document-identifier/fn:string(.)),
        local:check-segments($test-set/ex:segments, $set/ex:segments)
    )
};

local:main()