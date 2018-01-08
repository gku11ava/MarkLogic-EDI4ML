<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:ex="http://edi4ml/edi/xml#">
  <xsl:variable name="segments" select="/ex:edi-document/ex:segments"/>
  <xsl:key name="segment-identifier" match="ex:segment" use="ex:segment-identifier"/>
  <xsl:template match="/">
    <xsl:element name="rail-carrier-shipment" namespace="http://edi4ml/edi/common#">
      <xsl:for-each select="key('segment-identifier', 'ISA')">
        <xsl:variable name="control-number" select="./ex:fields/ex:field[@ex:index=13]"/>
        <xsl:variable name="end-segment" select="key('segment-identifier', 'IEA')[./ex:fields/ex:field[./@ex:index=2] = $control-number]"/>
        <xsl:call-template name="parse-interchange">
          <xsl:with-param name="header" select="."/>
          <xsl:with-param name="footer" select="$end-segment"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="parse-interchange">
    <xsl:param name="header"/>
    <xsl:param name="footer"/>
    <xsl:element name="interchange" namespace="http://edi4ml/edi/common#">
      <xsl:element name="authorization" namespace="http://edi4ml/edi/common#">
        <xsl:element name="qualifier" namespace="http://edi4ml/edi/common#">
          <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=1]"/>
        </xsl:element>
        <xsl:if test="$header/ex:fields/ex:field[./@ex:index=1] != '00'">
          <xsl:element name="information" namespace="http://edi4ml/edi/common#">
            <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=2]"/>
          </xsl:element>
        </xsl:if>
      </xsl:element>
      <xsl:element name="security" namespace="http://edi4ml/edi/common#">
        <xsl:element name="qualifier" namespace="http://edi4ml/edi/common#">
          <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=3]"/>
        </xsl:element>
        <xsl:if test="$header/ex:fields/ex:field[./@ex:index=3] != '00'">
          <xsl:element name="information" namespace="http://edi4ml/edi/common#">
            <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=4]"/>
          </xsl:element>
        </xsl:if>
      </xsl:element>
      <xsl:element name="sender" namespace="http://edi4ml/edi/common#">
        <xsl:element name="qualifier" namespace="http://edi4ml/edi/common#">
          <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=5]"/>
        </xsl:element>
        <xsl:if test="$header/ex:fields/ex:field[./@ex:index=5] != '00'">
          <xsl:element name="information" namespace="http://edi4ml/edi/common#">
            <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=6]"/>
          </xsl:element>
        </xsl:if>
      </xsl:element>
      <xsl:element name="receiver" namespace="http://edi4ml/edi/common#">
        <xsl:element name="qualifier" namespace="http://edi4ml/edi/common#">
          <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=7]"/>
        </xsl:element>
        <xsl:element name="information" namespace="http://edi4ml/edi/common#">
          <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=8]"/>
        </xsl:element>
      </xsl:element>
      <xsl:element name="format" namespace="http://edi4ml/edi">
        <xsl:element name="interchange-date" namespace="http://edi4ml/edi/common#">
          <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=9]"/>
        </xsl:element>
        <xsl:element name="interchange-time" namespace="http://edi4ml/edi/common#">
          <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=10]"/>
        </xsl:element>
        <xsl:element name="component-separator" namespace="http://edi4ml/edi/common#">
          <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=16]"/>
        </xsl:element>
      </xsl:element>
      <xsl:element name="interchange-standard" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=11]"/>
      </xsl:element>
      <xsl:element name="control-version" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=12]"/>
      </xsl:element>
      <xsl:element name="control-number" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=13]"/>
      </xsl:element>
      <xsl:element name="acknowledgement-required" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=14]"/>
      </xsl:element>
      <xsl:element name="usage" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=15]"/>
      </xsl:element>
      <xsl:element name="functional-groups" namespace="http://edi4ml/edi/common#">
        <xsl:attribute name="count">
          <xsl:value-of select="$footer/ex:fields/ex:field[./@ex:index=1]"/>
        </xsl:attribute>
        <xsl:for-each select="key('segment-identifier', 'GS')[./@ex:index/number(.) lt number($footer/@ex:index) and 
            ./@ex:index/number(.) gt number($header/@ex:index) ]">
          <xsl:variable name="control-number" select="./ex:fields/ex:field[./@ex:index=6]"/>
          <xsl:variable name="end-segment" select="key('segment-identifier', 'GE')[./ex:fields/ex:field[./@ex:index=2] = $control-number]"/>
          <xsl:call-template name="parse-group">
            <xsl:with-param name="group-header" select="."/>
            <xsl:with-param name="group-trailer" select="$end-segment"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="parse-group">
    <xsl:param name="group-header"/>
    <xsl:param name="group-trailer"/>
    <xsl:element name="group" namespace="http://edi4ml/edi/common#">
      <xsl:element name="functional-code" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$group-header/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="sender" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$group-header/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
      <xsl:element name="receiver" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$group-header/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
      <xsl:element name="date-format" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$group-header/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
      <xsl:element name="time-format" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$group-header/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
      <xsl:element name="control-number" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$group-header/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
      <xsl:element name="responsible-agency" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$group-header/ex:fields/ex:field[./@ex:index=7]"/>
      </xsl:element>
      <xsl:element name="document-identifier" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$group-header/ex:fields/ex:field[./@ex:index=8]"/>
      </xsl:element>
      <xsl:element name="transaction-sets" namespace="http://edi4ml/edi/common#">
        <xsl:attribute name="count">
          <xsl:value-of select="$group-trailer/ex:fields/ex:field[./@ex:index=1]"/>
        </xsl:attribute>
        <xsl:for-each select="key('segment-identifier', 'ST')[./@ex:index/number(.) lt $group-trailer/@ex:index/number(.) 
            and ./@ex:index/number(.) gt number($group-header/@ex:index)]">
          <xsl:variable name="control-number" select="./ex:fields/ex:field[./@ex:index=2]"/>
          <xsl:variable name="end-segment" select="key('segment-identifier', 'SE')[./ex:fields/ex:field[./@ex:index=2] = $control-number]"/>
          <xsl:call-template name="parse-set">
            <xsl:with-param name="set-header" select="."/>
            <xsl:with-param name="set-trailer" select="$end-segment"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="parse-set">
    <xsl:param name="set-header"/>
    <xsl:param name="set-trailer"/>
    <xsl:element name="transaction-set" namespace="http://edi4ml/edi/common#">
      <xsl:element name="transaction-id" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$set-header/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="control-number" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$set-header/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
      <xsl:element name="document-identifier" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$set-header/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
      <!--  Begin Format Specific Handling Here -->
      <xsl:for-each select="key('segment-identifier', 'ZC1')">
        <xsl:call-template name="ZC1">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
	  <xsl:for-each select="key('segment-identifier', 'BX')">
        <xsl:call-template name="BX">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
	  <xsl:for-each select="key('segment-identifier', 'BNX')">
        <xsl:call-template name="BNX">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
	  <xsl:for-each select="key('segment-identifier', 'M3')">
        <xsl:call-template name="M3">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
	  <xsl:for-each select="key('segment-identifier', 'N9')">
        <xsl:call-template name="N9">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
	  <xsl:for-each select="key('segment-identifier', 'CM')">
        <xsl:call-template name="CM">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
	  <xsl:for-each select="key('segment-identifier', 'M1')">
        <xsl:call-template name="M1">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
	  <xsl:for-each select="key('segment-identifier', 'DTM')">
        <xsl:call-template name="DTM">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
	  <xsl:for-each select="key('segment-identifier', 'N7')">
        <xsl:call-template name="N7-Loop">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
      <xsl:for-each select="key('segment-identifier', 'NA')">
        <xsl:call-template name="NA">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
	  <xsl:for-each select="key('segment-identifier', 'F9')">
        <xsl:call-template name="F9">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
	  <xsl:for-each select="key('segment-identifier', 'D9')">
        <xsl:call-template name="D9">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
	  <xsl:for-each select="key('segment-identifier', 'N1')">
        <xsl:call-template name="N1-Loop">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
	  <xsl:for-each select="key('segment-identifier', 'S1')">
        <xsl:call-template name="S1-Loop">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
	  <xsl:for-each select="key('segment-identifier', 'R2')">
        <xsl:call-template name="R2">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
	  <xsl:for-each select="key('segment-identifier', 'R9')">
        <xsl:call-template name="R9">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
	  <xsl:for-each select="key('segment-identifier', 'E1')">
        <xsl:call-template name="E1-Loop">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
	  <xsl:for-each select="key('segment-identifier', 'H3')">
        <xsl:call-template name="H3">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
	  <xsl:for-each select="key('segment-identifier', 'PS')">
        <xsl:call-template name="PS">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
	  <xsl:for-each select="key('segment-identifier', 'LX')">
        <xsl:call-template name="LX-Loop">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
	  <xsl:for-each select="key('segment-identifier', 'T1')">
        <xsl:call-template name="T1-Loop">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
	  <xsl:for-each select="key('segment-identifier', 'L3')">
        <xsl:call-template name="L3">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
	  <xsl:for-each select="key('segment-identifier', 'LS')">
        <xsl:call-template name="LS-Loop">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
	  <xsl:for-each select="key('segment-identifier', 'PER')">
        <xsl:call-template name="PER">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
	  <xsl:for-each select="key('segment-identifier', 'LH2')">
        <xsl:call-template name="LH2">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
	  <xsl:for-each select="key('segment-identifier', 'LHR')">
        <xsl:call-template name="LHR">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
	  <xsl:for-each select="key('segment-identifier', 'LH6')">
        <xsl:call-template name="LH6">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
	  <xsl:for-each select="key('segment-identifier', 'XH')">
        <xsl:call-template name="XH">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
	  <xsl:for-each select="key('segment-identifier', 'X7')">
        <xsl:call-template name="X7">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="ZC1">
    <xsl:param name="segment"/>
    <xsl:variable name="segment-index" select="./@ex:index"/>
    <xsl:element name="data-correction" namespace="http://edi4ml/edi/701#">
      <xsl:element name="shipment-id" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="equipment-initial" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
      <xsl:element name="equipment-number" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
      <xsl:element name="transaction-ref-number" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
      <xsl:element name="transaction-ref-date" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
	  <xsl:element name="correction-indicator" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
	  <xsl:element name="standard-carrier-alpha-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=7]"/>
      </xsl:element>
	  <xsl:element name="transportation-type-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=8]"/>
      </xsl:element>
	  <xsl:element name="equipment-number-check-digit" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=9]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="BX">
    <xsl:param name="segment"/>
    <xsl:variable name="segment-index" select="./@ex:index"/>
    <xsl:element name="general-shipment-info" namespace="http://edi4ml/edi/701#">
      <xsl:element name="tx-set-purpose-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="transportation-type-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
      <xsl:element name="shipment-payment-method" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
      <xsl:element name="shipment-id-number" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
      <xsl:element name="standard-carrier-alpha-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
	  <xsl:element name="weight-unit-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
	  <xsl:element name="shipment-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=7]"/>
      </xsl:element>
	  <xsl:element name="section-seven-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=8]"/>
      </xsl:element>
	  <xsl:element name="capacity-load-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=9]"/>
      </xsl:element>
	  <xsl:element name="customs-doc-handling-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=11]"/>
      </xsl:element>
	  <xsl:element name="confidential-billing-request-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=12]"/>
      </xsl:element>
	  <xsl:element name="goods-and-services-tax-reason-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=13]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="BNX">
    <xsl:param name="segment"/>
    <xsl:variable name="segment-index" select="./@ex:index"/>
    <xsl:element name="rail-shipment-info" namespace="http://edi4ml/edi/701#">
      <xsl:element name="shipment-wt-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="ref-pattern-id" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
      <xsl:element name="billing-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
      <xsl:element name="repetitive-pattern-number" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="M3">
    <xsl:param name="segment"/>
    <xsl:variable name="segment-index" select="./@ex:index"/>
    <xsl:element name="release" namespace="http://edi4ml/edi/701#">
      <xsl:element name="release-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="date" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
      <xsl:element name="time" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
      <xsl:element name="time-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="N9">
    <xsl:param name="segment"/>
    <xsl:variable name="segment-index" select="./@ex:index"/>
    <xsl:element name="extended-ref-ident" namespace="http://edi4ml/edi/701#">
      <xsl:element name="ref-id-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="ref-id" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
      <xsl:element name="description" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
      <xsl:element name="date" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
      <xsl:element name="time" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
      <xsl:element name="time-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="CM">
    <xsl:param name="segment"/>
    <xsl:variable name="segment-index" select="./@ex:index"/>
    <xsl:element name="cargo-manifest" namespace="http://edi4ml/edi/701#">
      <xsl:element name="flight-voyage-num" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="port-terminal-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
      <xsl:element name="port-name" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
      <xsl:element name="date" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="booking-num" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
	  <xsl:element name="current-standard-carrier-alpha-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
	  <xsl:element name="previous-standard-carrier-alpha-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=7]"/>
      </xsl:element>
	  <xsl:element name="manifest-date" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=8]"/>
      </xsl:element>
	  <xsl:element name="vessel-name" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=9]"/>
      </xsl:element>
	  <xsl:element name="pier-number" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=10]"/>
      </xsl:element>
	  <xsl:element name="pier-name" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=11]"/>
      </xsl:element>
	  <xsl:element name="terminal-name" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=12]"/>
      </xsl:element>
	  <xsl:element name="state-or-province-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=13]"/>
      </xsl:element>
	  <xsl:element name="country-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=14]"/>
      </xsl:element>
	  <xsl:element name="vessel-agent-num" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=15]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="M1">
    <xsl:param name="segment"/>
    <xsl:variable name="segment-index" select="./@ex:index"/>
    <xsl:element name="insurance" namespace="http://edi4ml/edi/701#">
      <xsl:element name="country-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="carriage-value" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
      <xsl:element name="declared-value" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
      <xsl:element name="rate-value-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="entity-id-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
	  <xsl:element name="message" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
	  <xsl:element name="rate-value-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=7]"/>
      </xsl:element>
	  <xsl:element name="monetary-amount" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=8]"/>
      </xsl:element>
	  <xsl:element name="percent-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=9]"/>
      </xsl:element>
	  <xsl:element name="percent" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=10]"/>
      </xsl:element>
	  <xsl:element name="percent-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=11]"/>
      </xsl:element>
	  <xsl:element name="percent" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=12]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="DTM">
    <xsl:param name="segment"/>
    <xsl:element name="date-time-reference" namespace="http://edi4ml/edi/701#">
      <xsl:element name="date-time-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="date" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="time" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="time-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="N7-Loop">
    <xsl:param name="segment"/>
    <xsl:variable name="segment-index" select="./@ex:index"/>
    <xsl:variable name="next-index" select="min($segments/ex:segment[(./ex:segment-identifier='NA' or
      ./ex:segment-identifier = 'F9' or ./ex:segment-identifier='D9' or
	  ./ex:segment-identifier = 'N7') and 
      ./@ex:index/number(.) gt number($segment/@ex:index)]/@ex:index)"/>
    <xsl:element name="equipment-details" namespace="http://edi4ml/edi/701#">
      <xsl:element name="equipment-initial" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="equipment-number" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
      <xsl:element name="weight" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
      <xsl:element name="weight-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
      <xsl:element name="tare-weight" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
      <xsl:element name="weight-allowance" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
	  <xsl:element name="dunnage" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=7]"/>
      </xsl:element>
	  <xsl:element name="ownership-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=10]"/>
      </xsl:element>
	  <xsl:element name="equipment-description-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=11]"/>
      </xsl:element>
	  <xsl:element name="owner-standard-carrier-alpha-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=12]"/>
      </xsl:element>
	  <xsl:element name="position" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=14]"/>
      </xsl:element>
	  <xsl:element name="equipment-length" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=15]"/>
      </xsl:element>
	  <xsl:element name="tare-qualifier-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=16]"/>
      </xsl:element>
	  <xsl:element name="equipment-number-check-digit" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=18]"/>
      </xsl:element>
	  <xsl:element name="height" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=20]"/>
      </xsl:element>
	  <xsl:element name="width" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=21]"/>
      </xsl:element>
	  <xsl:element name="equipment-type" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=22]"/>
      </xsl:element>
	  <xsl:element name="operator-standard-carrier-alpha-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=23]"/>
      </xsl:element>
	  <xsl:element name="car-type-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=24]"/>
      </xsl:element>
      <xsl:for-each select="$segments/ex:segment[./@ex:index/number(.) lt $next-index and
        ./@ex:index/number(.) gt number($segment/@ex:index)]">
        <xsl:choose>
          <xsl:when test="./ex:segment-identifier='EM'">
            <xsl:call-template name="EM">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="./ex:segment-identifier='VC'">
            <xsl:call-template name="N7-VC-Loop">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='M7'">
            <xsl:call-template name="M7">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='N5'">
            <xsl:call-template name="N5">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='IC'">
            <xsl:call-template name="IC">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='IM'">
            <xsl:call-template name="IM">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='M12'">
            <xsl:call-template name="M12">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='E1'">
            <xsl:call-template name="N7-E1-Loop">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='GA'">
            <xsl:call-template name="GA">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='REF'">
            <xsl:call-template name="N7-REF-Loop">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise/>
        </xsl:choose>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>
  
  <!-- N7 Loop Segments -->
  <xsl:template name="EM">
    <xsl:param name="segment"/>
    <xsl:element name="equipment-characteristics" namespace="http://edi4ml/edi/701#">
      <xsl:element name="weight-unit-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="weight" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="volume-unit-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="volume" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="country-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
	  <xsl:element name="construct-type" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
	  <xsl:element name="inspection-date" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=7]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="N7-VC-Loop">
    <xsl:param name="segment"/>
    <xsl:variable name="segment-index" select="./@ex:index"/>
    <xsl:variable name="next-index" select="min($segments/ex:segment[(./ex:segment-identifier='M7' or
      ./ex:segment-identifier = 'N5' or ./ex:segment-identifier='IC' or ./ex:segment-identifier='IM' or
	  ./ex:segment-identifier='M12' or ./ex:segment-identifier='E1' or ./ex:segment-identifier='GA' or 
	  ./ex:segment-identifier='REF' or ./ex:segment-identifier='NA' or ./ex:segment-identifier='F9' or
	  ./ex:segment-identifier='D9' or ./ex:segment-identier='VC') and 
      ./@ex:index/number(.) gt number($segment/@ex:index)]/@ex:index)"/>
    <xsl:element name="motor-vehicle-control" namespace="http://edi4ml/edi/701#">
      <xsl:element name="vehicle-id-num" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="deck-position-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
      <xsl:element name="vehicle-type-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
      <xsl:element name="dealer-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
      <xsl:element name="route-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
      <xsl:element name="factory-car-order-num" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=10]"/>
      </xsl:element>
	  <xsl:element name="equipment-orientation" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=12]"/>
      </xsl:element>
	  <xsl:element name="location-identifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=13]"/>
      </xsl:element>
      <xsl:for-each select="$segments/ex:segment[./@ex:index/number(.) lt $next-index and
        ./@ex:index/number(.) gt number($segment/@ex:index)]">
        <xsl:choose>
          <xsl:when test="./ex:segment-identifier='N1'">
            <xsl:call-template name="N7-VC-N1-Loop">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise/>
        </xsl:choose>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="N7-VC-N1-Loop">
    <xsl:param name="segment"/>
	<xsl:variable name="segment-index" select="./@ex:index"/>
    <xsl:variable name="next-index" select="min($segments/ex:segment[(./ex:segment-identifier='M7' or
      ./ex:segment-identifier = 'N5' or ./ex:segment-identifier='IC' or ./ex:segment-identifier='IM' or
	  ./ex:segment-identifier='M12' or ./ex:segment-identifier='E1' or ./ex:segment-identifier='GA' or 
	  ./ex:segment-identifier='REF' or ./ex:segment-identifier='NA' or ./ex:segment-identifier='F9' or
	  ./ex:segment-identifier='D9' or ./ex:segment-identifier='N1') and 
      ./@ex:index/number(.) gt number($segment/@ex:index)]/@ex:index)"/>
    <xsl:element name="party-identification" namespace="http://edi4ml/edi/701#">
      <xsl:call-template name="N1-body">
	    <xsl:with-param name="segment" select="."/>
	  </xsl:call-template>
	  <xsl:for-each select="$segments/ex:segment[./@ex:index/number(.) lt $next-index and
        ./@ex:index/number(.) gt number($segment/@ex:index)]">
        <xsl:choose>
          <xsl:when test="./ex:segment-identifier='N3'">
            <xsl:call-template name="N3">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='N4'">
            <xsl:call-template name="N4">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='H3'">
            <xsl:call-template name="H3">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise/>
        </xsl:choose>
      </xsl:for-each>
	</xsl:element>
  </xsl:template>
  
  <xsl:template name="N3">
    <xsl:param name="segment"/>
    <xsl:element name="party-location" namespace="http://edi4ml/edi/701#">
      <xsl:element name="weight-unit-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="address-information" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="additional-address-information" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="N4">
    <xsl:param name="segment"/>
    <xsl:element name="geographic-location" namespace="http://edi4ml/edi/701#">
      <xsl:element name="city-name" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="state-or-province-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="postal-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="country-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="location-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
	  <xsl:element name="location-identifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="H3">
    <xsl:param name="segment"/>
    <xsl:element name="special-handling-instructions" namespace="http://edi4ml/edi/701#">
      <xsl:element name="special-handle-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template name="M7">
    <xsl:param name="segment"/>
    <xsl:element name="seal-numbers" namespace="http://edi4ml/edi/701#">
      <xsl:element name="seal-number" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="seal-number" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="seal-number" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="seal-number" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="N5">
    <xsl:param name="segment"/>
    <xsl:element name="equipment-ordered" namespace="http://edi4ml/edi/701#">
      <xsl:element name="equipment-length" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="weight-capacity" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="cubic-capacity" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="car-type-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="height" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="IC">
    <xsl:param name="segment"/>
    <xsl:element name="intermodal-chassis-equipment" namespace="http://edi4ml/edi/701#">
      <xsl:element name="equipment-initial" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="equipment-number" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="tare-weight" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="tare-qualifier-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="owner-standard-carrier-alpha-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
	  <xsl:element name="equipment-length" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
	  <xsl:element name="lessee-standard-carrier-alpha-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=7]"/>
      </xsl:element>
	  <xsl:element name="chassis-type" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=8]"/>
      </xsl:element>
	  <xsl:element name="equipment-check-digit" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=9]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="IM">
    <xsl:param name="segment"/>
    <xsl:element name="intermodal-movement-info" namespace="http://edi4ml/edi/701#">
      <xsl:element name="water-move-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="special-handling-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="inland-transportation-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="M12">
    <xsl:param name="segment"/>
    <xsl:element name="in-bond-identifying-info" namespace="http://edi4ml/edi/701#">
      <xsl:element name="customs-entry-type-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="customs-entry-number" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="location-identifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="location-identifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="customs-shipment-value" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
	  <xsl:element name="in-bond-control-number" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
	  <xsl:element name="ref-id-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=8]"/>
      </xsl:element>
	  <xsl:element name="ref-id" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=9]"/>
      </xsl:element>
	  <xsl:element name="transport-type-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=10]"/>
      </xsl:element>
	  <xsl:element name="vessel-name" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=11]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="N7-E1-Loop">
    <xsl:param name="segment"/>
	<xsl:variable name="segment-index" select="./@ex:index"/>
    <xsl:variable name="next-index" select="min($segments/ex:segment[(./ex:segment-identifier='E1' or
      ./ex:segment-identifier = 'GA' or ./ex:segment-identifier='REF' or ./ex:segment-identifier='NA' or
	  ./ex:segment-identifier='F9' or ./ex:segment-identifier='D9') and 
      ./@ex:index/number(.) gt number($segment/@ex:index)]/@ex:index)"/>
    <xsl:element name="empty-car-disposition" namespace="http://edi4ml/edi/701#">
	  <xsl:element name="pended-destination-city" namespace="http://edi4ml/edi/701#">
        <xsl:element name="name" namespace="http://edi4ml/edi/701#">
          <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
        </xsl:element>
        <xsl:element name="id-code-qualifier" namespace="http://edi4ml/edi/701#">
          <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
        </xsl:element>
	    <xsl:element name="id-code" namespace="http://edi4ml/edi/701#">
          <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
        </xsl:element>
      </xsl:element>
	  <xsl:for-each select="$segments/ex:segment[./@ex:index/number(.) lt $next-index and
          ./@ex:index/number(.) gt number($segment/@ex:index)]">
          <xsl:choose>
            <xsl:when test="./ex:segment-identifier='E4'">
              <xsl:call-template name="E4">
                <xsl:with-param name="segment" select="."/>
              </xsl:call-template>
            </xsl:when>
		    <xsl:when test="./ex:segment-identifier='E5'">
              <xsl:call-template name="E5">
                <xsl:with-param name="segment" select="."/>
              </xsl:call-template>
            </xsl:when>
		    <xsl:when test="./ex:segment-identifier='PI'">
              <xsl:call-template name="PI">
                <xsl:with-param name="segment" select="."/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise/>
          </xsl:choose>
        </xsl:for-each>
      </xsl:element>
  </xsl:template>
  
  <xsl:template name="E4">
    <xsl:param name="segment"/>
    <xsl:element name="pended-destination-city" namespace="http://edi4ml/edi/701#">
      <xsl:element name="city-name" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="state-or-province-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="postal-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="country-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="address-information" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="E5">
    <xsl:param name="segment"/>
    <xsl:element name="pended-destination-route" namespace="http://edi4ml/edi/701#">
      <xsl:element name="standard-carrier-alpha-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="routing-sequence-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="city-name" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="standard-point-location-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="GA">
    <xsl:param name="segment"/>
    <xsl:element name="canadian-grain-info" namespace="http://edi4ml/edi/701#">
      <xsl:element name="fumigated-cleaned-indicator" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="commodity-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="inspected-weighed-indicator-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="ref-id-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="ref-id" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
	  <xsl:element name="crop-week" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
	  <xsl:element name="unload-terminal-elevator-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=7]"/>
      </xsl:element>
	  <xsl:element name="unload-date" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=8]"/>
      </xsl:element>
	  <xsl:element name="number-of-cars-claimed" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=9]"/>
      </xsl:element>
	  <xsl:element name="machine-separable-indicator-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=10]"/>
      </xsl:element>
	  <xsl:element name="cwb-market-class-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=11]"/>
      </xsl:element>
	  <xsl:element name="cwb-market-type-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=12]"/>
      </xsl:element>
	  <xsl:element name="yes-no-condition-response-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=13]"/>
      </xsl:element>
	  <xsl:element name="location-identifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=14]"/>
      </xsl:element>
	  <xsl:element name="state-or-province-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=15]"/>
      </xsl:element>
	  <xsl:element name="percent-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=16]"/>
      </xsl:element>
	  <xsl:element name="percent" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=17]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="N7-REF-Loop">
    <xsl:param name="segment"/>
	<xsl:variable name="segment-index" select="./@ex:index"/>
    <xsl:variable name="next-index" select="min($segments/ex:segment[(./ex:segment-identifier='REF' or
      ./ex:segment-identifier = 'NA' or ./ex:segment-identifier='F9' or ./ex:segment-identifier='D9') and 
      ./@ex:index/number(.) gt number($segment/@ex:index)]/@ex:index)"/>
    <xsl:element name="reference-information" namespace="http://edi4ml/edi/701#">
      <xsl:element name="ref-id-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="ref-id" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="description" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="ref-id-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:for-each select="$segments/ex:segment[./@ex:index/number(.) lt $next-index and
        ./@ex:index/number(.) gt number($segment/@ex:index)]">
        <xsl:choose>
          <xsl:when test="./ex:segment-identifier='N9'">
            <xsl:call-template name="N9">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='N10'">
            <xsl:call-template name="N10">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='SMD'">
            <xsl:call-template name="SMD">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='VC'">
            <xsl:call-template name="N7-REF-VC">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='L0'">
            <xsl:call-template name="N7-REF-L0-Loop">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='N1'">
            <xsl:call-template name="N7-REF-N1-Loop">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise/>
        </xsl:choose>
      </xsl:for-each>
	</xsl:element>
  </xsl:template>
    
  <xsl:template name="N10">
    <xsl:param name="segment"/>
    <xsl:element name="quantity-and-description" namespace="http://edi4ml/edi/701#">
      <xsl:element name="quantity" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="description" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="marks-and-numbers" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="commodity-code-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="commodity-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
	  <xsl:element name="customs-shipment-value" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
	  <xsl:element name="weight-unit-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=7]"/>
      </xsl:element>
	  <xsl:element name="weight" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=8]"/>
      </xsl:element>
	  <xsl:element name="ref-id" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=9]"/>
      </xsl:element>
	  <xsl:element name="manifest-unit-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=10]"/>
      </xsl:element>
	  <xsl:element name="manufacturing-country-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=11]"/>
      </xsl:element>
	  <xsl:element name="destination-country-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=12]"/>
      </xsl:element>
	  <xsl:element name="currency-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=13]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="SMD">
    <xsl:param name="segment"/>
    <xsl:element name="consolidated-shipment-manifest" namespace="http://edi4ml/edi/701#">
      <xsl:element name="service-level-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="shipment-payment-method" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="pickup-or-delivery-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="N7-REF-VC">
    <xsl:param name="segment"/>
    <xsl:variable name="segment-index" select="./@ex:index"/>
    <xsl:element name="motor-vehicle-control" namespace="http://edi4ml/edi/701#">
      <xsl:element name="vehicle-id-num" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="deck-position-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
      <xsl:element name="vehicle-type-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
      <xsl:element name="dealer-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
      <xsl:element name="route-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
      <xsl:element name="bay-location" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
	  <xsl:element name="auto-mfr-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=7]"/>
      </xsl:element>
	  <xsl:element name="damage-exception-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=8]"/>
      </xsl:element>
	  <xsl:element name="supplement-inspection-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=9]"/>
      </xsl:element>
	  <xsl:element name="factory-car-order-num" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=10]"/>
      </xsl:element>
	  <xsl:element name="vessel-stowage-location" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=11]"/>
      </xsl:element>
	  <xsl:element name="equipment-orientation" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=12]"/>
      </xsl:element>
	  <xsl:element name="location-identifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=13]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="N7-REF-L0-Loop">
    <xsl:param name="segment"/>
	<xsl:variable name="segment-index" select="./@ex:index"/>
    <xsl:variable name="next-index" select="min($segments/ex:segment[(./ex:segment-identifier='L0' or
      ./ex:segment-identifier = 'NA' or ./ex:segment-identifier='F9' or ./ex:segment-identifier='D9' or
	  ./ex:segment-identifier = 'N1') and 
      ./@ex:index/number(.) gt number($segment/@ex:index)]/@ex:index)"/>
    <xsl:element name="line-item" namespace="http://edi4ml/edi/701#">
      <xsl:element name="lading-line-item-num" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="billed-rated-quantity" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="billed-rated-quantity" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="weight" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="weight-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="volume" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="volume-unit-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="lading-quantity" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="packaging-form-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="dunnage-description" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="weight-unit-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="type-of-service-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="quantity" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="packaging-form-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="yes-no-condition-response-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:for-each select="$segments/ex:segment[./@ex:index/number(.) lt $next-index and
        ./@ex:index/number(.) gt number($segment/@ex:index)]">
        <xsl:choose>
          <xsl:when test="./ex:segment-identifier='MEA'">
            <xsl:call-template name="MEA">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='L1'">
            <xsl:call-template name="L1">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='PI'">
            <xsl:call-template name="N7-REF-L0-PI-Loop">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise/>
        </xsl:choose>
      </xsl:for-each>
	</xsl:element>
  </xsl:template>
  
  <xsl:template name="L0">
    <xsl:param name="segment"/>
	<xsl:variable name="segment-index" select="./@ex:index"/>
    <xsl:variable name="next-index" select="min($segments/ex:segment[(./ex:segment-identifier='L0' or
      ./ex:segment-identifier = 'NA' or ./ex:segment-identifier='F9' or ./ex:segment-identifier='D9' or
	  ./ex:segment-identifier = 'N1') and 
      ./@ex:index/number(.) gt number($segment/@ex:index)]/@ex:index)"/>
    <xsl:element name="line-item" namespace="http://edi4ml/edi/701#">
      <xsl:element name="lading-line-item-num" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="billed-rated-quantity" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="billed-rated-quantity" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="weight" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="weight-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="volume" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="volume-unit-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="lading-quantity" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="packaging-form-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="dunnage-description" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="weight-unit-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="type-of-service-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="quantity" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="packaging-form-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="yes-no-condition-response-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:for-each select="$segments/ex:segment[./@ex:index/number(.) lt $next-index and
        ./@ex:index/number(.) gt number($segment/@ex:index)]">
        <xsl:choose>
          <xsl:when test="./ex:segment-identifier='MEA'">
            <xsl:call-template name="MEA">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='L1'">
            <xsl:call-template name="L1">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='PI'">
            <xsl:call-template name="PI">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise/>
        </xsl:choose>
      </xsl:for-each>
	</xsl:element>
  </xsl:template>
  
  <xsl:template name="MEA">
    <xsl:param name="segment"/>
    <xsl:element name="measurements" namespace="http://edi4ml/edi/701#">
      <xsl:element name="measurement-ref-id-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="measurement-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="measurement-value" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="unit-basis-measurement-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="range-minimum" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="range-maximum" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="measurement-sig-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="measurement-attrib-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="layer-position-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="measurement-method" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="code-list-qualifier-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="industry-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	</xsl:element>
  </xsl:template>
  
  <xsl:template name="L1">
    <xsl:param name="segment"/>
    <xsl:element name="rate-and-charges" namespace="http://edi4ml/edi/701#">
      <xsl:element name="lading-line-item-num" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="freight-rate" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="rate-value-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="amount-charged" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="advances" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="prepaid-amount" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="rate-combo-poinnt-count" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="special-charge-allow-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="rate-class-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="entitlement-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="charge-method-of-payment" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="special-charge-description" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="tariff-applied-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="declared-value" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="rate-value-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="lading-liability-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="billed-rated-quantity" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="billed-rated-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="percent" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="currency-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="amount" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="lading-value" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	</xsl:element>
  </xsl:template>
  
  <xsl:template name="N7-REF-L0-PI-Loop">
    <xsl:param name="segment"/>
	<xsl:variable name="segment-index" select="./@ex:index"/>
    <xsl:variable name="next-index" select="min($segments/ex:segment[(./ex:segment-identifier='L0' or
      ./ex:segment-identifier = 'PI' or ./ex:segment-identifier='REF' or ./ex:segment-identifier='N1' or
	  ./ex:segment-identifier = 'NA' or ./ex:segment-identifier='F9') and 
      ./@ex:index/number(.) gt number($segment/@ex:index)]/@ex:index)"/>
    <xsl:element name="price-authority-identification" namespace="http://edi4ml/edi/701#">
	  <xsl:call-template name="PI">
        <xsl:with-param name="segment" select="."/>
      </xsl:call-template>
	  <xsl:for-each select="$segments/ex:segment[./@ex:index/number(.) lt $next-index and
        ./@ex:index/number(.) gt number($segment/@ex:index)]">
        <xsl:choose>
          <xsl:when test="./ex:segment-identifier='CD'">
            <xsl:call-template name="CD">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise/>
        </xsl:choose>
      </xsl:for-each>
	</xsl:element>
  </xsl:template>
  
  <xsl:template name="LX-L0-PI-Loop">
    <xsl:param name="segment"/>
	<xsl:variable name="segment-index" select="./@ex:index"/>
    <xsl:variable name="next-index" select="min($segments/ex:segment[(./ex:segment-identifier='L0' or
      ./ex:segment-identifier = 'PI' or ./ex:segment-identifier='LX' or ./ex:segment-identifier='X1' or
	  ./ex:segment-identifier = 'T1' or ./ex:segment-identifier='L3' or ./ex:segment-identifier='LS' or 
	  ./ex:segment-identifier='SE') and 
      ./@ex:index/number(.) gt number($segment/@ex:index)]/@ex:index)"/>
    <xsl:element name="price-authority-identification" namespace="http://edi4ml/edi/701#">
	  <xsl:call-template name="PI">
        <xsl:with-param name="segment" select="."/>
      </xsl:call-template>
	  <xsl:for-each select="$segments/ex:segment[./@ex:index/number(.) lt $next-index and
        ./@ex:index/number(.) gt number($segment/@ex:index)]">
        <xsl:choose>
          <xsl:when test="./ex:segment-identifier='CD'">
            <xsl:call-template name="CD">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise/>
        </xsl:choose>
      </xsl:for-each>
	</xsl:element>
  </xsl:template>
  
  <xsl:template name="PI">
    <xsl:param name="segment"/>
      <xsl:element name="ref-id-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="ref-id" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="primary-publication-authority" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="regulatory-agency-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="tariff-agency-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="issuing-carrier-id" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="contract-suffix" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="tariff-item-number" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="tariff-supplement-id" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="tariff-section-num" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="contract-suffix" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="effective-date" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="expiration-date" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="alternation-precedence-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="alternation-precedence-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="service-level-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
  </xsl:template>

  <xsl:template name="CD">
    <xsl:param name="segment"/>
    <xsl:element name="shipment-conditions" namespace="http://edi4ml/edi/701#">
      <xsl:element name="condition-segment-logical-connnector" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="condition-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="condition-value" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="condition-value" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="condition-value" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="assigned-number" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="change-type-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="lading-quantity" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="standard-carrier-alpha-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="docket-control-number" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="docket-id" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="group-title" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	</xsl:element>
  </xsl:template>
  
  <xsl:template name="N7-REF-N1-Loop">
    <xsl:param name="segment"/>
	<xsl:variable name="segment-index" select="./@ex:index"/>
    <xsl:variable name="next-index" select="min($segments/ex:segment[(./ex:segment-identifier='N1' or
      ./ex:segment-identifier = 'NA' or ./ex:segment-identifier='F9' or ./ex:segment-identifier='D9') and 
      ./@ex:index/number(.) gt number($segment/@ex:index)]/@ex:index)"/>
    <xsl:element name="party-identification" namespace="http://edi4ml/edi/701#">
      <xsl:element name="entity-id-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="name" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="id-code-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="id-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:for-each select="$segments/ex:segment[./@ex:index/number(.) lt $next-index and
        ./@ex:index/number(.) gt number($segment/@ex:index)]">
        <xsl:choose>
          <xsl:when test="./ex:segment-identifier='N3'">
            <xsl:call-template name="N3">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='N4'">
            <xsl:call-template name="N4">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='PER'">
            <xsl:call-template name="PER">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="./ex:segment-identifier='BL'">
            <xsl:call-template name="BL">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:otherwise/>
        </xsl:choose>
      </xsl:for-each>
	</xsl:element>
  </xsl:template>
  
  <xsl:template name="PER">
    <xsl:param name="segment"/>
    <xsl:element name="admin-comms-contact" namespace="http://edi4ml/edi/701#">
      <xsl:element name="contact-functional-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="contact-name" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="communication" namespace="http://edi4ml/edi/701#">
  	    <xsl:element name="comms-number-qualifier" namespace="http://edi4ml/edi/701#">
          <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
        </xsl:element>
	    <xsl:element name="comms-number" namespace="http://edi4ml/edi/701#">
          <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
        </xsl:element>
	  </xsl:element>
	  <xsl:element name="communication" namespace="http://edi4ml/edi/701#">
  	    <xsl:element name="comms-number-qualifier" namespace="http://edi4ml/edi/701#">
          <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
        </xsl:element>
	    <xsl:element name="comms-number" namespace="http://edi4ml/edi/701#">
          <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
        </xsl:element>
	  </xsl:element>
	  <xsl:element name="communication" namespace="http://edi4ml/edi/701#">
  	    <xsl:element name="comms-number-qualifier" namespace="http://edi4ml/edi/701#">
          <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=7]"/>
        </xsl:element>
	    <xsl:element name="comms-number" namespace="http://edi4ml/edi/701#">
          <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=8]"/>
        </xsl:element>
	  </xsl:element>
	  <xsl:element name="contact-inquiry-ref" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=9]"/>
      </xsl:element>
	</xsl:element>
  </xsl:template>
  
  <xsl:template name="BL"> <!-- Origin and Destination -->
    <xsl:param name="segment"/>
    <xsl:element name="billing-info" namespace="http://edi4ml/edi/701#">
      <xsl:element name="rebill-reason-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="freight-station-accounting-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="freight-station-accounting-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="standard-point-location-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="city-name" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="state-or-province-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="country-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="standard-point-location-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="city-name" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="state-or-province-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="country-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="standard-carrier-alpha-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="standard-carrier-alpha-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="standard-carrier-alpha-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="standard-carrier-alpha-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="standard-carrier-alpha-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="standard-carrier-alpha-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	</xsl:element>
  </xsl:template>
  <!-- End N7 Loop Elements -->
  
  <xsl:template name="NA">
    <xsl:param name="segment"/>
    <xsl:element name="cross-reference-equipment" namespace="http://edi4ml/edi/701#">
      <xsl:element name="ref-id-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="ref-id" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="equipment-initial" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="equipment-number" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="cross-ref-type-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
	  <xsl:element name="position" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
	  <xsl:element name="owner-standard-carrier-alpha-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=7]"/>
      </xsl:element>
	  <xsl:element name="equipment-length" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=8]"/>
      </xsl:element>
	  <xsl:element name="operator-standard-carrier-alpha-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=9]"/>
      </xsl:element>
	  <!--
	  <xsl:element name="chassis-type" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=10]"/>
      </xsl:element>
	  -->
	  <xsl:element name="yes-no-condition-response-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=11]"/>
      </xsl:element>
	  <xsl:element name="equipment-check-digit" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=12]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="F9">
    <xsl:param name="segment"/>
    <xsl:element name="origin-station" namespace="http://edi4ml/edi/701#">
      <xsl:element name="freight-station-accounting-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="ref-id" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="equipment-initial" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="equipment-number" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="cross-ref-type-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
	  <xsl:element name="position" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
	  <xsl:element name="owner-standard-carrier-alpha-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=7]"/>
      </xsl:element>
	  <xsl:element name="equipment-length" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=8]"/>
      </xsl:element>
	  <xsl:element name="operator-standard-carrier-alpha-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=9]"/>
      </xsl:element>
	  <!--
	  <xsl:element name="chassis-type" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=10]"/>
      </xsl:element>
	  -->
	  <xsl:element name="yes-no-condition-response-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=11]"/>
      </xsl:element>
	  <xsl:element name="equipment-check-digit" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=12]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="D9">
    <xsl:param name="segment"/>
    <xsl:element name="destination-station" namespace="http://edi4ml/edi/701#">
      <xsl:element name="freight-station-accounting-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="city-name" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="state-or-province-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <!--
	  <xsl:element name="country-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element> -->
	  <xsl:element name="freight-station-accounting-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
	  <xsl:element name="city-name" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
	  <xsl:element name="state-or-province-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=7]"/>
      </xsl:element>
	  <xsl:element name="standard-point-location-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=8]"/>
      </xsl:element>
	  <xsl:element name="postal-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=9]"/>
      </xsl:element>
	  <xsl:element name="standard-point-location-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=10]"/>
      </xsl:element>
	  <!--
	  <xsl:element name="postal-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=11]"/>
      </xsl:element>
	  <xsl:element name="country-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=12]"/>
      </xsl:element>
	  -->
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="N1-Loop">
    <xsl:param name="segment"/>
	<xsl:variable name="segment-index" select="./@ex:index"/>
    <xsl:variable name="next-index" select="min($segments/ex:segment[(./ex:segment-identifier='S1' or
	  ./ex:segment-identifier='R2' or ./ex:segment-identifier='N1') and 
      ./@ex:index/number(.) gt number($segment/@ex:index)]/@ex:index)"/>
    <xsl:element name="party-identification" namespace="http://edi4ml/edi/701#">
	  <xsl:call-template name="N1-body">
	    <xsl:with-param name="segment" select="."/>
	  </xsl:call-template>
	  <xsl:for-each select="$segments/ex:segment[./@ex:index/number(.) lt $next-index and
        ./@ex:index/number(.) gt number($segment/@ex:index)]">
        <xsl:choose>
          <xsl:when test="./ex:segment-identifier='N2'">
            <xsl:call-template name="N2">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='N3'">
            <xsl:call-template name="N3">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='N4'">
            <xsl:call-template name="N4">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='REF'">
            <xsl:call-template name="REF">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='PER'">
            <xsl:call-template name="PER">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='BL'">
            <xsl:call-template name="BL">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:otherwise/>
        </xsl:choose>
      </xsl:for-each>
	</xsl:element>
  </xsl:template>
  
  <xsl:template name="N1-body">
    <xsl:param name="segment"/>
      <xsl:element name="entity-id-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="name" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="id-code-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="entity-relationship-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element> 
	  <xsl:element name="entity-id-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
  </xsl:template>
  
  <xsl:template name="S1-Loop">
    <xsl:param name="segment"/>
	<xsl:variable name="segment-index" select="./@ex:index"/>
    <xsl:variable name="next-index" select="min($segments/ex:segment[(./ex:segment-identifier='S1' or
	  ./ex:segment-identifier='R2') and 
      ./@ex:index/number(.) gt number($segment/@ex:index)]/@ex:index)"/>
    <xsl:element name="stop-off-name" namespace="http://edi4ml/edi/701#">
	  <xsl:element name="stop-sequence-num" namespace="http://edi4ml/edi/701#">
	    <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
	  </xsl:element>
	  <xsl:element name="name" namespace="http://edi4ml/edi/701#">
	    <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
	  </xsl:element>
	  <xsl:element name="id-code-qualifier" namespace="http://edi4ml/edi/701#">
	    <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
	  </xsl:element>
	  <xsl:element name="id-code" namespace="http://edi4ml/edi/701#">
	    <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
	  </xsl:element>
	  <xsl:element name="standard-carrier-alpha-code" namespace="http://edi4ml/edi/701#">
	    <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
	  </xsl:element>
	  <xsl:element name="accomplish-code" namespace="http://edi4ml/edi/701#">
	    <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
	  </xsl:element>
	  <xsl:for-each select="$segments/ex:segment[./@ex:index/number(.) lt $next-index and
        ./@ex:index/number(.) gt number($segment/@ex:index)]">
        <xsl:choose>
          <xsl:when test="./ex:segment-identifier='S2'">
            <xsl:call-template name="S2">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='S9'">
            <xsl:call-template name="S9">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='N1'">
            <xsl:call-template name="N1">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='N2'">
            <xsl:call-template name="N2">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='N3'">
            <xsl:call-template name="N3">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='N4'">
            <xsl:call-template name="N4">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='PER'">
            <xsl:call-template name="PER">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:otherwise/>
        </xsl:choose>
      </xsl:for-each>
	</xsl:element>
  </xsl:template>
  
  <xsl:template name="S2">
    <xsl:param name="segment"/>
	<xsl:element name="stop-off-address" namespace="http://edi4ml/edi/701#">
      <xsl:element name="stop-sequence-num" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="address-information" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="address-information" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	</xsl:element>
  </xsl:template>
  
  <xsl:template name="S9">
    <xsl:param name="segment"/>
	<xsl:element name="stop-off-station" namespace="http://edi4ml/edi/701#">
      <xsl:element name="stop-sequence-num" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="standard-point-location-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="city-name" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="state-or-province-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="country-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
	  <xsl:element name="stop-reason-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
	  <xsl:element name="location-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=7]"/>
      </xsl:element>
	  <xsl:element name="location-identifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=8]"/>
      </xsl:element>
	</xsl:element>
  </xsl:template>
  
  <xsl:template name="R2">
    <xsl:param name="segment"/>
	<xsl:element name="route-information" namespace="http://edi4ml/edi/701#">
      <xsl:element name="standard-carrier-alpha-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="routing-sequence-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="city-name" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="standard-point-location-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="intermodal-service-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
	  <xsl:element name="intermediate-switch-carrier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
	  <xsl:element name="intermediate-switch-carrier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=7]"/>
      </xsl:element>
	</xsl:element>
  </xsl:template>
  
  <xsl:template name="R9">
    <xsl:param name="segment"/>
	<xsl:element name="route-code-id" namespace="http://edi4ml/edi/701#">
      <xsl:element name="route-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="agent-shipping-route-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="intermodal-service-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="switch-standard-carrier-alpha-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="action-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
	  <xsl:element name="source-standard-carrier-alpha-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
	</xsl:element>
  </xsl:template>
  
  <xsl:template name="E1-Loop">
    <xsl:param name="segment"/>
	<xsl:variable name="segment-index" select="./@ex:index"/>
    <xsl:variable name="next-index" select="min($segments/ex:segment[(./ex:segment-identifier='LX' or
	  ./ex:segment-identifier='E1' or ./ex:segment-identifier='H3') and 
      ./@ex:index/number(.) gt number($segment/@ex:index)]/@ex:index)"/>
    <xsl:element name="empty-car-disposition" namespace="http://edi4ml/edi/701#">
	  <xsl:element name="pended-consignee" namespace="http://edi4ml/edi/701#">
	    <xsl:call-template name="E1">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
	  </xsl:element>
	  <xsl:for-each select="$segments/ex:segment[./@ex:index/number(.) lt $next-index and
        ./@ex:index/number(.) gt number($segment/@ex:index)]">
        <xsl:choose>
          <xsl:when test="./ex:segment-identifier='E4'">
            <xsl:call-template name="E4">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='E5'">
            <xsl:call-template name="E5">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='PI'">
            <xsl:call-template name="PI">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:otherwise/>
        </xsl:choose>
      </xsl:for-each>
	</xsl:element>
  </xsl:template>
  
  <xsl:template name="E1">
    <xsl:param name="segment"/>
      <xsl:element name="name" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="id-code-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="id-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
  </xsl:template>
  
  <xsl:template name="PS">
    <xsl:param name="segment"/>
    <xsl:element name="protective-service-instructions" namespace="http://edi4ml/edi/701#">
      <xsl:element name="protective-service-rule-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="protective-service-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="unit-basis-measurement-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="optimum-temperature" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="standard-carrier-alpha-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
	  <xsl:element name="freight-station-accounting-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
	  <xsl:element name="city-name" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=7]"/>
      </xsl:element>
	  <xsl:element name="state-or-province-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=8]"/>
      </xsl:element>
	  <xsl:element name="weight" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=9]"/>
      </xsl:element>
	  <xsl:element name="pre-cooled-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=10]"/>
      </xsl:element>
	  <xsl:element name="heater-location" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=11]"/>
      </xsl:element>
	  <xsl:element name="is-food-product" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=12]"/>
      </xsl:element>
	  <xsl:element name="doorway-space" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=13]"/>
      </xsl:element>
	  <xsl:element name="origin-temperature" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=14]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="LX-Loop">
    <xsl:param name="segment"/>
	<xsl:variable name="segment-index" select="./@ex:index"/>
    <xsl:variable name="next-index" select="min($segments/ex:segment[(./ex:segment-identifier='LX' or
	  ./ex:segment-identifier='T1' or ./ex:segment-identifier='L3' or ./ex:segment-identifier='LS' or
	  ./ex:segment-identifier='SE') and 
      ./@ex:index/number(.) gt number($segment/@ex:index)]/@ex:index)"/>
    <xsl:element name="tx-set-line-number" namespace="http://edi4ml/edi/701#">
      <xsl:element name="assigned-number" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
	  <xsl:for-each select="$segments/ex:segment[./@ex:index/number(.) lt $next-index and
        ./@ex:index/number(.) gt number($segment/@ex:index)]">
        <xsl:choose>
          <xsl:when test="./ex:segment-identifier='L5'">
            <xsl:call-template name="L5">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='L0'">
            <xsl:call-template name="LX-L0-Loop">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='X1'">
            <xsl:call-template name="X1">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:otherwise/>
        </xsl:choose>
      </xsl:for-each>
	</xsl:element>
  </xsl:template>
  
  <xsl:template name="L5">
    <xsl:param name="segment"/>
    <xsl:element name="desc-marks-numbers" namespace="http://edi4ml/edi/701#">
	  <xsl:element name="lading-line-item-num" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
	  <xsl:element name="lading-description" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="commodity-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="commodity-code-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
      <xsl:element name="packaging-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
	  <xsl:element name="marks-and-numbers" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
      <xsl:element name="marks-and-numbers-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=7]"/>
      </xsl:element>
	  <xsl:element name="commodity-code-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=8]"/>
      </xsl:element>
	  <xsl:element name="commodity-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=9]"/>
      </xsl:element>
      <xsl:element name="compartment-id-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=10]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="LX-L0-Loop">
    <xsl:param name="segment"/>
	<xsl:variable name="segment-index" select="./@ex:index"/>
    <xsl:variable name="next-index" select="min($segments/ex:segment[(./ex:segment-identifier='L0' or
	  ./ex:segment-identifier='T1' or ./ex:segment-identifier='L3' or ./ex:segment-identifier='LS' or
	  ./ex:segment-identifier='SE') and 
      ./@ex:index/number(.) gt number($segment/@ex:index)]/@ex:index)"/>
    <xsl:element name="line-item-quantity-and-weight" namespace="http://edi4ml/edi/701#">
      <xsl:element name="lading-line-item-num" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
	  <xsl:element name="billed-rated-quantity" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="billed-rated-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="weight" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="weight-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
	  <xsl:element name="volume" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
	  <xsl:element name="volume-unit-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=7]"/>
      </xsl:element>
	  <xsl:element name="lading-quantity" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=8]"/>
      </xsl:element>
	  <xsl:element name="packaging-form-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=9]"/>
      </xsl:element>
	  <xsl:element name="dunnage-description" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=10]"/>
      </xsl:element>
	  <xsl:element name="weight-unit-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=11]"/>
      </xsl:element>
	  <xsl:element name="type-of-service-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=12]"/>
      </xsl:element>
	  <xsl:element name="quantity" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=13]"/>
      </xsl:element>
	  <xsl:element name="packaging-form-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=14]"/>
      </xsl:element>
	  <xsl:element name="yes-no-condition-response-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=15]"/>
      </xsl:element>
	  <xsl:for-each select="$segments/ex:segment[./@ex:index/number(.) lt $next-index and
        ./@ex:index/number(.) gt number($segment/@ex:index)]">
        <xsl:choose>
          <xsl:when test="./ex:segment-identifier='MEA'">
            <xsl:call-template name="MEA">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='L1'">
            <xsl:call-template name="L1">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='PI'">
            <xsl:call-template name="LX-L0-PI-Loop">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:otherwise/>
        </xsl:choose>
      </xsl:for-each>
	</xsl:element>
  </xsl:template>
  
  <xsl:template name="X1">
    <xsl:param name="segment"/>
    <xsl:element name="export-license" namespace="http://edi4ml/edi/701#">
	  <xsl:element name="licensing-agency-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
	  <xsl:element name="export-license-num" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="license-expiration-date" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="export-license-symbol-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="export-license-control-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
	  <xsl:element name="country-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
      <xsl:element name="schedule-b-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=9]"/>
      </xsl:element>
      <xsl:element name="international-domestic-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=12]"/>
      </xsl:element>
      <xsl:element name="lading-quantity" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=7]"/>
      </xsl:element>
      <xsl:element name="lading-value" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=8]"/>
      </xsl:element>
	  <xsl:element name="export-file-key-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=10]"/>
      </xsl:element>
      <xsl:element name="unit-basis-measurement-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=11]"/>
      </xsl:element>
	  <xsl:element name="unit-price" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=12]"/>
      </xsl:element>
	  <xsl:element name="us-gov-license-type" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=13]"/>
      </xsl:element>
	  <xsl:element name="id-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=14]"/>
      </xsl:element>
	  <xsl:element name="location-identifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=15]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="T1-Loop">
    <xsl:param name="segment"/>
	<xsl:variable name="segment-index" select="./@ex:index"/>
    <xsl:variable name="next-index" select="min($segments/ex:segment[(./ex:segment-identifier='T1' or
	  ./ex:segment-identifier='L3' or ./ex:segment-identifier='LS' or ./ex:segment-identifier='SE') and 
      ./@ex:index/number(.) gt number($segment/@ex:index)]/@ex:index)"/>
    <xsl:element name="transit-inbound-origin" namespace="http://edi4ml/edi/701#">
      <xsl:element name="assigned-number" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
	  <xsl:element name="waybill-number" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="waybill-date" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="standard-carrier-alpha-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="city-name" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
	  <xsl:element name="state-or-province-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
	  <xsl:element name="standard-point-location-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=7]"/>
      </xsl:element>
	  <xsl:element name="transit-register-num" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=8]"/>
      </xsl:element>
	  <xsl:element name="transit-level-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=9]"/>
      </xsl:element>
	  <xsl:element name="ref-id-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=10]"/>
      </xsl:element>
	  <xsl:element name="ref-id" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=11]"/>
      </xsl:element>
	  <xsl:for-each select="$segments/ex:segment[./@ex:index/number(.) lt $next-index and
        ./@ex:index/number(.) gt number($segment/@ex:index)]">
        <xsl:choose>
          <xsl:when test="./ex:segment-identifier='T2'">
            <xsl:call-template name="T2">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='T3'">
            <xsl:call-template name="T3">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='T6'">
            <xsl:call-template name="T6">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='T8'">
            <xsl:call-template name="T8">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:otherwise/>
        </xsl:choose>
      </xsl:for-each>
	</xsl:element>
  </xsl:template>
  
  <xsl:template name="T2">
    <xsl:param name="segment"/>
    <xsl:element name="transit-inbound-lading" namespace="http://edi4ml/edi/701#">
	  <xsl:element name="assigned-number" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
	  <xsl:element name="lading-description" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="weight" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="weight-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="paid-in" namespace="http://edi4ml/edi/701#">
        <xsl:element name="freight-rate" namespace="http://edi4ml/edi/701#">
          <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
        </xsl:element>
	    <xsl:element name="rate-value-qualifier" namespace="http://edi4ml/edi/701#">
          <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
        </xsl:element>
		<xsl:element name="city-name" namespace="http://edi4ml/edi/701#">
          <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=9]"/>
        </xsl:element>
		<xsl:element name="surcharge-percent" namespace="http://edi4ml/edi/701#">
          <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=12]"/>
        </xsl:element>
      </xsl:element>
	  <xsl:element name="through-freight" namespace="http://edi4ml/edi/701#">
        <xsl:element name="freight-rate" namespace="http://edi4ml/edi/701#">
          <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=7]"/>
        </xsl:element>
        <xsl:element name="rate-value-qualifier" namespace="http://edi4ml/edi/701#">
          <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=8]"/>
        </xsl:element>
	    <xsl:element name="city-name" namespace="http://edi4ml/edi/701#">
          <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=10]"/>
        </xsl:element>
		<xsl:element name="surcharge-percent" namespace="http://edi4ml/edi/701#">
          <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=11]"/>
        </xsl:element>
	  </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="T3">
    <xsl:param name="segment"/>
    <xsl:element name="transit-inbound-route" namespace="http://edi4ml/edi/701#">
	  <xsl:element name="assigned-number" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
	  <xsl:element name="standard-carrier-alpha-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="routing-sequence-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>7
	  <xsl:element name="city-name" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="standard-point-location-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
	  <xsl:element name="equipment-initial" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
      <xsl:element name="equipment-number" namespace="http://edi4ml/edi/701#">
          <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=7]"/>
      </xsl:element>
	</xsl:element>
  </xsl:template>
  
  <xsl:template name="T6">
    <xsl:param name="segment"/>
    <xsl:element name="transit-inbound-rates" namespace="http://edi4ml/edi/701#">
	  <xsl:element name="assigned-number" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="paid-in" namespace="http://edi4ml/edi/701#">
        <xsl:element name="freight-rate" namespace="http://edi4ml/edi/701#">
          <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
        </xsl:element>
	    <xsl:element name="rate-value-qualifier" namespace="http://edi4ml/edi/701#">
          <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
        </xsl:element>
		<xsl:element name="city-name" namespace="http://edi4ml/edi/701#">
          <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
        </xsl:element>
      </xsl:element>
	  <xsl:element name="through-freight" namespace="http://edi4ml/edi/701#">
        <xsl:element name="freight-rate" namespace="http://edi4ml/edi/701#">
          <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
        </xsl:element>
        <xsl:element name="rate-value-qualifier" namespace="http://edi4ml/edi/701#">
          <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
        </xsl:element>
	    <xsl:element name="city-name" namespace="http://edi4ml/edi/701#">
          <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=7]"/>
        </xsl:element>
	  </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="T8">
    <xsl:param name="segment"/>
    <xsl:element name="freeform-transit-data" namespace="http://edi4ml/edi/701#">
	  <xsl:element name="assigned-number" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
	  <xsl:element name="transit-freeform-data" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="L3">
    <xsl:param name="segment"/>
    <xsl:element name="total-weight-and-charges" namespace="http://edi4ml/edi/701#">
	  <!--
	  <xsl:element name="weight" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
	  <xsl:element name="weight-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="freight-rate" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="rate-value-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  -->
      <xsl:element name="amount-charged" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
	  <!--
	  <xsl:element name="advances" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
	  -->
      <xsl:element name="prepaid-amount" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=7]"/>
      </xsl:element>
	  <!--
	  <xsl:element name="special-charge-allow-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=8]"/>
      </xsl:element>
	  <xsl:element name="volume" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=9]"/>
      </xsl:element>
	  <xsl:element name="volume-unit-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=10]"/>
      </xsl:element>
	  <xsl:element name="lading-quantity" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=11]"/>
      </xsl:element>
	  <xsl:element name="weight-unit-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=12]"/>
      </xsl:element>
	  <xsl:element name="tariff-number" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=13]"/>
      </xsl:element>
	  <xsl:element name="declared-value" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=14]"/>
      </xsl:element>
	  <xsl:element name="rate-value-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=15]"/>
      </xsl:element>
	  -->
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="LS-Loop">
    <xsl:param name="segment"/>
	<xsl:variable name="segment-index" select="./@ex:index"/>
    <xsl:variable name="next-index" select="min($segments/ex:segment[(./ex:segment-identifier='LE') and 
      ./@ex:index/number(.) gt number($segment/@ex:index)]/@ex:index)"/>
    <xsl:element name="hazardous-material-data" namespace="http://edi4ml/edi/701#">
      <xsl:element name="loop-id" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
	  <xsl:for-each select="$segments/ex:segment[./@ex:index/number(.) lt $next-index and
        ./@ex:index/number(.) gt number($segment/@ex:index)]">
        <xsl:choose>
          <xsl:when test="./ex:segment-identifier='LH1'">
            <xsl:call-template name="LH1-Loop">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:otherwise/>
        </xsl:choose>
      </xsl:for-each>
	</xsl:element>
  </xsl:template>
  
  <xsl:template name="LH1-Loop">
    <xsl:param name="segment"/>
	<xsl:variable name="segment-index" select="./@ex:index"/>
    <xsl:variable name="next-index" select="min($segments/ex:segment[(./ex:segment-identifier='LE' or
	  ./@ex:segment-identifier='LH1') and 
      ./@ex:index/number(.) gt number($segment/@ex:index)]/@ex:index)"/>
    <xsl:element name="hazardous-id-info" namespace="http://edi4ml/edi/701#">
      <xsl:element name="unit-basis-measurement-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
	  <xsl:element name="lading-quantity" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="un-na-id-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="hazmat-page" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="commodity-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
	  <xsl:element name="unit-basis-measurement-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
	  <xsl:element name="quantity" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=7]"/>
      </xsl:element>
	  <xsl:element name="compartment-id-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=8]"/>
      </xsl:element>
	  <xsl:element name="residue-indicator-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=9]"/>
      </xsl:element>
	  <xsl:element name="packing-group-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=10]"/>
      </xsl:element>
	  <xsl:element name="interim-hazmat-regulatory-num" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=11]"/>
      </xsl:element>
	  <xsl:element name="industry-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=12]"/>
      </xsl:element>
	  <xsl:for-each select="$segments/ex:segment[./@ex:index/number(.) lt $next-index and
        ./@ex:index/number(.) gt number($segment/@ex:index)]">
        <xsl:choose>
          <xsl:when test="./ex:segment-identifier='LH2'">
            <xsl:call-template name="LH2">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='LH3'">
            <xsl:call-template name="LH3">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='LFH'">
            <xsl:call-template name="LFH">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='LEP'">
            <xsl:call-template name="LEP">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='LH4'">
            <xsl:call-template name="LH4">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='LHT'">
            <xsl:call-template name="LHT">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='LHR'">
            <xsl:call-template name="LHR">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='PER'">
            <xsl:call-template name="PER">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='N1'">
            <xsl:call-template name="LH-N1-Loop">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:otherwise/>
        </xsl:choose>
      </xsl:for-each>
	</xsl:element>
  </xsl:template>
  
  <xsl:template name="LH2">
    <xsl:param name="segment"/>
    <xsl:element name="hazardous-classification-info" namespace="http://edi4ml/edi/701#">
      <xsl:element name="hazardous-class" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="hazardous-class-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="hazardous-placard-notation" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="hazardous-endorsement" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="reportable-quantity-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
	  <xsl:element name="flashpoint-temperature" namespace="http://edi4ml/edi/701#">
  	    <xsl:element name="unit-basis-measurement-code" namespace="http://edi4ml/edi/701#">
          <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
        </xsl:element>
	    <xsl:element name="temperature" namespace="http://edi4ml/edi/701#">
          <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=7]"/>
        </xsl:element>
      </xsl:element>
	  <xsl:element name="control-temperature" namespace="http://edi4ml/edi/701#">
	    <xsl:element name="unit-basis-measurement-code" namespace="http://edi4ml/edi/701#">
          <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=8]"/>
        </xsl:element>
	    <xsl:element name="temperature" namespace="http://edi4ml/edi/701#">
          <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=9]"/>
        </xsl:element>
      </xsl:element>
	  <xsl:element name="emergency-temperature" namespace="http://edi4ml/edi/701#">
 	    <xsl:element name="unit-basis-measurement-code" namespace="http://edi4ml/edi/701#">
          <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=10]"/>
        </xsl:element>
	    <xsl:element name="temperature" namespace="http://edi4ml/edi/701#">
          <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=11]"/>
        </xsl:element>
	  </xsl:element>
	  <xsl:element name="weight-unit-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=12]"/>
      </xsl:element>
	  <xsl:element name="explosive-quantity-net" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=13]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="LH3">
    <xsl:param name="segment"/>
    <xsl:element name="hazmat-shipping-name-info" namespace="http://edi4ml/edi/701#">
      <xsl:element name="hazmat-shipping-name" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="hazmat-name-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="nos-indicator-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="yes-no-condition-response-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="LFH">
    <xsl:param name="segment"/>
    <xsl:element name="freeform-hazmat-info" namespace="http://edi4ml/edi/701#">
      <xsl:element name="hazmat-info-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="hazmat-shipping-info" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="hazmat-shipping-info" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="hazard-zone-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="unit-basis-measurement-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
  	  <xsl:element name="radioactive-activity" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
	  <xsl:element name="radioactive-transport-index" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=7]"/>
      </xsl:element>
	  <xsl:element name="fumigation-date" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=8]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template name="LEP">
    <xsl:param name="segment"/>
    <xsl:element name="epa-required-data" namespace="http://edi4ml/edi/701#">
      <xsl:element name="epa-waste-stream-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="waste-characteristics-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="state-or-province-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="ref-id" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="LH4">
    <xsl:param name="segment"/>
    <xsl:element name="canadian-dangerous-requirements" namespace="http://edi4ml/edi/701#">
      <xsl:element name="emergency-response-plan-num" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="comms-number" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="packing-group-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="first-subsidiary-classification" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="second-subsidiary-clasification" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
	  <xsl:element name="third-subsidiary-classification" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
	  <xsl:element name="subsidiary-risk-indicator" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=7]"/>
      </xsl:element>
	  <xsl:element name="explosive-quantity-net" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=8]"/>
      </xsl:element>
	  <xsl:element name="canadian-hazard-note" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=9]"/>
      </xsl:element>
      <xsl:element name="special-commodity-indicator-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=10]"/>
      </xsl:element>
	  <xsl:element name="comms-number" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=11]"/>
      </xsl:element>
	  <xsl:element name="unit-basis-measurement-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=12]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="LHT">
    <xsl:param name="segment"/>
    <xsl:element name="transborder-hazardous-requirements" namespace="http://edi4ml/edi/701#">
      <xsl:element name="hazardous-class" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="hazardous-placard-notation" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="hazardous-endorsement" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="LHR">
    <xsl:param name="segment"/>
    <xsl:element name="hazardous-material-id-ref-num" namespace="http://edi4ml/edi/701#">
      <xsl:element name="ref-id-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="ref-id" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="date" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="LH-N1-Loop">
    <xsl:param name="segment"/>
	<xsl:variable name="segment-index" select="./@ex:index"/>
    <xsl:variable name="next-index" select="min($segments/ex:segment[(./ex:segment-identifier='LE' or
	  ./@ex:segment-identifier='N1' or ./@ex:segment-identifier='LH1') and 
      ./@ex:index/number(.) gt number($segment/@ex:index)]/@ex:index)"/>
    <xsl:element name="party-identification" namespace="http://edi4ml/edi/701#">
	  <xsl:call-template name="N1-body">
        <xsl:with-param name="segment" select="."/>
      </xsl:call-template>
	  <xsl:for-each select="$segments/ex:segment[./@ex:index/number(.) lt $next-index and
        ./@ex:index/number(.) gt number($segment/@ex:index)]">
        <xsl:choose>
          <xsl:when test="./ex:segment-identifier='N3'">
            <xsl:call-template name="N3">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='N4'">
            <xsl:call-template name="N4">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:when test="./ex:segment-identifier='PER'">
            <xsl:call-template name="PER">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
		  <xsl:otherwise/>
        </xsl:choose>
      </xsl:for-each>
	</xsl:element>
  </xsl:template>
  
  <xsl:template name="LH6">
    <xsl:param name="segment"/>
    <xsl:element name="hazardous-certification" namespace="http://edi4ml/edi/701#">
      <xsl:element name="name" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="hazardous-certification-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="hazardous-certification-declaration" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="hazardous-certification-declaration" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="XH">
    <xsl:param name="segment"/>
    <xsl:element name="pro-forma-b13-info" namespace="http://edi4ml/edi/701#">
      <xsl:element name="currency-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="related-company-indication-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="special-charge-or-allowance-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="amount" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	  <xsl:element name="block-20-code" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
	  <xsl:element name="chemical-analysis-percent" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
	  <xsl:element name="unit-price" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=7]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="X7">
    <xsl:param name="segment"/>
    <xsl:element name="customs-info" namespace="http://edi4ml/edi/701#">
      <xsl:element name="free-form-message" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="free-form-message" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="N1"> <!-- S1 Loop -->
    <xsl:param name="segment"/>
    <xsl:element name="party-identification" namespace="http://edi4ml/edi/701#">
	  <xsl:call-template name="N1-body">
        <xsl:with-param name="segment" select="."/>
      </xsl:call-template>
	</xsl:element>
  </xsl:template>
  
  <xsl:template name="N2">
    <xsl:param name="segment"/>
	<xsl:element name="additional-name-info" namespace="http://edi4ml/edi/701#">
      <xsl:element name="name" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="name" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	</xsl:element>
  </xsl:template>
  
  <xsl:template name="REF">
    <xsl:param name="segment"/>
    <xsl:element name="reference-information" namespace="http://edi4ml/edi/701#">
      <xsl:element name="ref-id-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="ref-id" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
	  <xsl:element name="description" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
	  <xsl:element name="ref-id-qualifier" namespace="http://edi4ml/edi/701#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
	</xsl:element>
  </xsl:template>
</xsl:stylesheet>