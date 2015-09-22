xquery version "1.0-ml";
(:~
 : 
 :)
import module namespace epc = "http://marklogic.com/edi/parser/commons" at "/modules/edi-parser/edi-parser-commons.xqy";
import module namespace epx = "http://marklogic.com/edi/parser/xml" at "/modules/edi-parser/edi-parser-xml.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

declare namespace ex = "http://marklogic.com/edi/xml#";

declare variable $EDI-SEGMENTS := fn:tokenize(fn:doc("/test-data/sample999.edi"), "~");
declare variable $EDI-XML := fn:doc("/test-data/sample999-specific.xml")/ex:edi-document;
declare variable $TEST-CASES := fn:doc("/test-data/test-case-definitions.xml")/test-cases/test-case[./@test = "parse-header"];
(: Results document with the expected XML output for each test case :)
declare variable $TEST-RESULTS := <results>{fn:doc("/test-data/test-results.xml")/test-results/result[./test = "parse-header"]}</results>;

declare function local:main() {
    local:check-build-interchange(),
    local:check-build-group(),
    local:check-build-set(),
    for $test in $TEST-CASES 
    return local:check-parse-header($test)
};

declare private function local:check-build-interchange() {
    let $fields := fn:tokenize($EDI-SEGMENTS[1], "\*")
    let $results := epx:build-interchange($fields)
    return (
        test:assert-equal($fields[14], $results/ex:control-number/fn:string(.)),
        test:assert-equal($fields[13], $results/ex:control-version/fn:string(.)),
        test:assert-equal($fields[10], $results/ex:interchange-date/fn:string(.)),
        test:assert-equal($fields[11], $results/ex:interchange-time/fn:string(.)),
        test:assert-equal($fields[12], $results/ex:standard-identifier/fn:string(.)),
        test:assert-equal($fields[15], $results/ex:acknowledgement-required/fn:string(.)),
        test:assert-equal($fields[16], $results/ex:usage-indicator/fn:string(.)),
        test:assert-equal($fields[17], $results/ex:component-separator/fn:string(.)),
        test:assert-equal($fields[2], $results/ex:authorization/ex:qualifier/fn:string(.)),
        test:assert-equal($fields[3], $results/ex:authorization/ex:information/fn:string(.)),
        test:assert-equal($fields[4], $results/ex:security/ex:qualifier/fn:string(.)),
        test:assert-equal($fields[5], $results/ex:security/ex:information/fn:string(.)),
        test:assert-equal($fields[6], $results/ex:sender/ex:qualifier/fn:string(.)),
        test:assert-equal($fields[7], $results/ex:sender/ex:identifier/fn:string(.)),
        test:assert-equal($fields[8], $results/ex:receiver/ex:qualifier/fn:string(.)),
        test:assert-equal($fields[9], $results/ex:receiver/ex:identifier/fn:string(.))
    )
};

declare private function local:check-build-group() {
    let $fields := fn:tokenize($EDI-SEGMENTS[2], "\*")
    let $results := epx:build-group($fields)
    return (
        test:assert-equal($fields[7], $results/ex:control-number/fn:string(.)),
        test:assert-equal($fields[2], $results/ex:functional-code/fn:string(.)),
        test:assert-equal($fields[3], $results/ex:application-sender/fn:string(.)),
        test:assert-equal($fields[4], $results/ex:application-receiver/fn:string(.)),
        test:assert-equal($fields[5], $results/ex:date-format/fn:string(.)),
        test:assert-equal($fields[6], $results/ex:time-format/fn:string(.)),
        test:assert-equal($fields[8], $results/ex:responsible-agency-code/fn:string(.)),
        test:assert-equal($fields[9], $results/ex:document-identifier/fn:string(.))
    )
};

declare private function local:check-build-set() {
    let $fields := fn:tokenize($EDI-SEGMENTS[3], "\*")
    let $results := epx:build-transaction-set($fields)
    return (
        test:assert-equal($fields[2], $results/ex:id/fn:string(.)),
        test:assert-equal($fields[3], $results/ex:control-number/fn:string(.)),
        test:assert-equal($fields[4], $results/ex:document-identifier/fn:string(.))
    )
};

declare private function local:check-parse-header($test as element(test-case)) {
    let $results := epx:parse-header($test/start-index, $EDI-SEGMENTS, epc:build-delimiter-map(()))
    let $expected := $TEST-RESULTS/result[./case-id = $test/@id]
    return
        if(fn:count($results/ex:interchange) = 1) then 
            local:check-interchange($EDI-XML/ex:interchange, $results/ex:interchange)
        else if(fn:count($results/ex:functional-group) = 1) then 
            local:check-group($EDI-XML//ex:functional-group, $results/ex:functional-group)
        else if(fn:count($results/ex:transaction-set) = 1) then
            local:check-set($EDI-XML//ex:transaction-set, $results/ex:transaction-set) 
        else (
            test:assert-not-exists(($results/ex:interchange, $results/ex:functional-group, $results/ex:transaction-set)),
            test:assert-equal($expected/next-index, $results/next-index)
        )
};

declare private function local:check-interchange($expected as element(ex:interchange), $result as element(ex:interchange)?) {
    test:assert-equal($expected/@ex:start-index/xs:int(.), $result/@ex:start-index/xs:int(.)),
    test:assert-equal($expected/@ex:end-index/xs:int(.), $result/@ex:end-index/xs:int(.)),
    test:assert-equal($expected/ex:control-number, $result/ex:control-number),
    test:assert-equal($expected/ex:control-version, $result/ex:control-version),
    test:assert-equal($expected/ex:authorization/ex:qualifier, $result/ex:authorization/ex:qualifier),
    test:assert-equal($expected/ex:authorization/ex:information, $result/ex:authorization/ex:information),
    test:assert-equal($expected/ex:security/ex:qualifier, $result/ex:security/ex:qualifier),
    test:assert-equal($expected/ex:security/ex:information, $result/ex:security/ex:information),
    test:assert-equal($expected/ex:sender/ex:qualifier, $result/ex:sender/ex:qualifier),
    test:assert-equal($expected/ex:sender/ex:information, $result/ex:sender/ex:information),
    test:assert-equal($expected/ex:receiver/ex:qualifier, $result/ex:receiver/ex:qualifier),
    test:assert-equal($expected/ex:receiver/ex:information, $result/ex:receiver/ex:information),
    test:assert-equal($expected/ex:interchange-date, $result/ex:interchange-date),
    test:assert-equal($expected/ex:interchange-time, $result/ex:interchange-time),
    test:assert-equal($expected/ex:standard-identifier, $result/ex:standard-identifier),
    test:assert-equal($expected/ex:acknowledgement-required, $result/ex:acknowledgement-required),
    test:assert-equal($expected/ex:usage-indicator, $result/ex:usage-indicator),
    test:assert-equal($expected/ex:component-separator, $result/ex:component-separator),
    test:assert-equal($expected/ex:functional-groups/@ex:count/xs:int(.), $result/ex:functional-groups/@ex:count/xs:int(.)),
    for $group in $expected/ex:functional-groups/ex:group
    return local:check-group($group, $result/ex:functional-groups/ex:functional-group[./@ex:start-index = $group/@ex:start-index])
};

declare private function local:check-group($expected as element(ex:functional-group), $result as element(ex:functional-group)?) {
    test:assert-equal($expected/@ex:start-index/xs:int(.), $result/@ex:start-index/xs:int(.)),
    test:assert-equal($expected/@ex:end-index/xs:int(.), $result/@ex:end-index/xs:int(.)),
    test:assert-equal($expected/ex:control-number, $result/ex:control-number),
    test:assert-equal($expected/ex:functional-code, $result/ex:functional-code),
    test:assert-equal($expected/ex:application-sender, $result/ex:application-sender),
    test:assert-equal($expected/ex:application-receiver, $result/ex:application-receiver),
    test:assert-equal($expected/ex:date-format, $result/ex:date-format),
    test:assert-equal($expected/ex:time-format, $result/ex:time-format),
    test:assert-equal($expected/ex:responsible-agency-code, $result/ex:responsible-agency-code),
    test:assert-equal($expected/ex:document-identifier, $result/ex:document-identifier),
    test:assert-equal($expected/ex:transaction-sets/@ex:count/xs:int(.), $result/ex:transaction-sets/@ex:count/xs:int(.)),
    for $set in $expected/ex:transaction-sets/ex:transaction-set
    return local:check-set($set, $result/ex:transaction-sets/ex:transaction-set[./@ex:start-index = $set/@ex:start-index])
};

declare private function local:check-set($expected as element(ex:transaction-set), $result as element(ex:transaction-set)?) {
    test:assert-equal($expected/@ex:start-index/xs:int(.), $result/@ex:start-index/xs:int(.)),
    test:assert-equal($expected/@ex:end-index/xs:int(.), $result/@ex:end-index/xs:int(.)),
    test:assert-equal($expected/ex:control-number, $result/ex:control-number),
    test:assert-equal($expected/ex:id, $result/ex:id),
    test:assert-equal($expected/ex:document-identifier, $result/ex:document-identifier),
    test:assert-equal($expected/ex:segments/@ex:count/xs:int(.), $result/ex:segments/@ex:count/xs:int(.))
};

local:main()