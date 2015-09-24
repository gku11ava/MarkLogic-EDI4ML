# EDI4ML
EDI4ML consists of 2 parts, the standalone library modules in src/modules/edi-parser and a local Roxy framework for testing the XQuery modules.

The EDI4ML XQuery library modules provides functions to parse an EDI X12 document into one of 2 possible XML formats and from either XML format back into X12.
The first XML format is a generic XML structure with an edi-document root.  The document is then broken down into its constituent segments, fields, components and sub-components.
The second XML format is an extension of the generic XML structure that includes specialized parsing for the standard Interchange, Functional Group and Transaction set elements.
This format also includes an edi-document root, but then contains an interchange element that contains one or more function-groups which in turn contains one or more transaction sets.
Each transaction set is then broken down into the standard segment/field/component/sub-component elements.

Once parsed into XML, business and format specific XSL transforms can be applied to convert and add meaning to the contents.

# Usage Examples
## Convert EDI X12 to a generic XML document
```
xquery version "1.0-ml";
import module namespace epx = "http://edi4ml/parser/xml" at "/modules/edi-parser/edi-parser-xml.xqy";

let $doc := fn:document-get("/tmp/myEDIdoc.edi")
return epx:edi-to-xml($doc, (), (), (), (), fn:false())
```
## Convert EDI X12 to generic XML with handling for Interchange, Functional Groups and Transaction Sets
```
xquery version "1.0-ml";
import module namespace epx = "http://edi4ml/parser/xml" at "/modules/edi-parser/edi-parser-xml.xqy";

let $doc := fn:document-get("/tmp/myEDIdoc.edi")
return epx:edi-to-xml($doc, (), (), (), (), fn:true())
```
## Convert EDI formatted XML to EDI X12
```
xquery version "1.0-ml";
import module namespace epx = "http://edi4ml/parser/xml" at "/modules/edi-parser/edi-parser-xml.xqy";

epx:xml-to-edi(fn:doc("/data/myEDI-XMdoc.xml"))
```
# API Documentation
## epx:edi-to-xml($document, $segment, $field, $component, $subcomponent, $parse-headers)
###Parameters:
`$document - The EDI x12 document that will be parsed`
`$segment - Optional segment delimiter.  Defaults to ~`
`$field - Optional field delimiter.  Defaults to *`
`$component - Optional component delimiter.  Defaults to :`
`$subcomponent - Optional sub-component delimiter.  Not used by default and is blank` 
`$parse-headers - Applies parsing for Interchange, Functional Groups and Transaction Sets when true`
###Returns: 
`element(xs:QName("http://edi4ml/edi/xml#", "edi-document")`
## xml-to-edi($xml)
###Parameters:
`$xml - The root edi-document element and its children`
###Returns: 
`EDI ASC X12 formatted text`
## Generic EDI XML format
The basic EDI XML format.
`
<edi-document xmlns="http://edi4ml/edi/xml#>
  <delimiters>
    <!-- Delimiters used to parse/build the EDI X12 document -->
    <delimiter type="field">*</delimiter>
    <delimiter type="segment">~</delimiter>
    <delimiter type="component">:</delimiter>
  </delimiters>
  <segments count="10">
    <!-- Content from EDI X12 document is broken down here -->
    <segment index="1">
      <!-- index is the position of the segment in the original EDI document -->
      <segment-identifier>ISA</segment-identifier>
      <ex:fields count="16">
        <!-- The individual fields that make up a segment go here.
             Empty fields are included as blanks. 
             Each field has an index attribute which is the position
               of the field within the segment.  -->
        <field index="1">00</field>
        <field index="2">  </field>
        <field index="3">
          <!-- Fields may be broken down into components or repeating elements.
               Like fields each component has an index that indicates its position in the field.
               Empty components are included as blanks -->
          <components count="3">
            <component index="1">abcd</component>
            <component index="2">  </component>
            <component index="3">
              <!-- Components can be broken down into sub-components.
                   These behave like components and fields. -->
              <sub-components count="1">
                <sub-component index="1">xyz</sub-component>
              </sub-components>
            </component>
          </components>
        </field>
        ....
      </fields>          
    </segment>
    ....
  </segments>
</edi-document>
`
## Parsed EDI XML format
Similar to the basic EDI format, this includes special handling for the interchange, functional group and transaction set elements common in all EDI X12 documents.
The standard segment/field/component/sub-component constructs exist within each transaction set.
`
<edi-document xmlns="http://edi4ml/edi/xml#>
  <delimiters>
    <!-- Delimiters used to parse/build the EDI X12 document -->
    <delimiter type="field">*</delimiter>
    <delimiter type="segment">~</delimiter>
    <delimiter type="component">:</delimiter>
  </delimiters>
  <interchanges count="1">
    <interchange start-index="1" end-index="10">
      <!-- There is one interchange for each ISA/IEA pair in the
           EDI document.  
           start-index is the position of the ISA segment
           end-index is the position of the IEA segment -->             
      <control-number>12345</control-number>
      <control-version>123</control-version>
      <authorization>
        <qualifier>00</qualifier>
        <information> </information>
      </authorization>
      <security>
        <qualifier>00</qualifier>
        <information> </information>
      </security>
      <sender>
        <qualifier>00</qualifier>
        <identifier> </identifier>
      </sender>
      <receiver>
        <qualifier>00</qualifier>
        <information> </information>
      </receiver>
      <interchange-date>150101</interchange-date>
      <interchange-time>1335</interchange-time>
      <standard-identifier>^</standard-identifier>
      <acknowledgement-required>0</acknowledgement-required>
      <usage-indicator>P</usage-indicator>
      <component-separator>:</component-separator>
      <functional-groups count="1">
        <!-- functional groups contained in the interchange.
             These are the GS/GE pairs -->
        <functional-group start-index="2" end-index="9">
          <control-number>1</control-number>
          <functional-code>FA</functional-code>
          <application-sender>12345</application-sender>
          <application-receiver>abcdef</application-receiver>
          <date-format>20150101</dateformat>
          <time-format>13350701</time-format>
          <responsible-agency-code>X</responsible-agency-code>
          <document-identifier>9876</document-identifier>
          <transaction-sets count="1">
            <!-- a functional group may contain 1 or more transaction sets.
                 each set corresponds to a ST/SE pair -->
            <transaction-set start-index="3" end-index="8">
              <id>123</id>
              <control-number>12345</control-number>
              <document-identifier>abcd</document-identifier>
              <segments count="4">
                <!-- Segments contained within the transaction set.
                     These follow the same pattern as the segments
                     in the generic document above -->
              </segments>
            </transaction-set>
          </transaction-sets>
        </functional-group>
      </functional-groups>
    </interchange>
  </interchanges>
</edi-document>
`
# Installation
## EDI Libraries
The EDI4ML libraries are located in the /src/modules/edi-parser folder.
These libraries can be added to your code and made accessible to your XQuery modules via the following import statement:
import module namespace epx = "http://edi4ml/parser/xml" at "/modules/edi-parser/edi-parser-xml.xqy";
## Roxy Test Framework
Functionality of the EDI4ML libraries can be verified through a test suite in the Roxy framework.
*Edit the deploy/build.properties file with the username, password and ports specific to your environment.
*Then configure your test instance by running ml local bootstrap
*Then deploy your modules and content by running `ml local deploy modules` and `ml local deploy content`
*Open a browser to your test instance `http://localhost:9120/test/`
*Deselect all except for edi-parser-commons and edi-parser-xml
*Press `Run Tests`
# Contributors
# License
Roxy is destributed under the Apache license.
There is currently no license for EDI4ML and no warranty.  Use at your own risk.