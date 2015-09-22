module namespace epm = "http://marklogic.com/edi/parser/map";
(:~
 : This module contains functions used to convert an EDI x12 document to a map format,
 : convert ex:edi-document XML into a map or a map into EDI x12 formatted text.
 :
 : The map format is a tree-like structure.  The root map element contains a map of delimiters,
 : a count of the number of segments in the tree and a map of segments.
 :
 : Each entry (segment) in the map of segments is identified by a key value that also serves as a 
 : positional index identifying where it is in the EDI x12 document.  Each segment contains
 : an optional segment text which is the segment in x12 format, the segment identifier which
 : is the first field in the segment, a count of the number of fields in the segment and
 : a map of fields belonging to the segment.
 :
 : Each entry (field) in a map of fields is identified by a key value that also serves as a
 : positional index that identifies where the field is within the segment.  If the field
 : can be subdivided into sub-components, it will also be represented by a map that contains
 : a count of components and a map of the components.  Otherwise, the field will contain a
 : string representation of the field value.  Components and sub-components behave in 
 : a similar manner except sub-components will only represent the sub-component value as
 : a sub-component cannot be divided further.
 :
 :)

import module namespace epc = "http://marklogic.com/edi/parser/commons" at "/modules/edi-parser/edi-parser-commons.xqy";

declare namespace ex = "http://marklogic.com/edi/xml";

(:~
 : Converts the provided EDI x12 document into a map using the user provided delimiters.  Any empty delimiters
 : will be replaced by default values specified in the edi-parser-commons module.
 :
 : @params $document - the x12 document to parse
 : @params $segment-delimiter - the optional segment delimiter to use
 : @params $field-delimiter - the optional field delimiter to use
 : @params $component-delimiter - the optional component delimiter to use
 : @params $subcomponent-delimiter - the optional subcomponent delimiter to use
 : @returns the EDI document in map form
 :)
declare function epm:edi-to-map($document, $segment-delimiter as xs:string?, $field-delimiter as xs:string?, 
    $component-delimiter as xs:string?, $subcomponent-delimiter as xs:string?) as map:map {
    let $delimiter-map := epc:build-delimiter-map($segment-delimiter, $field-delimiter,
        $component-delimiter, $subcomponent-delimiter)
    let $segments := epc:tokenize($document, map:get($delimiter-map, $epc:KEY-SEGMENT-DELIMITER))
    let $segment-map := map:map()
    let $_ := 
        for $segment at $i in $segments
        return
            if(fn:string-length(fn:normalize-space($segment)) > 0) then
                map:put($segment-map, fn:string($i), epm:segment-to-map($segment, $delimiter-map))
            else ()
    let $document-map := map:map()
    let $_ := ( 
        map:put($document-map, $epc:KEY-DELIMITER-MAP, $delimiter-map),
        map:put($document-map, $epc:KEY-SEGMENT-COUNT, map:count($segment-map)), 
        map:put($document-map, $epc:KEY-SEGMENT-MAP, $segment-map)
    )
    return $document-map
};

(:~
 : Converts the provided EDI x12 segment into a map using the provided delimiters
 :
 : @params $segment-text - the original segment text to process
 : @params $delimiter-map - a map of delimiters to use
 : @returns a map of the current segment
 :)
declare function epm:segment-to-map($segment-text as xs:string, $delimiter-map as map:map) 
    as map:map {
    let $fields := epc:tokenize($segment-text, map:get($delimiter-map, $epc:KEY-FIELD-DELIMITER))
    let $field-map := map:map()
    let $_ := 
        for $field at $i in fn:subsequence($fields, 2)
        return map:put($field-map, fn:string($i), epm:string-to-map($field, $epc:TYPE-FIELD, $delimiter-map))
    let $segment-map := map:map()
    let $_ := (
        map:put($segment-map, $epc:KEY-SEGMENT-TEXT, $segment-text),
        map:put($segment-map, $epc:KEY-FIELD-COUNT, map:count($field-map)),
        map:put($segment-map, $epc:KEY-SEGMENT-IDENTIFIER, $fields[1]),
        map:put($segment-map, $epc:KEY-FIELD-MAP, $field-map)
    )
    return $segment-map
};

(:~
 : Converts the provided EDI x12 string into a field, component or subcomponent as specified by the type, using
 : the provided delimiters.   If the content can be further subdivided, this function will be called recursively
 : on with the appropriate child type and a map of the processed child values will be returned, otherwise a
 : the processed string will be returned.
 :
 : @params $string - the string to process
 : @params $type - the string type, field, component or sub-component
 : @params $delimiter-map - the map of delimiters to use for processing
 : @returns a string or a map containing the count and child string tokens
 :)
declare function epm:string-to-map($string as xs:string, $type as xs:string, $delimiter-map as map:map) as item() {
    let $type-mappings := $epc:STRING-TYPE-MAPPINGS/type[./@name = $type]
    let $child-type := $type-mappings/child-type/fn:string(.)
    let $child-delimiter-type := 
        $epc:STRING-TYPE-MAPPINGS/type[./@name = $child-type]/delimiter-key/fn:string(.) 
    let $delimiter := map:get($delimiter-map, $child-delimiter-type)
    return
        if($delimiter and fn:contains($string, $delimiter)) then
            let $part-map := map:map()
            let $_ := 
                for $part at $i in epc:tokenize($string, $delimiter)
                return map:put($part-map, fn:string($i), 
                    if($type-mappings/child-type) then 
                        epm:string-to-map($part, $type-mappings/child-type/fn:string(.), $delimiter-map) 
                    else $part)
            let $string-map := map:map()
            let $_ := (
                map:put($string-map, $type-mappings/child-count-key/fn:string(.), map:count($part-map)),
                map:put($string-map, $type-mappings/child-map-key/fn:string(.), $part-map)
            )
            return $string-map
        else $string
};

(:~
 : Converts the provided ex:edi-document XML element into a map representation.
 : This assumees the delimiters that were used to convert the original x12 document
 : to XML are specified in the ex:edi-document/ex:delimiters.  Any unspecified
 : delimiters will be replaced with the default delimiters specified in the
 : edi-parser-commons module.
 :
 : @params $xml - the edi-document XMl element to parse.
 : @returns an edi map of values
 :)
declare function epm:xml-to-edi-map($xml as element(ex:edi-document)) as map:map {
    let $delimiter-map := epc:build-delimiter-map(
        $xml/ex:delimiters/delimiter[./@type=$epc:KEY-SEGMENT-DELIMITER]/fn:string(.), 
        $xml/ex:delimiters/delimiter[./@type=$epc:KEY-FIELD-DELIMITER]/fn:string(.),
        $xml/ex:delimiters/delimiter[./@type=$epc:KEY-COMPONENT-DELIMITER]/fn:string(.),
        $xml/ex:delimiters/delimiter[./@type=$epc:KEY-SUBCOMPONENT-DELIMITER]/fn:string(.))
    let $segment-map := map:map()
    let $_ := 
        for $segment in $xml/ex:segments/ex:segment
        order by $segment/@index/xs:int(.) ascending
        return map:put($segment-map, $segment/@index/fn:string(.), epm:xml-to-segment-map($segment))
    let $document-map := map:map()
    let $_ := (
        map:put($document-map, $epc:KEY-DELIMITER-MAP, $delimiter-map),
        map:put($document-map, $epc:KEY-SEGMENT-COUNT, $xml/ex:segments/@count/fn:string(.)), 
        map:put($document-map, $epc:KEY-SEGMENT-MAP, $segment-map)
    )
    return $document-map
};

(:~
 : Converts the provided ex:segment element into the equivalent map representation
 :
 : @params $segment - the ex:segment element to parse
 : @returns a map
 :)
declare function epm:xml-to-segment-map($segment as element(ex:segment)) as map:map {
    let $field-map := map:map()
    let $_ := 
        for $field in $segment/ex:fields/ex:field
        order by $field/@index/xs:int(.) ascending
        return map:put($field-map, $field/@index/fn:string(.), epm:xml-to-string-map($field, $epc:TYPE-FIELD))
    let $segment-map := map:map()
    let $_ := (
        map:put($segment-map, $epc:KEY-SEGMENT-TEXT, $segment/ex:segment-text/fn:string(.)),
        map:put($segment-map, $epc:KEY-FIELD-COUNT, $segment/ex:fields/@count/fn:string(.)),
        map:put($segment-map, $epc:KEY-SEGMENT-IDENTIFIER, $segment/ex:segment-identifier/fn:string(.)),
        map:put($segment-map, $epc:KEY-FIELD-MAP, $field-map)
    )
    return $segment-map
};

(:~
 : Converts an ex:field, ex:component or ex:sub-component to the equivalent map.
 : This will be called recursively if the provided element contains the appropriate child types,
 : otherwise, a string representation of the element will be returned.
 :
 : @params $string - the ex element to process
 : @params $type - the type of the element, field, component or sub-component
 : @returns a map or string as appropriate
 :)
declare function epm:xml-to-string-map($string as element(), $type as xs:string) as item() {
    let $type-mappings := $epc:STRING-TYPE-MAPPINGS/type[./@name = $type]
    let $map := map:map()
    let $children := 
        if($type = $epc:TYPE-FIELD) then $string/ex:components/ex:component
        else if($type = $epc:TYPE-COMPONENT) then $string/ex:sub-components/ex:sub-component
        else ()
    return
        if($children) then
            let $child-map := map:map()
            let $_ := 
                for $child in $children
                order by $child/@index/xs:int(.) ascending
                return map:put($child-map, $child/@index, 
                    epm:xml-to-string-map($child, $type-mappings/child-type/fn:string(.)))
            let $_ := (
                map:put($map, $type-mappings/child-count-key/fn:string(.), fn:count($children)),
                map:put($map, $type-mappings/child-map-key/fn:string(.), $child-map)
            )
            return $map
        else $string/fn:string(.)
};

(:~
 : Converts the specified map to an EDI x12 document.  This assumes the delimiters used
 : are specified in a delimiter map that is included in the provided map.  if some
 : delimiter values are missing, the default delimiters specified in the edi-parser-commons
 : will be used instead.
 :
 : @params $map - the map to parse
 : @returns EDI x12 text representation of the map
 :)
declare function epm:map-to-edi($map as map:map) as text() {
    let $delimiter-map := epc:build-delimiter-map(map:get($map, $epc:KEY-DELIMITER-MAP))
    let $segment-delimiter := map:get($delimiter-map, $epc:KEY-SEGMENT-DELIMITER)
    let $segment-map := map:get($map, $epc:KEY-SEGMENT-MAP)
    return text {
        fn:concat(
            fn:string-join(
                for $segment-key in map:keys($segment-map)
                order by xs:int($segment-key) ascending
                return epm:map-to-segment(map:get($segment-map, $segment-key), $delimiter-map),
                $segment-delimiter
            ), $segment-delimiter)
    }
};

(:~
 : Converts the provided segment map into an EDI x12 representation of the segment using the
 : provided delimiters.
 :
 : @params $segment - the segment map
 : @params $delimiter - map a map of delimiters to use
 : @returns an EDI x12 string of the map
 :)
declare function epm:map-to-segment($segment as map:map, $delimiter-map as map:map) as xs:string {
    fn:string-join((map:get($segment, $epc:KEY-SEGMENT-IDENTIFIER),
        epm:map-to-string(map:get($segment, $epc:KEY-FIELD-MAP), $epc:TYPE-FIELD, $delimiter-map)), 
        map:get($delimiter-map, $epc:KEY-FIELD-DELIMITER))
};

(:~
 : Converts the provided string map (field, component, sub-component) into the EDI x12 representation
 : for the specified type using the provided delimiters.  if the type is a map this will be recursively
 : called to process the contents of the map.  Otherwise, the string value is returned.
 : 
 : @params $string-map - the map of the fields/components/sub-componets
 : @params $type - the corresponding x12 type, field, component or sub-component
 : @params $delimiter-map - a map of delimiters to use for parsing
 : @returns an x12 string representing the provided map
 :)
declare function epm:map-to-string($string-map as map:map, $type as xs:string,
    $delimiter-map as map:map) as xs:string? {
    let $type-mapping :=  $epc:STRING-TYPE-MAPPINGS/type[./@name = $type]
    return 
        fn:string-join((
            for $key in map:keys($string-map)
            order by xs:int($key) ascending
            return 
                let $item := map:get($string-map, $key)
                return 
                    if($item castable as map:map) then 
                        epm:map-to-string($item, $type-mapping/child-type/fn:string(.), $delimiter-map)
                    else $item
            ), map:get($delimiter-map, $type-mapping/delimiter-key/fn:string(.)))
};