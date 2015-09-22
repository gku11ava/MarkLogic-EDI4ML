  <xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:ex="http://marklogic.com/edi/xml#">
  <xsl:variable name="segments" select="/ex:edi-document/ex:segments"/>
  <xsl:key name="segment-identifier" match="ex:segment" use="ex:segment-identifier"/>
  <xsl:template match="/">
    <xsl:element name="remittance-advice" namespace="http://marklogic.com/edi/common#">
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
    <xsl:element name="interchange" namespace="http://marklogic.com/edi/common#">
      <xsl:element name="authorization" namespace="http://marklogic.com/edi/common#">
        <xsl:element name="qualifier" namespace="http://marklogic.com/edi/common#">
          <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=1]"/>
        </xsl:element>
        <xsl:if test="$header/ex:fields/ex:field[./@ex:index=1] != '00'">
          <xsl:element name="information" namespace="http://marklogic.com/edi/common#">
            <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=2]"/>
          </xsl:element>
        </xsl:if>
      </xsl:element>
      <xsl:element name="security" namespace="http://marklogic.com/edi/common#">
        <xsl:element name="qualifier" namespace="http://marklogic.com/edi/common#">
          <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=3]"/>
        </xsl:element>
        <xsl:if test="$header/ex:fields/ex:field[./@ex:index=3] != '00'">
          <xsl:element name="information" namespace="http://marklogic.com/edi/common#">
            <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=4]"/>
          </xsl:element>
        </xsl:if>
      </xsl:element>
      <xsl:element name="sender" namespace="http://marklogic.com/edi/common#">
        <xsl:element name="qualifier" namespace="http://marklogic.com/edi/common#">
          <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=5]"/>
        </xsl:element>
        <xsl:if test="$header/ex:fields/ex:field[./@ex:index=5] != '00'">
          <xsl:element name="information" namespace="http://marklogic.com/edi/common#">
            <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=6]"/>
          </xsl:element>
        </xsl:if>
      </xsl:element>
      <xsl:element name="receiver" namespace="http://marklogic.com/edi/common#">
        <xsl:element name="qualifier" namespace="http://marklogic.com/edi/common#">
          <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=7]"/>
        </xsl:element>
        <xsl:element name="information" namespace="http://marklogic.com/edi/common#">
          <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=8]"/>
        </xsl:element>
      </xsl:element>
      <xsl:element name="format" namespace="http://marklogic.com/edi">
        <xsl:element name="interchange-date" namespace="http://marklogic.com/edi/common#">
          <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=9]"/>
        </xsl:element>
        <xsl:element name="interchange-time" namespace="http://marklogic.com/edi/common#">
          <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=10]"/>
        </xsl:element>
        <xsl:element name="component-separator" namespace="http://marklogic.com/edi/common#">
          <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=16]"/>
        </xsl:element>
      </xsl:element>
      <xsl:element name="interchange-standard" namespace="http://marklogic.com/edi/common#">
        <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=11]"/>
      </xsl:element>
      <xsl:element name="control-version" namespace="http://marklogic.com/edi/common#">
        <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=12]"/>
      </xsl:element>
      <xsl:element name="control-number" namespace="http://marklogic.com/edi/common#">
        <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=13]"/>
      </xsl:element>
      <xsl:element name="acknowledgement-required" namespace="http://marklogic.com/edi/common#">
        <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=14]"/>
      </xsl:element>
      <xsl:element name="usage" namespace="http://marklogic.com/edi/common#">
        <xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=15]"/>
      </xsl:element>
      <xsl:element name="functional-groups" namespace="http://marklogic.com/edi/common#">
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
    <xsl:element name="group" namespace="http://marklogic.com/edi/common#">
      <xsl:element name="functional-code" namespace="http://marklogic.com/edi/common#">
        <xsl:value-of select="$group-header/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="sender" namespace="http://marklogic.com/edi/common#">
        <xsl:value-of select="$group-header/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
      <xsl:element name="receiver" namespace="http://marklogic.com/edi/common#">
        <xsl:value-of select="$group-header/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
      <xsl:element name="date-format" namespace="http://marklogic.com/edi/common#">
        <xsl:value-of select="$group-header/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
      <xsl:element name="time-format" namespace="http://marklogic.com/edi/common#">
        <xsl:value-of select="$group-header/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
      <xsl:element name="control-number" namespace="http://marklogic.com/edi/common#">
        <xsl:value-of select="$group-header/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
      <xsl:element name="responsible-agency" namespace="http://marklogic.com/edi/common#">
        <xsl:value-of select="$group-header/ex:fields/ex:field[./@ex:index=7]"/>
      </xsl:element>
      <xsl:element name="document-identifier" namespace="http://marklogic.com/edi/common#">
        <xsl:value-of select="$group-header/ex:fields/ex:field[./@ex:index=8]"/>
      </xsl:element>
      <xsl:element name="transaction-sets" namespace="http://marklogic.com/edi/common#">
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
    <xsl:element name="transaction-set" namespace="http://marklogic.com/edi/common#">
      <xsl:element name="transaction-id" namespace="http://marklogic.com/edi/common#">
        <xsl:value-of select="$set-header/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="control-number" namespace="http://marklogic.com/edi/common#">
        <xsl:value-of select="$set-header/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
      <xsl:element name="document-identifier" namespace="http://marklogic.com/edi/common#">
        <xsl:value-of select="$set-header/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
      <!--  Begin Format Specific Handling Here -->
      <xsl:for-each select="key('segment-identifier', 'BPR')">
        <xsl:call-template name="BPR">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
      <xsl:for-each select="key('segment-identifier', 'N1')">
        <xsl:call-template name="N1">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
      <xsl:for-each select="key('segment-identifier', 'ENT')">
        <xsl:call-template name="ENT">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
      <xsl:for-each select="key('segment-identifier', 'NM1')">
        <xsl:call-template name="NM1">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
      <xsl:for-each select="key('segment-identifier', 'RMR')">
        <xsl:call-template name="RMR">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
      <xsl:for-each select="key('segment-identifier', 'ADX')">
        <xsl:call-template name="ADX">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="BPR">
    <xsl:param name="segment"/>
    <xsl:variable name="segment-index" select="./@ex:index"/>
    <xsl:variable name="next-index" select="min($segments/ex:segment[(./ex:segment-identifier = 'N1' or
      ./ex:segment-identifier = 'ENT' or ./ex:segment-identifier = 'NM1' or ./ex:segment-identifier = 'RMR' or
      ./ex:segment-identifier = 'ADX') and ./@ex:index/number(.) gt number($segment/@ex:index)]/@ex:index)"/>
    <xsl:element name="begin-payment-remittance" namespace="http://marklogic.com/edi/820#">
      <xsl:element name="transaction-handling-code" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="monetary-amount" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
      <xsl:element name="credit-debit-flag-code" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
      <xsl:element name="payment-method-code" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
      <xsl:for-each select="$segments/ex:segment[./@ex:index/number(.) lt $next-index and
        ./@ex:index/number(.) gt number($segment/@ex:index)]">
        <xsl:choose>
          <xsl:when test="./ex:segment-identifier='TRN'">
            <xsl:call-template name="TRN">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="./ex:segment-identifier='DTM'">
            <xsl:call-template name="DTM">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise/>
        </xsl:choose>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="TRN">
    <xsl:param name="segment"/>
    <xsl:element name="trace" namespace="http://marklogic.com/edi/820#">
      <xsl:element name="trace-type-code" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="reference-identification" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="DTM">
    <xsl:param name="segment"/>
    <xsl:element name="date-time-reference" namespace="http://marklogic.com/edi/820#">
      <xsl:element name="date-time-qualifier" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="date-time" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template name="N1">
    <xsl:param name="segment"/>
    <xsl:element name="party-identification" namespace="http://marklogic.com/edi/820#">
      <xsl:element name="entity-identifier-code" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="name" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
      <xsl:element name="identification-code-qualifier" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
      <xsl:element name="identification-code" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="ENT">
    <xsl:param name="segment"/>
    <xsl:element name="entity" namespace="http://marklogic.com/edi/820#">
      <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="NM1">
    <xsl:param name="segment"/>
    <xsl:element name="entity-name" namespace="http://marklogic.com/edi/820#">
      <xsl:element name="entity-identifier-code" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="entity-type-qualifier" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
      <xsl:element name="last-name" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
      <xsl:element name="first-name" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
      <xsl:element name="middle-initial" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
      <xsl:element name="name-prefix" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
      <xsl:element name="name-suffix" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=7]"/>
      </xsl:element>
      <xsl:element name="identification-code-qualifier" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=8]"/>
      </xsl:element>
      <xsl:element name="identification-code" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=9]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="RMR">
    <xsl:param name="segment"/>
    <xsl:variable name="segment-index" select="./@ex:index"/>
    <xsl:variable name="next-index" select="min($segments/ex:segment[(./ex:segment-identifier='RMR' or
      ./ex:segment-identifier = 'ADX' or ./ex:segment-identifier='SE') and 
      ./@ex:index/number(.) gt number($segment/@ex:index)]/@ex:index)"/>
    <xsl:element name="remittance-advice" namespace="http://marklogic.com/edi/820#">
      <xsl:element name="remittance-identification-qualifier" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="remittance-identification" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
      <xsl:element name="payment-action-code" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
      <xsl:element name="monetary-amount" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
      <xsl:element name="monetary-amount" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]"/>
      </xsl:element>
      <xsl:element name="monetary-amount" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=6]"/>
      </xsl:element>
      <xsl:for-each select="$segments/ex:segment[./@ex:index/number(.) lt $next-index and
        ./@ex:index/number(.) gt number($segment/@ex:index)]">
        <xsl:choose>
          <xsl:when test="./ex:segment-identifier='REF'">
            <xsl:call-template name="REF">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="./ex:segment-identifier='DTM'">
            <xsl:call-template name="DTM">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise/>
        </xsl:choose>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="REF">
    <xsl:param name="segment"/>
    <xsl:element name="reference-information" namespace="http://marklogic.com/edi/820#">
      <xsl:element name="reference-id-qualifier" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="reference-id" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template name="ADX">
    <xsl:param name="segment"/>
    <xsl:variable name="segment-index" select="./@ex:index"/>
    <xsl:variable name="next-index" select="min($segments/ex:segment[(./ex:segment-identifier = 'ADX' or 
      ./ex:segment-identifier='SE') and ./@ex:index/number(.) gt number($segment/@ex:index)]/@ex:index)"/>
    <xsl:element name="adjustment" namespace="http://marklogic.com/edi/820#">
      <xsl:element name="monetary-amount" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="adjustment-reason-code" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
      <xsl:for-each select="$segments/ex:segment[./@ex:index/number(.) lt $next-index and
        ./@ex:index/number(.) gt number($segment/@ex:index)]">
        <xsl:call-template name="NTE">
          <xsl:with-param name="segment" select="."/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="NTE">
    <xsl:param name="segment"/>
    <xsl:element name="note" namespace="http://marklogic.com/edi/820#">
      <xsl:element name="note-reference-code" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="description" namespace="http://marklogic.com/edi/820#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>