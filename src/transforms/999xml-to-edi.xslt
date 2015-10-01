<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:ex="http://edi4ml/edi/xml#"
  xmlns:edi="http://edi4ml/edi/common#"
  xmlns:edi-ns="http://edi4ml/edi/999#">

  <xsl:template match="/edi:implementation-acknowledgement">
    <xsl:element name="edi-document" namespace="http://edi4ml/edi/xml#">
      <xsl:element name="segments" namespace="http://edi4ml/edi/xml#">
        <xsl:for-each select="./edi:interchange">
          <xsl:call-template name="parse-interchange">
            <xsl:with-param name="interchange" select="."/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template name="parse-interchange">
    <xsl:param name="interchange"/>
    <xsl:element name="segment" namespace="http://edi4ml/edi/xml#">
      <xsl:element name="segment-identifier" namespace="http://edi4ml/edi/xml#">
        <xsl:text>ISA</xsl:text>
      </xsl:element>
      <xsl:element name="fields" namespace="http://edi4ml/edi/xml#">
        <xsl:attribute name="count"><xsl:number value="16"/></xsl:attribute>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index"><xsl:number value="1"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi:authorization/edi:qualifier"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index"><xsl:number value="2"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi:authorization/edi:information"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index"><xsl:number value="3"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi:security/edi:qualifier"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index"><xsl:number value="4"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi:security/edi:information"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index"><xsl:number value="5"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi:sender/edi:qualifier"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index"><xsl:number value="6"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi:sender/edi:identifier"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index"><xsl:number value="7"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi:receiver/edi:qualifier"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index"><xsl:number value="8"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi:receiver/edi:identifier"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index"><xsl:number value="9"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi:format/edi:interchange-date"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index"><xsl:number value="10"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi:format/edi:interchange-time"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index"><xsl:number value="11"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi:interchange-standard"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index"><xsl:number value="12"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi:control-version"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index"><xsl:number value="13"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi:control-number"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index"><xsl:number value="14"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi:acknowledgement-required"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index"><xsl:number value="15"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi:usage"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index"><xsl:number value="16"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi:format/edi:component-separator"/>
        </xsl:element>
      </xsl:element>
    </xsl:element>
    <xsl:for-each select="$interchange/edi:functional-groups/edi:functional-group">
      <xsl:call-template name="parse-group">
        <xsl:with-param name="group" select="."/>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:element name="segment" namespace="http://edi4ml/edi/xml#">
      <xsl:element name="segment-identifier" namespace="http://edi4ml/edi/xml#">
        <xsl:text>IEA</xsl:text>
      </xsl:element>
      <xsl:element name="fields" namespace="http://edi4ml/edi/xml#">
        <xsl:attribute name="count"><xsl:number value="2"/></xsl:attribute>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index"><xsl:number value="1"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi:functional-groups/@edi:count"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index"><xsl:number value="2"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi:control-number"/>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template name="parse-group">
    <xsl:param name="group"/>
    <xsl:element name="segment" namespace="http://edi4ml/edi/xml#">
      <xsl:element name="segment-identifier" namespace="http://edi4ml/edi/xml#">
        <xsl:text>GS</xsl:text>
      </xsl:element>
      <xsl:element name="fields" namespace="http://edi4ml/edi/xml#">
        <xsl:attribute name="count"><xsl:number value="8"/></xsl:attribute>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index"><xsl:number value="1"/></xsl:attribute>
          <xsl:value-of select="$group/edi:functional-code"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index"><xsl:number value="2"/></xsl:attribute>
          <xsl:value-of select="$group/edi:sender"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index"><xsl:number value="3"/></xsl:attribute>
          <xsl:value-of select="$group/edi:receiver"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index"><xsl:number value="4"/></xsl:attribute>
          <xsl:value-of select="$group/edi:date-format"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index"><xsl:number value="5"/></xsl:attribute>
          <xsl:value-of select="$group/edi:time-format"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index"><xsl:number value="6"/></xsl:attribute>
          <xsl:value-of select="$group/edi:control-number"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index"><xsl:number value="7"/></xsl:attribute>
          <xsl:value-of select="$group/edi:responsible-agency"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index"><xsl:number value="8"/></xsl:attribute>
          <xsl:value-of select="$group/edi:document-identifier"/>
        </xsl:element>
      </xsl:element>
    </xsl:element>
      <xsl:for-each select="$group/edi:transaction-sets/edi:transaction-set">
        <xsl:call-template name="parse-set">
          <xsl:with-param name="set" select="."/>
        </xsl:call-template>
      </xsl:for-each>
      <xsl:element name="segment" namespace="http://edi4ml/edi/xml#">
        <xsl:element name="segment-identifier" namespace="http://edi4ml/edi/xml#">
          <xsl:text>GE</xsl:text>
        </xsl:element>
        <xsl:element name="fields" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="count"><xsl:number value="2"/></xsl:attribute>
          <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
            <xsl:attribute name="index"><xsl:number value="1"/></xsl:attribute>
            <xsl:value-of select="$group/edi:transaction-sets/@edi:count"/>
          </xsl:element>
          <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
            <xsl:attribute name="index"><xsl:number value="2"/></xsl:attribute>
            <xsl:value-of select="$group/edi:control-number"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
  </xsl:template>
  
  <xsl:template name="parse-set">
    <xsl:param name="set"/>
    <xsl:variable name="segment-count" select="0"/>
    <xsl:element name="segment" namespace="http://edi4ml/edi/xml#">
      <xsl:element name="segment-identifier" namespace="http://edi4ml/edi/xml#">
        <xsl:text>ST</xsl:text>
      </xsl:element>
      <xsl:element name="fields" namespace="http://edi4ml/edi/xml#">
        <xsl:attribute name="count"><xsl:number value="2"/></xsl:attribute>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index"><xsl:number value="1"/></xsl:attribute>
          <xsl:value-of select="$set/edi:transaction-id"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index"><xsl:number value="2"/></xsl:attribute>
          <xsl:value-of select="$set/edi:control-number"/>
        </xsl:element>
      </xsl:element>
    </xsl:element>
    <xsl:for-each select="$set/edi:functional-group-response">
      <xsl:call-template name="parse-fg-response">
        <xsl:with-param name="element" select="."/>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:for-each select="$set/edi:transaction-set-response-header">
      <xsl:call-template name="parse-ts-response">
        <xsl:with-param name="element" select="."/>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:for-each select="$set/edi:functional-group-response-trailer">
      <xsl:call-template name="parse-fg-trailer">
        <xsl:with-param name="element" select="."/>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:element name="segment" namespace="http://edi4ml/edi/xml#">
      <xsl:element name="segment-identifier" namespace="http://edi4ml/edi/xml#">
        <xsl:text>SE</xsl:text>
      </xsl:element>
      <xsl:element name="fields" namespace="http://edi4ml/edi/xml#">
        <xsl:attribute name="count" namespace="http://edi4ml/edi/xml#"><xsl:number value="2"/></xsl:attribute>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="1"/></xsl:attribute>
          <xsl:number value="$segment-count"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="2"/></xsl:attribute>
          <xsl:value-of select="$set/edi-ns:control-number"/>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="parse-fg-response">
    <xsl:param name="element"/>
    <xsl:element name="segment" namespace="http://edi4ml/edi/xml#">
      <xsl:element name="segment-identifier" namespace="http://edi4ml/edi/xml#">
        <xsl:text>AK1</xsl:text>
      </xsl:element>
      <xsl:element name="fields" namespace="http://edi4ml/edi/xml#">
        <xsl:attribute name="count" namespace="http://edi4ml/edi/xml#"><xsl:number value="3"/></xsl:attribute>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="1"/></xsl:attribute>
          <xsl:value-of select="$element/edi-999:functional-identifier"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="2"/></xsl:attribute>
          <xsl:value-of select="$element/edi-999:control-number"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="3"/></xsl:attribute>
          <xsl:value-of select="$element/edi-999:identifier-code"/>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="parse-ts-response">
    <xsl:param name="element"/>
    <xsl:element name="segment" namespace="http://edi4ml/edi/xml#">
      <xsl:element name="segment-identifier" namespace="http://edi4ml/edi/xml#">
        <xsl:text>AK2</xsl:text>
      </xsl:element>
      <xsl:element name="fields" namespace="http://edi4ml/edi/xml#">
        <xsl:attribute name="count" namespace="http://edi4ml/edi/xml#"><xsl:number value="3"/></xsl:attribute>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="1"/></xsl:attribute>
          <xsl:value-of select="$element/edi-999:transaction-set-identifier"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="2"/></xsl:attribute>
          <xsl:value-of select="$element/edi-999:set-control-number"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="3"/></xsl:attribute>
          <xsl:value-of select="$element/edi-999:convention-reference"/>
        </xsl:element>
      </xsl:element>
    </xsl:element>
    <xsl:for-each select="$element/edi-999:error-identification">
      <xsl:call-template name="parse-error">
        <xsl:with-param name="error" select="."/>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:for-each select="$element/edi-999:transaction-set-response-trailer">
      <xsl:call-template name="parse-ts-trailer">
        <xsl:with-param name="trailer" select="."/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="parse-error">
    <xsl:param name="error"/>
    <xsl:element name="segment" namespace="http://edi4ml/edi/xml#">
      <xsl:element name="segment-identifier" namespace="http://edi4ml/edi/xml#">
        <xsl:text>IK3</xsl:text>
      </xsl:element>
      <xsl:element name="fields" namespace="http://edi4ml/edi/xml#">
        <xsl:attribute name="count" namespace="http://edi4ml/edi/xml#"><xsl:number value="4"/></xsl:attribute>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="1"/></xsl:attribute>
          <xsl:value-of select="$error/edi-999:segment-identifier"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="2"/></xsl:attribute>
          <xsl:value-of select="$error/edi-999:segment-position"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="3"/></xsl:attribute>
          <xsl:value-of select="$error/edi-999:loop-identifier"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="4"/></xsl:attribute>
          <xsl:value-of select="$error/edi-999:error-code"/>
        </xsl:element>
      </xsl:element>
    </xsl:element>
    <xsl:for-each select="$error/*[local-name(.) = ('segment-context', 'business-unit-identifier', 'data-element')">
      <xsl:choose>
        <xsl:when test="local-name(.) = 'segment-context'">
          <xsl:call-template name="parse-seg-context">
            <xsl:with-param name="context" select="."/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="local-name(.) = 'business-unit-identifier'">
          <xsl:call-template name="parse-business-context">
            <xsl:with-param name="context" select="."/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="parse-data-element">
            <xsl:with-param name="element" select="."/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="parse-el-context">
    <xsl:param name="context"/>
    <xsl:element name="segment" namespace="http://edi4ml/edi/xml#">
      <xsl:element name="segment-identifier" namespace="http://edi4ml/edi/xml#">
        <xsl:text>CTX</xsl:text>
      </xsl:element>
      <xsl:element name="fields" namespace="http://edi4ml/edi/xml#">
        <xsl:attribute name="count" namespace="http://edi4ml/edi/xml#"><xsl:number value="4"/></xsl:attribute>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="1"/></xsl:attribute>
          <xsl:value-of select="$error/edi-999:context-name"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="2"/></xsl:attribute>
          <xsl:value-of select="$error/edi-999:segment-id"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="3"/></xsl:attribute>
          <xsl:value-of select="$error/edi-999:segment-position"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="4"/></xsl:attribute>
          <xsl:value-of select="$error/edi-999:loop-identifier"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="5"/></xsl:attribute>
          <xsl:element name="components" namespace="http://edi4ml/edi/xml#">
            <xsl:attribute name="count" namespace="http://edi4ml/edi/xml#"><xsl:number>3</xsl:number></xsl:attribute>
            <xsl:element name="component" namespace="http://edi4ml/edi/xml#">
              <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number>1</xsl:number></xsl:attribute>
              <xsl:value-of select="$context/edi-999:element/edi-999:element-position"/>
            </xsl:element>
            <xsl:element name="component" namespace="http://edi4ml/edi/xml#">
              <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number>2</xsl:number></xsl:attribute>
              <xsl:value-of select="$context/edi-999:element/edi-999:component-position"/>
            </xsl:element>
            <xsl:element name="component" namespace="http://edi4ml/edi/xml#">
              <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number>3</xsl:number></xsl:attribute>
              <xsl:value-of select="$context/edi-999:element/edi-999:repeating-position"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="6"/></xsl:attribute>
          <xsl:element name="components" namespace="http://edi4ml/edi/xml#">
            <xsl:attribute name="count" namespace="http://edi4ml/edi/xml#"><xsl:number>2</xsl:number></xsl:attribute>
            <xsl:element name="component" namespace="http://edi4ml/edi/xml#">
              <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number>1</xsl:number></xsl:attribute>
              <xsl:value-of select="$context/edi-999:reference/edi-999:reference-number"/>
            </xsl:element>
            <xsl:element name="component" namespace="http://edi4ml/edi/xml#">
              <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number>2</xsl:number></xsl:attribute>
              <xsl:value-of select="$context/edi-999:reference/edi-999:reference-number"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="parse-el-context">
    <xsl:param name="context"/>
    <xsl:element name="segment" namespace="http://edi4ml/edi/xml#">
      <xsl:element name="segment-identifier" namespace="http://edi4ml/edi/xml#">
        <xsl:text>CTX</xsl:text>
      </xsl:element>
      <xsl:element name="fields" namespace="http://edi4ml/edi/xml#">
        <xsl:attribute name="count" namespace="http://edi4ml/edi/xml#"><xsl:number value="4"/></xsl:attribute>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="1"/></xsl:attribute>
          <xsl:value-of select="$error/edi-999:context-name"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="2"/></xsl:attribute>
          <xsl:value-of select="$error/edi-999:segment-id"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="3"/></xsl:attribute>
          <xsl:value-of select="$error/edi-999:segment-position"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="4"/></xsl:attribute>
          <xsl:value-of select="$error/edi-999:loop-identifier"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="5"/></xsl:attribute>
          <xsl:element name="components" namespace="http://edi4ml/edi/xml#">
            <xsl:attribute name="count" namespace="http://edi4ml/edi/xml#"><xsl:number>3</xsl:number></xsl:attribute>
            <xsl:element name="component" namespace="http://edi4ml/edi/xml#">
              <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number>1</xsl:number></xsl:attribute>
              <xsl:value-of select="$context/edi-999:element/edi-999:element-position"/>
            </xsl:element>
            <xsl:element name="component" namespace="http://edi4ml/edi/xml#">
              <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number>2</xsl:number></xsl:attribute>
              <xsl:value-of select="$context/edi-999:element/edi-999:component-position"/>
            </xsl:element>
            <xsl:element name="component" namespace="http://edi4ml/edi/xml#">
              <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number>3</xsl:number></xsl:attribute>
              <xsl:value-of select="$context/edi-999:element/edi-999:repeating-position"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="6"/></xsl:attribute>
          <xsl:element name="components" namespace="http://edi4ml/edi/xml#">
            <xsl:attribute name="count" namespace="http://edi4ml/edi/xml#"><xsl:number>2</xsl:number></xsl:attribute>
            <xsl:element name="component" namespace="http://edi4ml/edi/xml#">
              <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number>1</xsl:number></xsl:attribute>
              <xsl:value-of select="$context/edi-999:reference/edi-999:reference-number"/>
            </xsl:element>
            <xsl:element name="component" namespace="http://edi4ml/edi/xml#">
              <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number>2</xsl:number></xsl:attribute>
              <xsl:value-of select="$context/edi-999:reference/edi-999:reference-number"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template name="parse-data-element">
    <xsl:param name="element"/>
    <xsl:element name="segment" namespace="http://edi4ml/edi/xml#">
      <xsl:element name="segment-identifier" namespace="http://edi4ml/edi/xml#">
        <xsl:text>IK4</xsl:text>
      </xsl:element>
      <xsl:element name="fields" namespace="http://edi4ml/edi/xml#">
        <xsl:attribute name="count" namespace="http://edi4ml/edi/xml#"><xsl:number value="4"/></xsl:attribute>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="1"/></xsl:attribute>
          <xsl:value-of select="$error/edi-999:element-position"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="2"/></xsl:attribute>
          <xsl:value-of select="$error/edi-999:element-reference-number"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="3"/></xsl:attribute>
          <xsl:value-of select="$error/edi-999:error-code"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="4"/></xsl:attribute>
          <xsl:value-of select="$error/edi-999:bad-element"/>
        </xsl:element>
      </xsl:element>
    </xsl:element>
    <xsl:for-each select="$error/edi-999:element-context">
      <xsl:call-template name="parse-el-context">
        <xsl:with-param name="context" select="."/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="parse-el-context">
    <xsl:param name="context"/>
    <xsl:element name="segment" namespace="http://edi4ml/edi/xml#">
      <xsl:element name="segment-identifier" namespace="http://edi4ml/edi/xml#">
        <xsl:text>CTX</xsl:text>
      </xsl:element>
      <xsl:element name="fields" namespace="http://edi4ml/edi/xml#">
        <xsl:attribute name="count" namespace="http://edi4ml/edi/xml#"><xsl:number value="4"/></xsl:attribute>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="1"/></xsl:attribute>
          <xsl:value-of select="$error/edi-999:context-name"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="2"/></xsl:attribute>
          <xsl:value-of select="$error/edi-999:segment-id"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="3"/></xsl:attribute>
          <xsl:value-of select="$error/edi-999:segment-position"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="4"/></xsl:attribute>
          <xsl:value-of select="$error/edi-999:loop-identifier"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="5"/></xsl:attribute>
          <xsl:element name="components" namespace="http://edi4ml/edi/xml#">
            <xsl:attribute name="count" namespace="http://edi4ml/edi/xml#"><xsl:number>3</xsl:number></xsl:attribute>
            <xsl:element name="component" namespace="http://edi4ml/edi/xml#">
              <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number>1</xsl:number></xsl:attribute>
              <xsl:value-of select="$context/edi-999:element/edi-999:element-position"/>
            </xsl:element>
            <xsl:element name="component" namespace="http://edi4ml/edi/xml#">
              <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number>2</xsl:number></xsl:attribute>
              <xsl:value-of select="$context/edi-999:element/edi-999:component-position"/>
            </xsl:element>
            <xsl:element name="component" namespace="http://edi4ml/edi/xml#">
              <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number>3</xsl:number></xsl:attribute>
              <xsl:value-of select="$context/edi-999:element/edi-999:repeating-position"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="6"/></xsl:attribute>
          <xsl:element name="components" namespace="http://edi4ml/edi/xml#">
            <xsl:attribute name="count" namespace="http://edi4ml/edi/xml#"><xsl:number>2</xsl:number></xsl:attribute>
            <xsl:element name="component" namespace="http://edi4ml/edi/xml#">
              <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number>1</xsl:number></xsl:attribute>
              <xsl:value-of select="$context/edi-999:reference/edi-999:reference-number"/>
            </xsl:element>
            <xsl:element name="component" namespace="http://edi4ml/edi/xml#">
              <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number>2</xsl:number></xsl:attribute>
              <xsl:value-of select="$context/edi-999:reference/edi-999:reference-number"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
      <!-- 
      
    <?xml version="1.0" encoding="UTF-8"?>
 
    <segment-context>
      <context-name>SITUATIONAL TRIGGER</context-name>
      <segment-id>TRN</segment-id>
      <segment-position>10</segment-position>
      <loop-identifier>2000</loop-identifier>
    </segment-context>
    <business-unit-identifier>
      <context-name>TRN02</context-name>
    </business-unit-identifier>
    <data-element>
      <element-position>3</element-position>
      <element-reference-number/>
      <error-code>4</error-code>
      <bad-element>9HPPES000</bad-element>
      <element-context>
        <context-name>SITUATIONAL TRIGGER</context-name>
        <segment-id>TRN</segment-id>
        <segment-position>10</segment-position>
        <loop-identifier>2000</loop-identifier>
        <element>
          <element-position/>
          <component-position/>
          <repeating-position/>
        </element>
        <reference>
          <reference-number/>
          <reference-number/>
        </reference>
      </element-context>
    </data-element>
        </error-identification>
        
      </transaction-set-response-header>
     -->

  
  <xsl:template name="parse-ts-trailer">
    <xsl:param name="trailer"/>
    <xsl:element name="segment" namespace="http://edi4ml/edi/xml#">
      <xsl:element name="segment-identifier" namespace="http://edi4ml/edi/xml#">
        <xsl:text>IK5</xsl:text>
      </xsl:element>
      <xsl:element name="fields" namespace="http://edi4ml/edi/xml#">
        <xsl:attribute name="count" namespace="http://edi4ml/edi/xml#"><xsl:number value="2"/></xsl:attribute>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="1"/></xsl:attribute>
          <xsl:value-of select="$element/edi-999:transaction-status"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="2"/></xsl:attribute>
          <xsl:value-of select="$element/edi-999:error-code"/>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
    
  <xsl:template name="parse-fg-trailer">
    <xsl:param name="element"/>
    <xsl:element name="segment" namespace="http://edi4ml/edi/xml#">
      <xsl:element name="segment-identifier" namespace="http://edi4ml/edi/xml#">
        <xsl:text>AK9</xsl:text>
      </xsl:element>
      <xsl:element name="fields" namespace="http://edi4ml/edi/xml#">
        <xsl:attribute name="count" namespace="http://edi4ml/edi/xml#"><xsl:number value="4"/></xsl:attribute>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="1"/></xsl:attribute>
          <xsl:value-of select="$element/edi-999:acknowledgement-code"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="2"/></xsl:attribute>
          <xsl:value-of select="$element/edi-999:included-transaction-sets"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="3"/></xsl:attribute>
          <xsl:value-of select="$element/edi-999:received-transaction-sets"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://edi4ml/edi/xml#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/xml#"><xsl:number value="3"/></xsl:attribute>
          <xsl:value-of select="$element/edi-999:accepted-transaction-sets"/>
        </xsl:element>
      </xsl:element>      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>