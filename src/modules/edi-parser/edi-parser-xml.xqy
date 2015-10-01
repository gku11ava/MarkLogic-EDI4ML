module namespace epx = "http://edi4ml/edi/parser/xml";
(:~
 : This module contains functions used to convert an EDI x12 document to XML format,
 : EDI maps generated from the edi-parser-map library into XML, or XML into
 : the EDI x12 format.
 :
 : The ex:edi-document element contains a section to specify delimiters and then
 : contains an ex:segments section that contains the count and an ex:segment for each
 : EDI x12 segment.
 :
 : Each ex:segment contains an index attribute that represents its positional index
 : within the document.  It also contains an optional ex:segment-text section that contains
 : the original EDI x12 text for debugging purposes, the segment identifier in ex:segment-identifier,
 : and an ex:fields section that contains a count of fields for the segment as well as an ex:field for
 : each field.
 :
 : Each ex:field contains an index attribute that represents its positional index within
 : the segment. If the field contains any components, it will contain an ex:components element that
 : contains the count of components and an ex:component for each component.  Otherwise, the field
 : will contain the text value for the field.
 :
 : Each ex:component contains an index attribute that represents its positional index within
 : the field.  If the component contains any sub-components, it will contain an ex:sub-components element
 : that contains the count of components and an ex:sub-component for each component.  Otherwise, the
 : component will contain the text value for the component.
 :
 : Each ex:sub-component contains an index attribute that represents its positional index within
 : the component and the text value for the sub-component.
 :)
import module namespace epc = "http://edi4ml/edi/parser/commons" at "/modules/edi-parser/edi-parser-commons.xqy";

declare namespace ex = "http://edi4ml/edi/xml#";

declare variable $TRACE-DEBUG as xs:string := "edi-parser-xml";
declare variable $TRACE-DETAIL as xs:string := "edi-parser-xml-detail";
declare variable $TRACE-DOCUMENT as xs:string := "edi-parser-xml-document";

(:~
 : Convert an EDI x12 formatted document into an XML structure using the user specified delimiters.
 : This will create an ex:edi-document element with ex:segment, ex:field, ex:component and ex:sub-component
 : elements analogous to the EDI structure.  If no delimiters are provided default delimiters from the
 : edi-parser-commons module will be used.
 :
 : @params $document - the EDI x12 document to convert
 : @params $segment-delimiter - optional delimiter used to identify segments.
 : @params $field-delimiter - optional delimiter to identify fields within segments.
 : @params $component-delimiter - optional delimiter to identify components within fields.
 : @params $subcomponent-delimiter - optional delimiter to identify sub-components within components.
 : @params $apply-header-parsing - optional boolean to parse interchange/group/transaction headers.  Defaults to false.
 : @returns an ex:edi-document element
 :)
declare function epx:edi-to-xml($document, $segment-delimiter as xs:string?, $field-delimiter as xs:string?, 
    $component-delimiter as xs:string?, $subcomponent-delimiter as xs:string?, $apply-header-parsing as xs:boolean?) as element(ex:edi-document) {
    let $_ := (
        fn:trace("edi-to-xml -- called", $TRACE-DEBUG),
        fn:trace(fn:concat("edi-to-xml -- segment-delimiter=", $segment-delimiter), $TRACE-DETAIL),
        fn:trace(fn:concat("edi-to-xml -- field-delimiter=", $field-delimiter), $TRACE-DETAIL),
        fn:trace(fn:concat("edi-to-xml -- component-delimiter=", $component-delimiter), $TRACE-DETAIL),
        fn:trace(fn:concat("edi-to-xml -- subcomponent-delimiter=", $subcomponent-delimiter), $TRACE-DETAIL),
        fn:trace(fn:concat("edi-to-xml -- apply-header-parsing=", $apply-header-parsing), $TRACE-DETAIL),
        fn:trace(fn:concat("edi-to-xml -- document=", $document), $TRACE-DOCUMENT)
    )
    let $delimiter-map := epc:build-delimiter-map($segment-delimiter, $field-delimiter,
        $component-delimiter, $subcomponent-delimiter)
    return
        <ex:edi-document>
            <ex:delimiters>
            {
                for $key in map:keys($delimiter-map)
                return <ex:delimiter ex:type="{$key}">{map:get($delimiter-map, $key)}</ex:delimiter>
            }
            </ex:delimiters>
            {
                if($apply-header-parsing) then 
                    let $_ := fn:trace("edi-to-xml -- Applying header specific parsing", $TRACE-DEBUG)
                    (: Begin parsing the document from the first segment.  Parse header works recursively :)
                    let $interchanges := epx:parse-header(1, 
                        epc:tokenize($document, map:get($delimiter-map, $epc:KEY-SEGMENT-DELIMITER)), $delimiter-map)
                    let $warnings := $interchanges//warning
                    return (
                        <ex:interchanges ex:count="{fn:count($interchanges/ex:interchange)}">{$interchanges/ex:interchange}</ex:interchanges>,
                        if($warnings and $epc:DEBUG-MODE) then 
                            <ex:warnings>
                            {
                                for $warning in $warnings return <ex:warning>{$warning/fn:string(.)}</ex:warning>
                            }
                            </ex:warnings>
                        else (),
                        $interchanges/children
                    )
                else (: Parse to segments with no special handling of headers :)
                    let $_ := fn:trace("edi-to-xml -- Parsing headers into generic segments", $TRACE-DEBUG)
                    let $segments := 
                        for $segment at $i in epc:tokenize($document, map:get($delimiter-map, $epc:KEY-SEGMENT-DELIMITER))
                        where fn:string-length(fn:normalize-space($segment)) > 0
                        return epx:segment-to-xml((), $i, $segment, $delimiter-map)
                    return <ex:segments ex:count="{fn:count($segments)}">{$segments}</ex:segments>
            }
        </ex:edi-document>
};

(:~
 : Convert an EDI x12 formatted segment into the equivalent ex:segment element.
 :
 : @params $parent-index - the optional positional index for the parent segment
 : @params $segment-index - the positional index for the current segment
 : @params $segment-text - the EDI x12 segment that will be processed
 : @params $delimiter-map - a map of the current delimiters that will be used to process this segment
 : @returns an ex:segment element
 :)
declare function epx:segment-to-xml($parent-index as xs:int?, $segment-index as xs:int, $segment-text as xs:string, $delimiter-map as map:map) 
    as element(ex:segment) {
    let $_ := (
        fn:trace(fn:concat("segment-to-xml -- parsing segment ", $segment-index), $TRACE-DEBUG),
        fn:trace(fn:concat("segment-to-xml -- parent-index=", $parent-index), $TRACE-DETAIL),
        fn:trace(fn:concat("segment-to-xml -- segment-text=", $segment-text), $TRACE-DETAIL)
    )
    let $fields := epc:tokenize($segment-text, map:get($delimiter-map, $epc:KEY-FIELD-DELIMITER))
    return
        element{xs:QName("ex:segment")} {
            attribute{xs:QName("ex:index")} {$segment-index},
            if($parent-index) then attribute{xs:QName("ex:set-position")} {$segment-index - $parent-index} else (),
            if($epc:DEBUG-MODE) then element{xs:QName("ex:segment-text")} {$segment-text} else (),
            element{xs:QName("ex:segment-identifier")} {$fields[1]},
            let $parsed-fields :=
                for $field at $i in fn:subsequence($fields, 2)
                return epx:string-to-xml($i, $field, $epc:TYPE-FIELD, 
                    if($fields[1] = "ISA") then
                        let $temp-map := epc:build-delimiter-map($delimiter-map)
                        let $_ := map:delete($temp-map, $epc:KEY-COMPONENT-DELIMITER)
                        return $temp-map 
                    else $delimiter-map)
            return element{xs:QName("ex:fields")} {
                attribute{xs:QName("ex:count")} {fn:count($parsed-fields)},
                $parsed-fields
            }
        }
};

(:~
 : Convert an EDI x12 formatted string to the equivalent ex: element.  Fields and components
 : may recursively call this function to produce component and sub-component elements if
 : the provided string contains the matching component or sub-component delimiter if one
 : has been specified.
 :
 : @params $string-index - the positional index for the string
 : @params $string - the string that will be processed
 : @params $type - the string type.  This should be field, component or sub-component
 : @params $delimiter-map - a map of delimiters that will be used to process this string
 : @returns an ex: element analogous to the EDI x12 string type
 :)
declare function epx:string-to-xml($string-index as xs:int, $string as xs:string, $type as xs:string, 
    $delimiter-map as map:map) as element() {
    let $_ := (
        fn:trace(fn:concat("string-to-xml -- parsing ", $type, " at position ", $string-index), $TRACE-DEBUG),
        fn:trace(fn:concat("string-to-xml -- string=", $string), $TRACE-DETAIL)
    )
    let $type-mappings := $epc:STRING-TYPE-MAPPINGS/type[./@name = $type]
    let $child-type := $type-mappings/child-type/fn:string(.)
    let $child-delimiter-type := 
        $epc:STRING-TYPE-MAPPINGS/type[./@name = $child-type]/delimiter-key/fn:string(.) 
    let $delimiter := map:get($delimiter-map, $child-delimiter-type)
    return
         element {fn:concat("ex:", $type)} {
            attribute {xs:QName("ex:index")} {$string-index},
            if($delimiter and fn:contains($string, $delimiter)) then
                let $children :=
                    for $child at $i in epc:tokenize($string, $delimiter)
                    return epx:string-to-xml($i, $child, $child-type, $delimiter-map)
                return
                    element {fn:concat("ex:", $type-mappings/child-map-key/fn:string(.))} {
                        attribute {xs:QName("ex:count")} {fn:count($children)},
                        $children
                    }
            else $string
        }
};

(:~
 : Converts the provided ex:edi-document element into an EDI x12 document. 
 : This assumes the relevant delimiters are specified in the ex:edi-document.  If
 : No delimiters are specified there, the default delimiters in the edi-parser-commons module
 : will be used instead.
 : 
 : @params $xml - the ex:edi-document element that will be processed
 : @returns EDI x12 formatted text
 :)
declare function epx:xml-to-edi($xml as element(ex:edi-document)) as text() {
    let $_ := (
        fn:trace("xml to edi -- called", $TRACE-DEBUG),
        fn:trace(fn:concat("xml to edi -- xml=", xdmp:quote($xml)), $TRACE-DOCUMENT)
    )
    let $delimiter-map := epc:build-delimiter-map(
        $xml/ex:delimiters/ex:delimiter[./@ex:type=$epc:KEY-SEGMENT-DELIMITER]/fn:string(.), 
        $xml/ex:delimiters/ex:delimiter[./@ex:type=$epc:KEY-FIELD-DELIMITER]/fn:string(.),
        $xml/ex:delimiters/ex:delimiter[./@ex:type=$epc:KEY-COMPONENT-DELIMITER]/fn:string(.),
        $xml/ex:delimiters/ex:delimiter[./@ex:type=$epc:KEY-SUBCOMPONENT-DELIMITER]/fn:string(.))
    let $segment-delimiter := map:get($delimiter-map, $epc:KEY-SEGMENT-DELIMITER)
    return text {
            fn:string-join(
                if($xml/ex:segments) then
                    let $_ := fn:trace("xml to edi -- generic XML encountered", $TRACE-DEBUG)
                    for $segment in $xml/ex:segments/ex:segment
                    order by $segment/@ex:index/xs:int(.) ascending
                    return epx:xml-to-segment($segment, $delimiter-map)
                else if($xml/ex:interchanges) then 
                    let $_ := fn:trace("xml to edi -- parsed headers encountered", $TRACE-DEBUG)
                    for $interchange in $xml/ex:interchanges/ex:interchange
                    return epx:interchange-to-edi($interchange, $delimiter-map)
                else (),
                $segment-delimiter)
    }    
};

(:~
 : Converts the provided ex:segment into its equivalent EDI x12 string representation.
 :
 : @params $segment - the ex:segment element that will be processed
 : @params $delimiter-map - a map of delimiters that will be used to build the x12 string
 : @returns the string representation of the segment
 :)
declare function epx:xml-to-segment($segment as element(ex:segment), $delimiter-map as map:map) as xs:string {
    let $_ := fn:trace(fn:concat("xml-to-segment -- parsing to segment=", xdmp:quote($segment)), $TRACE-DETAIL)
    return fn:string-join(($segment/ex:segment-identifier/fn:string(.),
        (
            for $field in $segment/ex:fields/ex:field
            order by $field/@ex:index/xs:int(.) ascending
            return epx:xml-to-string($field, $delimiter-map)
        )), map:get($delimiter-map, $epc:KEY-FIELD-DELIMITER)) 
};

(:~
 : Converts the provided ex:field, ex:component or ex:sub-component into its equivalent EDI x12 string
 : representation.  If the ex:field or ex:component contains components or sub-components, this function
 : will be called recursively to obtain and concatenate those values using the appropriate delimiter
 : specified in the provided delimiter map.
 :
 : @params $string - the element that will be processed
 : @params $delimiter-map - the map of delimiters to use
 : @returns an x12 formatted string representation of the element
 :)
declare function epx:xml-to-string($string as element(), $delimiter-map as map:map) as xs:string {
    let $_ := fn:trace(fn:concat("xml-to-string -- parsing to string=", xdmp:quote($string)), $TRACE-DETAIL)
    let $type := fn:local-name($string)
    let $children := 
        if($type = $epc:TYPE-FIELD) then $string/ex:components/ex:component
        else if($type = $epc:TYPE-COMPONENT) then $string/ex:sub-components/ex:sub-component
        else ()
    return
        if($children) then
            fn:string-join(
                (
                    for $child in $children
                    order by $child/@ex:index/xs:int(.) ascending
                    return epx:xml-to-string($child, $delimiter-map)
                ), map:get($delimiter-map, $epc:STRING-TYPE-MAPPINGS/type[./@name = $type]/child-type)
            )        
        else $string/fn:string(.)
};

(:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
 :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
 :: Common EDI Header parsing in XQuery -- This may go away in the future                       ::
 :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
 :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::)
(:~
 : Applies special handling to the EDI common segments.  These are the interchange (ISA/ISE), functional group (GS, GE),
 : and transaction set (ST/SE) segments.  Instead of parsing these as generic segment/field/component elements, this
 : parses the content into specific elements to improve their searchability.
 :
 : @params $start-index the position of the segment being parsed
 : @params $segments a sequence of segments from the EDI document
 : @params $delimiter-map the map of delimiters used by the EDI document
 : @returns a results element containing the parsed header and its children as well as any
 :   validation warnings as a sibling.
 :)
declare function epx:parse-header($start-index as xs:int, $segments as xs:string*, $delimiter-map as map:map) as element() {
    let $_ := fn:trace(fn:concat("parse-header -- called on segment at position ", $start-index), $TRACE-DEBUG)
    let $header := $segments[$start-index]
    let $field-delimiter := map:get($delimiter-map, $epc:KEY-FIELD-DELIMITER)
    let $fields := epc:tokenize($header, $field-delimiter)
    let $identifier := $fields[1]
    let $header-type := $epc:HEADER-TYPE-DETAILS/header[./@identifier = $identifier]
    let $_ := (
        fn:trace(fn:concat("parse-header -- header-text: ", $header), $TRACE-DETAIL),
        fn:trace(fn:concat("parse-header -- header-type: ", $header-type, ", identifier: ", $identifier), $TRACE-DEBUG)
    )
    return
        <results>
        {   (: If the segment identifier is a known header type, apply the type specific processing and map the
               fields to specific elements.   Otherwise, return the current index up for further processing :)
            if($header-type) then
                (: If the segment is an ISA or GS, then the child should be a GS or ST and will be parsed using
                   parse-header.  Otherwise, start processing the children using the generic build-segment :)
                let $children := 
                    if($identifier = ("ISA", "GS")) then epx:parse-header($start-index + 1, $segments, $delimiter-map)
                    else epx:build-segment($start-index, $start-index + 1, $segments, $delimiter-map)
                let $child-count := fn:count($children/ex:*)
                (: The next index value returned after processing the children should be the footer for this
                   segment. :)
                let $footer := $segments[$children/next-index/xs:int(.)]
                let $footer-validation := epx:check-footer($children/next-index/xs:int(.), $footer, 
                    $header-type/tail-identifier/xs:string(.), $fields[$header-type/control-number-index/xs:int(.)],
                    if($identifier = "ST") then $child-count + 2 else $child-count, $field-delimiter)  
                return (
                    element{xs:QName(fn:concat("ex:", $header-type/name/fn:string(.)))} {
                        (: Start index is the segment index of the header segment :)
                        attribute{xs:QName("ex:start-index")} {$start-index},
                        (: End index is the segment index of the footer segment :)
                        attribute{xs:QName("ex:end-index")} {$children/next-index/xs:int(.)},
                        if($epc:DEBUG-MODE) then (
                            element{xs:QName("ex:original-header")}{$header},
                            $footer-validation/ex:original-footer
                        ) else (),
                        (: Map the fields for the segment to it's type specific XML :)
                        if($identifier = "ISA") then epx:build-interchange($fields)/*
                        else if($identifier = "GS") then epx:build-group($fields)/*
                        else epx:build-transaction-set($fields)/*,
                        (: Add the children.
                             interchange will contain functional-groups
                             functional-group will contain transaction-sets
                             transaction-sets will contain segments :)
                        element{xs:QName(fn:concat("ex:", $header-type/children/fn:string(.)))} {
                            attribute{xs:QName("ex:count")} {$child-count},
                            $children/ex:*
                        }
                    },
                    (: Next index after the footer should be the next instance of this segment type:)
                    epx:parse-header($footer-validation/next-index/xs:int(.), $segments, $delimiter-map)/*,
                    (: Any validation warnings for this segment :)
                    $footer-validation/warning
                )
            else
                let $_ := fn:trace("parse-header -- current segment is not a header", $TRACE-DEBUG)
                return <next-index>{$start-index}</next-index>
        }
        </results>
};

(:~
 : Map the fields from an interchange segment into an XML structure using human readable element
 : names.
 : @params $fields the fields from an interchange segment.
 : @returns an element containing XML elements specific to the interchange segment.
 :)
declare function epx:build-interchange($fields as xs:string*) as element(interchange-fields) {
    let $_ := (
        fn:trace("build-interchange -- parsing interchange header (ISA)", $TRACE-DEBUG),
        for $field at $i in $fields
        return fn:trace(fn:concat("build-interchange -- field at ", $i, ":", $field), $TRACE-DETAIL)
    )
    return
    <interchange-fields>
        <ex:control-number>{$fields[14]}</ex:control-number>
        <ex:control-version>{$fields[13]}</ex:control-version>
        <ex:authorization>
            <ex:qualifier>{$fields[2]}</ex:qualifier>
            <ex:information>{$fields[3]}</ex:information>
        </ex:authorization>
        <ex:security>
            <ex:qualifier>{$fields[4]}</ex:qualifier>
            <ex:information>{$fields[5]}</ex:information>
        </ex:security>
        <ex:sender>
            <ex:qualifier>{$fields[6]}</ex:qualifier>
            <ex:identifier>{$fields[7]}</ex:identifier>      
        </ex:sender>
        <ex:receiver>
            <ex:qualifier>{$fields[8]}</ex:qualifier>
            <ex:identifier>{$fields[9]}</ex:identifier>
        </ex:receiver>
        <ex:interchange-date>{$fields[10]}</ex:interchange-date>
        <ex:interchange-time>{$fields[11]}</ex:interchange-time>
        <ex:standard-identifier>{$fields[12]}</ex:standard-identifier>
        <ex:acknowledgement-required>{$fields[15]}</ex:acknowledgement-required>
        <ex:usage-indicator>{$fields[16]}</ex:usage-indicator>
        <ex:component-separator>{$fields[17]}</ex:component-separator>
    </interchange-fields>
};

(:~
 : Map the fields from a functional group segment into an XML structure using human readable element
 : names.
 : @params $fields the fields from a group segment.
 : @returns an element containing XML elements specific to the group segment.
 :)
declare function epx:build-group($fields as xs:string*) as element(group-fields) {
    let $_ := (
        fn:trace("build-group -- parsing functional group header (GS)", $TRACE-DEBUG),
        for $field at $i in $fields
        return fn:trace(fn:concat("build-group -- field at ", $i, ":", $field), $TRACE-DETAIL)
    )
    return
    <group-fields>
        <ex:control-number>{$fields[7]}</ex:control-number>
        <ex:functional-code>{$fields[2]}</ex:functional-code>
        <ex:application-sender>{$fields[3]}</ex:application-sender>
        <ex:application-receiver>{$fields[4]}</ex:application-receiver>
        <ex:date-format>{$fields[5]}</ex:date-format>
        <ex:time-format>{$fields[6]}</ex:time-format>
        <ex:responsible-agency-code>{$fields[8]}</ex:responsible-agency-code>
        <ex:document-identifier>{$fields[9]}</ex:document-identifier>
    </group-fields>
};

(:~
 : Map the fields from a transaction set segment into an XML structure using human readable element
 : names.
 : @params $fields the fields from a transaction set segment.
 : @returns an element containing XML elements specific to the transaction set segment.
 :)
declare function epx:build-transaction-set($fields as xs:string*) as element(set-fields) {
    let $_ := (
        fn:trace("build-transaction-set -- parsing transaction set header (ST)", $TRACE-DEBUG),
        for $field at $i in $fields
        return fn:trace(fn:concat("build-transaction-set -- field at ", $i, ":", $field), $TRACE-DETAIL)
    )
    return
    <set-fields>
        <ex:id>{$fields[2]}</ex:id>
        <ex:control-number>{$fields[3]}</ex:control-number>
        <ex:document-identifier>{$fields[4]}</ex:document-identifier>
    </set-fields>            
};

(:~ 
 : Recursive processing of generic segments.  This checks that the current segment is not one of the common EDI segments and then
 : parses it into the generic segment/field/component/sub-component elements.  If the segement is a common EDI segment, no parsing
 : is done and the index of the segment is returned back to parse-header for type specific parsing.
 : @params $parent-index the index of the parent segment
 : @params $start-index the index of the segment to parse
 : @params $segments a sequence of segments from the EDI document
 : @params $delimiter-map a map of delimiters used in this document
 : @returns a sequence of 0 or more parsed generic segments and the index of the next segment which is not generic.
 :)
declare function epx:build-segment($parent-index as xs:int, $start-index as xs:int, $segments as xs:string*, $delimiter-map as map:map) 
    as element() {
    let $segment := $segments[$start-index]
        let $_ := (
        fn:trace(fn:concat("build-segment -- parsing generic segment at ", $start-index), $TRACE-DEBUG),
        fn:trace(fn:concat("build-segment -- parent-index = ", $parent-index), $TRACE-DETAIL),
        fn:trace(fn:concat("build-segment -- segment text: ", $segment), $TRACE-DETAIL)
    )
    let $field-delimiter := map:get($delimiter-map, $epc:KEY-FIELD-DELIMITER)
    return 
        <results>
        {
            if(epx:check-segment-identifier($segment, ("ISA", "IEA", "GS", "GE", "ST", "SE"), $field-delimiter)) then
                let $_ := fn:trace("build-segment -- Segment is a header (ISA/GS/ST/IEA/GE/SE) type", $TRACE-DEBUG)
                return <next-index>{$start-index}</next-index>
            else (
                epx:segment-to-xml($parent-index, $start-index, $segment, $delimiter-map),
                epx:build-segment($parent-index, $start-index + 1, $segments, $delimiter-map)/*
            )
        }
        </results>
};

(:~
 : Utility function to verify that the segment matches one of the specified identifiers
 :
 : @params $segment the segment to verify
 : @params $identifier one or more identifiers to check
 : @params $field-delimiter the delimiter used to separate segment fields
 : @returns true if the segment identifier matches one of the provided identifiers. False otherwise
 :)
declare function epx:check-segment-identifier($segment as xs:string, $identifier as xs:string*, $field-delimiter) as xs:boolean {
    if(fn:substring-before($segment, $field-delimiter) = $identifier) then fn:true() else fn:false()
};

(:~
 : Utility function to perform footer segment validation.  This checks that the control number and child counts specified in the footer
 : match what is in the interchange/group/transactionset.
 :
 : @params $index the position of the footer segment
 : @params $footer the footer segment
 : @params $identifier the identifier for the footer
 : @params $control-number the control number used for the check
 : @params $count the count used for the check
 : @params $field-delimiter the delimiter used to separate fields in the provided segment
 : @returns The original footer segment text (ex:original-footer), any validation warnings and the index of the next segment for parsing
 :)
declare function epx:check-footer($index as xs:int, $footer as xs:string, $identifier as xs:string, $control-number as xs:string, 
    $count as xs:int, $field-delimiter as xs:string) as element() {
    let $_ := (
        fn:trace(fn:concat("check-footer -- validating header against footer contents at ", $index), $TRACE-DEBUG),
        fn:trace(fn:concat("check-footer -- footer-text:", $footer), $TRACE-DETAIL),
        fn:trace(fn:concat("check-footer -- footer-type:", $identifier), $TRACE-DETAIL)
    )
    let $type := 
        if($identifier = "IEA") then "Interchange"
        else if($identifier = "GE") then "Group"
        else if($identifier = "SE") then "Transaction Set"
        else "Unknown Segment Type"
    return
        <results>
        {
            if(epx:check-segment-identifier($footer, $identifier, $field-delimiter)) then
                let $footer-fields := epc:tokenize($footer, $field-delimiter)
                return (
                    if(xs:int($footer-fields[2]) != $count) then 
                        <warning>
                        {
                            fn:trace(fn:concat("Child count mismatch for ", $type, ": ", $control-number, 
                                ".  Expected ", $footer-fields[2], " found ", xs:string($count)), $TRACE-DEBUG)        
                        }
                        </warning>
                    else (),
                    if($footer-fields[3] != $control-number) then 
                         <warning>
                         {
                            fn:trace(fn:concat("Control number mismatch for ", $type, ": ", $control-number,
                                ".  ", $identifier, ": ", $footer-fields[3]), $TRACE-DEBUG)
                         }
                         </warning>
                    else (),
                    <next-index>{$index + 1}</next-index>,
                    <ex:original-footer>{$footer}</ex:original-footer>
                )
            else (
                <warning>
                {
                    fn:trace(fn:concat("Missing end segment (", $identifier, ") for ", $type, ": ", $control-number), $TRACE-DEBUG)
                }
                </warning>,
                <next-index>{$index}</next-index>
            ) 
        }
        </results>
};

(:~
 : Convert the interchange xml and its associated children back into an EDI formatted string.
 : This will parse the interchange element as well as its functional group and transaction set children.
 : This will produce the ISA and IEA segments as well as the segments that line in between.
 :
 : @params $interchange the ex:interchange element to parse
 : @params $delimtier-map the delimiters used to build the EDI document
 : @returns an EDI string representation of the interchange
 :)
declare function epx:interchange-to-edi($interchange as element(ex:interchange), $delimiter-map as map:map) as xs:string? {
    let $_ := (
        fn:trace("interchange-to-edi -- Converting interchange element to ISA/IEA segments", $TRACE-DEBUG),
        fn:trace(fn:concat("interchange-to-edi -- ", xdmp:quote($interchange)), $TRACE-DOCUMENT)
    )
    return
    fn:string-join((
        fn:string-join(("ISA", epx:get-string($interchange/ex:authorization/ex:qualifier),
            epx:get-string($interchange/ex:authorization/ex:information), epx:get-string($interchange/ex:security/ex:qualifier),
            epx:get-string($interchange/ex:security/ex:information), epx:get-string($interchange/ex:sender/ex:qualifier),
            epx:get-string($interchange/ex:sender/ex:identifier), epx:get-string($interchange/ex:receiver/ex:qualifier),
            epx:get-string($interchange/ex:receiver/ex:identifier), epx:get-string($interchange/ex:interchange-date),
            epx:get-string($interchange/ex:interchange-time), epx:get-string($interchange/ex:standard-identifier),
            epx:get-string($interchange/ex:control-version), epx:get-string($interchange/ex:control-number),
            epx:get-string($interchange/ex:acknowledgement-required), epx:get-string($interchange/ex:usage-indicator),
            epx:get-string($interchange/ex:component-separator)), map:get($delimiter-map, $epc:KEY-FIELD-DELIMITER)),
        for $group in $interchange/ex:functional-groups/ex:functional-group return epx:group-to-edi($group, $delimiter-map),
        fn:string-join(("IEA", $interchange/ex:functional-groups/@ex:count/fn:string(.), epx:get-string($interchange/ex:control-number)),
            map:get($delimiter-map, $epc:KEY-FIELD-DELIMITER))), map:get($delimiter-map, $epc:KEY-SEGMENT-DELIMITER))
};

(:~
 : Converts the functional group and its associated children back into an EDI formatted string.
 : This will parse the functional group and all of its transaction sets.  This produces the
 : GS and GE segments as well as the segments that lie in between.
 :
 : @params $group the ex:functional-group to parse
 : @params $delimiter-map the delimiters used to build the EDI document
 : @returns an EDI string representation of the functional group
 :)
declare function epx:group-to-edi($group as element(ex:functional-group), $delimiter-map as map:map) as xs:string? {
    let $_ := (
        fn:trace("group-to-edi -- Converting functional-group element to GS/GE segments", $TRACE-DEBUG),
        fn:trace(fn:concat("group-to-edi -- ", xdmp:quote($group)), $TRACE-DOCUMENT)
    )
    return
    fn:string-join((
        fn:string-join(("GS", epx:get-string($group/ex:functional-code),
            epx:get-string($group/ex:application-sender), epx:get-string($group/ex:application-receiver),
            epx:get-string($group/ex:date-format), epx:get-string($group/ex:time-format),
            epx:get-string($group/ex:control-number), epx:get-string($group/ex:responsible-agency-code),
            epx:get-string($group/ex:document-identifier)), map:get($delimiter-map, $epc:KEY-FIELD-DELIMITER)),
        for $set in $group/ex:transaction-sets/ex:transaction-set return epx:set-to-edi($set, $delimiter-map),
        fn:string-join(("GE", $group/ex:transaction-sets/@ex:count/fn:string(.), epx:get-string($group/ex:control-number)),
            map:get($delimiter-map, $epc:KEY-FIELD-DELIMITER))), map:get($delimiter-map, $epc:KEY-SEGMENT-DELIMITER))
};

(:~
 : Converts the transaction set and its associated segments back into an EDI formatted string.
 : This will produce the ST and SE segments with the format specific segments associated with the
 : transaction set lying in between.
 :
 : @params $set the ex:transaction-set to build.
 : @params $delimiter-map the delimiters used
 : @returns an EDI string representation of the transaction set
 :)
declare function epx:set-to-edi($set as element(ex:transaction-set), $delimiter-map as map:map) as xs:string? {
    let $_ := (
        fn:trace("set-to-edi -- Converting transaction-set element to ST/SE segments", $TRACE-DEBUG),
        fn:trace(fn:concat("set-to-edi -- ", xdmp:quote($set)), $TRACE-DOCUMENT)
    )
    return
    fn:string-join((
        fn:string-join(("ST", epx:get-string($set/ex:id), epx:get-string($set/ex:control-number), 
            epx:get-string($set/ex:document-identifier)), map:get($delimiter-map, $epc:KEY-FIELD-DELIMITER)),
        for $segment in $set/ex:segments/ex:segment return epx:xml-to-segment($segment, $delimiter-map),
        fn:string-join(("SE", fn:string($set/ex:segments/@ex:count/xs:int(.) + 2), epx:get-string($set/ex:control-number)),
            map:get($delimiter-map, $epc:KEY-FIELD-DELIMITER))), map:get($delimiter-map, $epc:KEY-SEGMENT-DELIMITER))
};

(:~
 : Helper function used to convert the provided element or attribute value into a string.
 :
 : @params $node the element or attribute to process
 : @returns the value for the element or attribute, an empty string if the provided node doesn't exist
 :)
declare function epx:get-string($node as item()?) as xs:string {
    if($node) then $node/fn:string(.) else ""
};

(:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
 :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
 :: Map to XML functions -- This may go away in the future                                      ::
 :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
 :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::)

(:~
 : Converts an EDI document map to XML with equivalent segment, field, component and sub-component
 : elements analogous to the EDI x12 structures.  Delimiters that were used to parse the original
 : x12 document into map format are assumed to be included in the provided document map.
 :
 : @params $document-map - the EDI document map to be parsed
 : @returns an ex:edi-document element
 :)
declare function epx:edi-map-to-xml($document-map as map:map) as element(ex:edi-document) {
    <ex:edi-document>
        <ex:delimiters>
        {
            let $delimiter-map := map:get($document-map, $epc:KEY-DELIMITER-MAP)
            for $key in map:keys($delimiter-map)
            return <ex:delimiter ex:type="{$key}">{map:get($delimiter-map, $key)}</ex:delimiter>
        }
        </ex:delimiters>
        <ex:segments ex:count="{map:get($document-map, $epc:KEY-SEGMENT-COUNT)}">
        {
            let $segment-map := map:get($document-map, $epc:KEY-SEGMENT-MAP)
            for $segment in map:keys($segment-map)
            order by xs:int($segment) ascending
            return epx:segment-map-to-xml($segment, map:get($segment-map, $segment))
        }
        </ex:segments>
    </ex:edi-document>
};

(:~
 : Converts the provided EDI segment map into the equivalent ex:segment element.
 : 
 : @params $segment-index - the positional index for the segment
 : @params $segment-map - the EDI segment map to process
 : @returns An XML representation of the segment-map as an ex:segment element.
 :)
declare function epx:segment-map-to-xml($segment-index as xs:string, $segment-map as map:map) 
    as element(ex:segment) {
    <ex:segment ex:index="{$segment-index}">
        <ex:segment-text>{map:get($segment-map, $epc:KEY-SEGMENT-TEXT)}</ex:segment-text>
        <ex:segment-identifier>{map:get($segment-map, $epc:KEY-SEGMENT-IDENTIFIER)}</ex:segment-identifier>
        <ex:fields ex:count="{map:get($segment-map, $epc:KEY-FIELD-COUNT)}">
        {
            epx:string-map-to-xml(map:get($segment-map, $epc:KEY-FIELD-MAP), $epc:TYPE-FIELD)
        }
        </ex:fields>
    </ex:segment>        
};

(:~
 : Converts the provided EDI string map (Field/Component/Sub-Component) into the equivalent ex:
 : XML elements.  When processing fields and components, this function may be recursively called
 : if the provided map contains a map of component or sub-component values.
 :
 : @params $map - the map being processed
 : @params $type - the map type, field, component or sub-component
 : @returns ex: element for each item in the provided string map.
 :)
declare function epx:string-map-to-xml($map as map:map, $type as xs:string) as element()* {
    let $type-mappings := $epc:STRING-TYPE-MAPPINGS/type[./@name = $type]
    let $child-type := $type-mappings/child-type/fn:string(.)
    for $key in map:keys($map)
    let $value := map:get($map, $key)
    order by xs:int($key)
    return
        element {fn:concat("ex:", $type)} {
            attribute {xs:QName("ex:index")} {$key},
            if($value castable as map:map and $child-type) then
                element {xs:QName(fn:concat("ex:", $type-mappings/child-map-key/fn:string(.)))} {
                    attribute {xs:QName("ex:count")} {map:get($value, $type-mappings/child-count-key/fn:string(.))},
                    epx:string-map-to-xml(map:get($value, $type-mappings/child-map-key/fn:string(.)), $child-type)
                }
            else $value
        }
};
