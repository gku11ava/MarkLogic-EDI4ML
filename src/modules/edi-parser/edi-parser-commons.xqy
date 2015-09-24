module namespace epc = "http://edi4ml/edi/parser/commons";
(:~
 : Module: edi-parser-commons.xqy
 : Date: 8/3/2015
 :
 : This module contains constants and shared functions that can be used to
 : convert an EDI document into a map or generic XML format.
 :
 :)

declare variable $epc:DEBUG-MODE as xs:boolean := xdmp:get-server-field("EDI-PARSER-DEBUG", fn:false());

(: Default Delimiters :)
declare variable $epc:COMPONENT-DELIMITER as xs:string? := ":";
declare variable $epc:FIELD-DELIMITER as xs:string := "*";
declare variable $epc:SEGMENT-DELIMITER as xs:string := "~";
declare variable $epc:SUBCOMPONENT-DELIMITER as xs:string? := ();

(: String Constants
 : Values with a KEY prefix are constant key names used to store and retrieve
 : data in specific maps.  Typically the naming convention is key-map-description.
 :)
declare variable $epc:KEY-COMPONENT-COUNT as xs:string := "component-count";
declare variable $epc:KEY-COMPONENT-DELIMITER as xs:string := "component";
declare variable $epc:KEY-COMPONENT-MAP as xs:string := "components";
declare variable $epc:KEY-DELIMITER-MAP as xs:string := "delimiters";
declare variable $epc:KEY-FIELD-COUNT as xs:string := "field-count";
declare variable $epc:KEY-FIELD-DELIMITER as xs:string := "field";
declare variable $epc:KEY-FIELD-MAP as xs:string := "fields";
declare variable $epc:KEY-SEGMENT-COUNT as xs:string := "segment-count";
declare variable $epc:KEY-SEGMENT-DELIMITER as xs:string := "segment";
declare variable $epc:KEY-SEGMENT-IDENTIFIER as xs:string := "segment-identifier";
declare variable $epc:KEY-SEGMENT-MAP as xs:string := "segments";
declare variable $epc:KEY-SEGMENT-TEXT as xs:string := "segment-text";
declare variable $epc:KEY-SUBCOMPONENT-COUNT as xs:string := "sub-component-count";
declare variable $epc:KEY-SUBCOMPONENT-DELIMITER as xs:string := "sub-component";
declare variable $epc:KEY-SUBCOMPONENT-MAP as xs:string := "sub-components";
declare variable $epc:TRACE-DEBUG-UTIL as xs:string := "edi-parser-util";
declare variable $epc:TRACE-DETAIL-UTIL as xs:string := "edi-parser-util-detail";
declare variable $epc:TYPE-COMPONENT as xs:string := "component";
declare variable $epc:TYPE-FIELD as xs:string := "field";
declare variable $epc:TYPE-SUBCOMPONENT as xs:string := "sub-component";

(: This is used to streamline processing of fields/components/sub-components.
 : This is because the processing behavior for each type is similar, but with
 : different key/element/child names 
 :)
declare variable $epc:STRING-TYPE-MAPPINGS := 
<type-mappings>
    <type name="{$epc:TYPE-FIELD}">
        <delimiter-key>{$epc:KEY-FIELD-DELIMITER}</delimiter-key>
        <child-type>{$TYPE-COMPONENT}</child-type>
        <child-count-key>{$epc:KEY-COMPONENT-COUNT}</child-count-key>
        <child-map-key>{$epc:KEY-COMPONENT-MAP}</child-map-key>
    </type>
    <type name="{$epc:TYPE-COMPONENT}">
        <delimiter-key>{$epc:KEY-COMPONENT-DELIMITER}</delimiter-key>
        <child-type>{$TYPE-SUBCOMPONENT}</child-type>
        <child-count-key>{$epc:KEY-SUBCOMPONENT-COUNT}</child-count-key>
        <child-map-key>{$epc:KEY-SUBCOMPONENT-MAP}</child-map-key>
    </type>
    <type name="{$epc:TYPE-SUBCOMPONENT}">
        <delimiter-key>{$epc:KEY-SUBCOMPONENT-DELIMITER}</delimiter-key>
    </type>
</type-mappings>;

(: This is used to handle the optional built-in processing of the common header components
 : for an EDI document.  These are the Interchange (ISA/IEA), Functional Group (GS/GE) and
 : Transaction Set (ST/SE) segments.
 :)
declare variable $epc:HEADER-TYPE-DETAILS :=
<header-mappings>
    <header identifier="ISA">
        <tail-identifier>IEA</tail-identifier>
        <control-number-index>14</control-number-index>
        <name>interchange</name>
        <children>functional-groups</children>
    </header>
    <header identifier="GS">
        <tail-identifier>GE</tail-identifier>
        <control-number-index>7</control-number-index>
        <name>functional-group</name>
        <children>transaction-sets</children>
    </header>
    <header identifier="ST">
        <tail-identifier>SE</tail-identifier>
        <control-number-index>3</control-number-index>
        <name>transaction-set</name>
        <children>segments</children>
    </header>
</header-mappings>;

(:~
 : Create a delimiter map from the provided map of delimiter values.  If some values
 : are missing, replace the missing values with defaults from this module.
 : 
 : @params $map - a map with custom delimiter value
 : @returns - a merged delimiter map with the user provided delimiters with missing values
 :   replaced by defaults
 :)
declare function epc:build-delimiter-map($map as map:map?) as map:map {
    let $_ := (
        fn:trace("build-delimiter-map -- called", $epc:TRACE-DEBUG-UTIL),
        if(fn:exists($map)) then 
            let $keys := map:keys($map)
            return 
                if($keys) then 
                    for $key in $keys 
                    return fn:trace(fn:concat("build-delimiter-map -- map:", $key, "=", map:get($map, $key)), $epc:TRACE-DETAIL-UTIL) 
                else fn:trace("build-delimiter-map -- provided map contains no keys", $epc:TRACE-DETAIL-UTIL)
        else fn:trace("build-delimiter-map -- no map provided", $epc:TRACE-DETAIL-UTIL)
    )
    let $base-map := if(fn:empty($map)) then map:map() else $map
    let $delimiter-map := map:map()
    let $_ := (
        map:put($delimiter-map, $epc:KEY-SEGMENT-DELIMITER, 
            if(map:contains($base-map, $epc:KEY-SEGMENT-DELIMITER)) then 
                map:get($base-map, $epc:KEY-SEGMENT-DELIMITER) 
            else $epc:SEGMENT-DELIMITER),
        map:put($delimiter-map, $epc:KEY-FIELD-DELIMITER, 
            if(map:contains($base-map, $epc:KEY-FIELD-DELIMITER)) then 
                map:get($base-map, $epc:KEY-FIELD-DELIMITER) 
            else $epc:FIELD-DELIMITER),
        map:put($delimiter-map, $epc:KEY-COMPONENT-DELIMITER, 
            if(map:contains($base-map, $epc:KEY-COMPONENT-DELIMITER)) then 
                map:get($base-map, $epc:KEY-COMPONENT-DELIMITER) 
            else $epc:COMPONENT-DELIMITER),
        map:put($delimiter-map, $epc:KEY-SUBCOMPONENT-DELIMITER, 
            if(map:contains($base-map, $epc:KEY-SUBCOMPONENT-DELIMITER)) then 
                map:get($base-map, $epc:KEY-SUBCOMPONENT-DELIMITER) 
            else $epc:SUBCOMPONENT-DELIMITER)
    )
    return $delimiter-map
};

(:~
 : Create a delimiter map from the user provided delimiter values.  If some values
 : are missing, replace the missing values with defaults from this module.
 : 
 : @params $segment-delimiter - optional delimiter for segments
 : @params $field-delimiter - optional delimiter for fields
 : @params $component-delimiter - optional delimiter for components
 : @params $subcomponent-delimiter - optional delimiter for sub-components
 : @returns - a delimiter map with the user provided delimiters and default values for
 :   any values skipped by the user
 :)
declare function epc:build-delimiter-map($segment-delimiter as xs:string?, $field-delimiter as xs:string?,
    $component-delimiter as xs:string?, $subcomponent-delimiter as xs:string?) as map:map {
    let $_ := (
        fn:trace("build-delimiter-map -- called", $epc:TRACE-DEBUG-UTIL),
        fn:trace(fn:concat("build-delimiter-map -- segment-delimiter=", $segment-delimiter), $epc:TRACE-DETAIL-UTIL),
        fn:trace(fn:concat("build-delimiter-map -- field-delimiter=", $field-delimiter), $epc:TRACE-DETAIL-UTIL),
        fn:trace(fn:concat("build-delimiter-map -- component-delimiter=", $component-delimiter), $epc:TRACE-DETAIL-UTIL),
        fn:trace(fn:concat("build-delimiter-map -- subcomponent-delimiter=", $subcomponent-delimiter), $epc:TRACE-DETAIL-UTIL)
    )
    let $delimiter-map := map:map()
    let $_ := (
        map:put($delimiter-map, $epc:KEY-SEGMENT-DELIMITER, 
            if($segment-delimiter) then $segment-delimiter else $epc:SEGMENT-DELIMITER),
        map:put($delimiter-map, $epc:KEY-FIELD-DELIMITER, 
            if($field-delimiter) then $field-delimiter else $epc:FIELD-DELIMITER),
        map:put($delimiter-map, $epc:KEY-COMPONENT-DELIMITER, 
            if($component-delimiter) then $component-delimiter else $epc:COMPONENT-DELIMITER),
        map:put($delimiter-map, $epc:KEY-SUBCOMPONENT-DELIMITER, 
            if($subcomponent-delimiter) then $subcomponent-delimiter else $epc:SUBCOMPONENT-DELIMITER)
    )
    return $delimiter-map
};

(:~
 : Handles escaping the delimiter if the delimiter is a reserved regex character.
 :
 : @params $string - the string to tokenize
 : @params $delimiter - the delimiter to use
 : @returns the tokenized string
 :)
declare function epc:tokenize($string as xs:string, $delimiter as xs:string) as xs:string* {
    fn:tokenize($string,
        if($delimiter = ("[", "\", "^", "$", ".", "|", "?", "*", "+", "{", "}", "(", ")")) then
            fn:concat("\", $delimiter)
        else $delimiter)
};