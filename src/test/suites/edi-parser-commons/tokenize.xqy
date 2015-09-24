xquery version "1.0-ml";
(:~
 : This module tests the tokenizer function from the edi-parser-commons library.
 : The tokenizer there differs from the basic fn:tokenize with the addition of
 : special handling to escape out regex reserved characters.
 :)
import module namespace epc = "http://edi4ml/edi/parser/commons" at "/modules/edi-parser/edi-parser-commons.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

declare variable $RESERVED-CHARACTERS := ("[", "\", "^", "$", ".", "|", "?", "*", "+", "{", "}", "(", ")");
declare variable $TEST-TEXT := ("Hello", "World ", " ", "12345", "'special-character'");

declare function local:main() {
    (: Test tokenizing with Regex reserved character escaping :)
    for $token in $RESERVED-CHARACTERS
    return local:tokenize($token),
    
    (: Test splitting with non-reserved character :)
    local:tokenize(",")
};

declare private function local:build-test-string($delimiter as xs:string) as xs:string {
    fn:string-join($TEST-TEXT, $delimiter)
};

declare private function local:tokenize($token as xs:string) {
    let $test := epc:tokenize(local:build-test-string($token), $token)
    return (
        (: Verify token count :)
        test:assert-equal(fn:count($TEST-TEXT), fn:count($test)),
        (: Verify token values :)
        for $value at $i in $TEST-TEXT
        return test:assert-equal($value, $test[$i])         
    )
};

local:main()