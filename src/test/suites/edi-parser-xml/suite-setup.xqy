xquery version "1.0-ml";

import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

test:load-test-file("mock-edi-segment.edi", xdmp:database(), "/test-data/mock-edi-segment.edi"),
test:load-test-file("mock-edi-xml-segments.xml", xdmp:database(), "/test-data/mock-edi-xml-segments.xml"),
test:load-test-file("sample999-generic.xml", xdmp:database(), "/test-data/sample999-generic.xml"),
test:load-test-file("sample999-specific.xml", xdmp:database(), "/test-data/sample999-specific.xml"),
test:load-test-file("sample999.edi", xdmp:database(), "/test-data/sample999.edi"),
test:load-test-file("test-case-definitions.xml", xdmp:database(), "/test-data/test-case-definitions.xml"),
test:load-test-file("test-results.xml", xdmp:database(), "/test-data/test-results.xml")