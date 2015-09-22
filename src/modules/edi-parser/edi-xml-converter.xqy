xquery version "1.0-ml";
(: Convert from generic XML document to context specific XML --  This is still in Proof of Concept :)
module namespace exc = "http://marklogic.com/edi/parser/xml/converter";

import module namespace epc = "http://marklogic.com/edi/parser/commons" at "/modules/edi-parser/edi-parser-commons.xqy";

declare namespace em = "http://marklogic.com/edi/mapping";
declare namespace ex = "http://marklogic.com/edi/xml";

declare function exc:convert-edi-document($edi-document as element(ex:edi-document), $mapping as element(em:edi-mapping)) as element()* {
    if($edi-document/ex:interchanges) then
        for $interchange in $edi-document/ex:interchanges/ex:interchange
        return exc:convert-header($interchange, $mapping)
    else exc:convert-segment(1, $edi-document/ex:segments/ex:segment, $mapping, ())
};

declare function exc:convert-header($content as element(), $mapping as element(em:edi-mapping)) as element() {
    let $type := fn:local-name($content)
    let $type-mappings := $epc:HEADER-TYPE-DETAILS/header[./name = $type]
    let $content-fields := 
        for $child in $content/element()
        where fn:not(fn:local-name($child) = ("original-header", "original-footer", $type-mappings/children/fn:string(.)))
        return $child
    let $children :=
        if($type = "interchange") then $content/ex:functional-groups
        else if($type = "group") then $content/ex:transaction-sets
        else if($type = "transaction-set") then $content/ex:segments
        else fn:error(xs:QName("exc:TYPEUNKNOWN"), fn:concat("Unknown content type ", $type, ".  Expected interchange, group or transaction-set."))
    return
        element{fn:node-name($content)} {
            $content-fields,
            if($type = ("interchange", "group")) then
                element{fn:QName("http://marklogic.com/edi/xml", $type-mappings/children/fn:string(.))} {
                    attribute {xs:QName("count")} {$children/@count/fn:string(.)},
                    for $child in $children/element()
                    return exc:convert-header($child, $mapping)
                }
            else exc:convert-segment(1, $content/ex:segments/ex:segment, $mapping, ())
        }
    
};

declare function exc:convert-segment($segment-index as xs:int, $segments as element(ex:segment)*, $mapping as element(em:edi-mapping),
    $segment-mapping as element(em:segment)*) as element()* {
    let $current-segment := $segments[$segment-index]
    let $next-index := $segment-index + 1
    let $results := 
            if($current-segment) then
                let $current-mapping := if($segment-mapping) then $segment-mapping else
                    $mapping/em:segment[./em:identifier = $current-segment/ex:segment-identifier]
                let $segment :=
                    element { fn:QName($current-mapping/em:element/@namespace/fn:string(.), $current-mapping/em:element/@name/fn:string(.)) } {
                        for $field at $i in $current-segment/ex:fields/ex:field
                        order by $field/@index/xs:int(.) ascending
                        return exc:convert-content($i, $field, $current-mapping),
                        if($current-mapping/em:loop) then
                            let $results := exc:handle-loop($next-index, $segments, $mapping, $current-mapping)
                            let $_ := if($results/next-index castable as xs:int) then xdmp:set($next-index, $results/next-index/xs:int(.)) else ()
                            return $results/loop/*
                        else ()
                    }
                return (
                  $segment,
                  if(fn:empty($segment-mapping)) then exc:convert-segment($next-index, $segments, $mapping, ()) else ()
                )
        else ()
    return 
        if($segment-mapping) then
            <results>
                <converted-segment>{$results}</converted-segment>
                <next-index>{$next-index}</next-index>
            </results>
        else $results
};

declare function exc:convert-content($index as xs:int, $content as element(), $mapping as element()) as element() {
    let $type := fn:local-name($content)
    let $content-mapping := 
        if($type = "field") then $mapping/em:fields/em:field[./@index = $index]
        else if($type = "component") then $mapping/em:components/em:component[./@index = $index]
        else if($type = "sub-component") then $mapping/em:sub-components/em:sub-component[./@index = $index]
        else fn:error(xs:QName("exc:TYPEUNKNOWN"), fn:concat("Unknown content type ", $type, ".  Expected field, component or sub-component."))
    let $element :=
        element{ fn:QName($content-mapping/em:element/@namespace/fn:string(.), $content-mapping/em:element/@name/fn:string(.)) } {
            if($content/ex:components) then
                for $component at $i in $content/ex:components/ex:component
                order by $component/@index/xs:int(.) ascending
                return exc:convert-content($i, $component, $content-mapping)
            else if($content-mapping/em:sub-components) then
                for $sub-component at $i in $content/ex:components/ex:component
                order by $sub-component/@index/xs:int(.) ascending
                return exc:convert-content($i, $sub-component, $content-mapping)
            else $content/fn:string(.)
        }
    return $element
};

declare function exc:handle-loop($segment-index as xs:int, $segments as element(ex:segment)*, $mapping as element(em:edi-mapping), 
    $previous-mapping as element(em:segment)) as element(results) {
    let $loop-segment := $segments[$segment-index]
    return
        <results>
        {
            if($loop-segment) then
                let $segment-name := $previous-mapping/em:loop/em:loop-segment[./@identifier = $loop-segment/ex:segment-identifier]
                return 
                    if($segment-name) then 
                        let $segment-mapping := $mapping/em:segment[./em:identifier = $loop-segment/ex:segment-identifier]
                        return
                            if($segment-mapping) then
                                let $segment := exc:convert-segment($segment-index, $segments, $mapping, $segment-mapping)
                                let $next-segment := exc:handle-loop($segment/next-index/xs:int(.), $segments, $mapping, $previous-mapping)
                                return (<loop>{$segment/converted-segment/*, $next-segment/loop/*}</loop>, $next-segment/next-index)
                            else fn:error(xs:QName("exc:NOLOOPSEG"), fn:concat("No mapping found for segment identifier ", 
                                $loop-segment/ex:segment-identifier/fn:string(.), " in loop ", $previous-mapping/em:loop/@id/fn:string(.))) 
                    else <next-index>{$segment-index}</next-index>
            else <next-index>{$segment-index}</next-index>
        }
        </results>
};