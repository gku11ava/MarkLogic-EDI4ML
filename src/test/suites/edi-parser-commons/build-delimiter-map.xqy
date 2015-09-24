xquery version "1.0-ml";
(:~
 : Tests the build-delimiter-map functions from the edi-parser-commons library.
 : These functions are used to build a map that stores the specified delimiter values
 : used in the EDI document to separate segments, fields and repeating sections (components/sub-components).
 :
 : This map is then used to support parsing of an EDI document into XML or building an EDI document from 
 : the generic XML.
 :
 : Two versions of this function exist.  The first provides the ability to specify each of the 4 possible delimiters as 
 : individual parameters while the second provides the ability to build a map from an existing one.  Empty values or an
 : empty map are replaced with default values specified in the edi-parser-commons library.
 :)
import module namespace epc = "http://edi4ml/edi/parser/commons" at "/modules/edi-parser/edi-parser-commons.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

declare variable $ALTERNATE-DELIMITERS := ("!", ",", "@", "=");

declare function local:main() {
    (: Build Delimiter Map using default params :)
    local:build-delimiter-map((), (), (), ()),
    
    (: Build Delimiter Map overriding defaults :)
    local:build-delimiter-map($ALTERNATE-DELIMITERS[1], $ALTERNATE-DELIMITERS[2],
        $ALTERNATE-DELIMITERS[3], $ALTERNATE-DELIMITERS[4]),
        
    (: Build Delimiter Map from no map :)
    local:build-delimiter-map(()),
    
    (: Build Delimiter Map with empty map :)
    local:build-delimiter-map(map:map()),
    
    (: Build Delimiter Map with overriding map :) 
    local:build-delimiter-map(local:build-map($ALTERNATE-DELIMITERS[1], $ALTERNATE-DELIMITERS[2],
        $ALTERNATE-DELIMITERS[3], $ALTERNATE-DELIMITERS[4]))
};

declare private function local:build-delimiter-map($segment as xs:string?, $field as xs:string?, 
    $component as xs:string?, $subcomponent as xs:string?) {
    let $expected-results := local:get-expected-values($segment, $field, $component, $subcomponent)
    let $map := epc:build-delimiter-map($segment, $field, $component, $subcomponent)
    return (
        test:assert-equal($expected-results[1], map:get($map, $epc:KEY-SEGMENT-DELIMITER)),
        test:assert-equal($expected-results[2], map:get($map, $epc:KEY-FIELD-DELIMITER)),
        test:assert-equal($expected-results[3], map:get($map, $epc:KEY-COMPONENT-DELIMITER)),
        test:assert-equal($expected-results[4], map:get($map, $epc:KEY-SUBCOMPONENT-DELIMITER))
    )
};

declare private function local:build-delimiter-map($map as map:map?) {
    let $expected-results := 
        if(fn:exists($map)) then  
            local:get-expected-values(map:get($map, $epc:KEY-SEGMENT-DELIMITER), map:get($map, $epc:KEY-FIELD-DELIMITER),
                map:get($map, $epc:KEY-COMPONENT-DELIMITER), map:get($map, $epc:KEY-SUBCOMPONENT-DELIMITER))
        else local:get-expected-values((), (), (), ())
    let $test-map := epc:build-delimiter-map($map)
    return (
        test:assert-equal($expected-results[1], map:get($test-map, $epc:KEY-SEGMENT-DELIMITER)),
        test:assert-equal($expected-results[2], map:get($test-map, $epc:KEY-FIELD-DELIMITER)),
        test:assert-equal($expected-results[3], map:get($test-map, $epc:KEY-COMPONENT-DELIMITER)),
        test:assert-equal($expected-results[4], map:get($test-map, $epc:KEY-SUBCOMPONENT-DELIMITER))
    )
};

declare private function local:get-expected-values($segment as xs:string?, $field as xs:string?,
    $component as xs:string?, $subcomponent as xs:string?) as xs:string* {
    if($segment) then $segment else $epc:SEGMENT-DELIMITER,
    if($field) then $field else $epc:FIELD-DELIMITER,
    if($component) then $component else $epc:COMPONENT-DELIMITER,
    if($subcomponent) then $subcomponent else $epc:SUBCOMPONENT-DELIMITER
};

declare private function local:build-map($segment as xs:string?, $field as xs:string?, 
    $component as xs:string?, $subcomponent as xs:string?) as map:map {
    let $map := map:map()
    let $_ := (
        if($segment) then map:put($map, $epc:KEY-SEGMENT-DELIMITER, $segment) else (),
        if($field) then map:put($map, $epc:KEY-FIELD-DELIMITER, $field) else (),
        if($component) then map:put($map, $epc:KEY-COMPONENT-DELIMITER, $component) else (),
        if($subcomponent) then map:put($map, $epc:KEY-SUBCOMPONENT-DELIMITER, $subcomponent) else ()
    )
    return $map
};

local:main()