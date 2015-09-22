<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:ex="http://marklogic.com/edi/xml"
  xmlns:edi="http://marklogic.com/edi/common#"
  xmlns:edi-ns="http://marklogic.com/edi/999#">
  <xsl:variable name="segment-count" />

  <xsl:template match="/edi-common:implementation-acknowledgement">
    <xsl:element name="edi-document" namespace="http://marklogic.com/edi/xml">
      <xsl:element name="segments" namespace="http://marklogic.com/edi/xml">
        <xsl:for-each select="./edi-common:interchange">
          <xsl:call-template name="parse-interchange">
            <xsl:with-param name="interchange" select="."/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:element>
    </xsl:element>
  </xsl:template>
    
  <xsl:template name="parse-interchange">
    <xsl:param name="interchange"/>
    <xsl:element name="segment" namespace="http://marklogic.com/edi/xml">
      <xsl:element name="segment-identifier" namespace="http://marklogic.com/edi/xml">
        <xsl:text>ISA</xsl:text>
      </xsl:element>
      <xsl:element name="fields" namespace="http://marklogic.com/edi/xml">
        <xsl:attribute name="count"><xsl:number value="16"/></xsl:attribute>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="1"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi-common:authorization/edi-common:qualifier"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="2"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi-common:authorization/edi-common:identifier"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="3"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi-ns:security/edi-ns:qualifier"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="4"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi-ns:security/edi-ns:identifier"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="5"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi-ns:sender/edi-ns:qualifier"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="6"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi-ns:sender/edi-ns:identifier"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="7"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi-ns:receiver/edi-ns:qualifier"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="8"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi-ns:receiver/edi-ns:identifier"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="9"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi-ns:format/edi-ns:interchange-date"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="10"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi-ns:format/edi-ns:interchange-time"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="11"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi-ns:interchange-standard"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="12"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi-ns:control-version"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="13"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi-ns:control-number"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="14"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi-ns:acknowledgement-required"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="15"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi-ns:usage"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="16"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi-ns:format/edi-ns:component-separator"/>
        </xsl:element>
      </xsl:element>
    </xsl:element>
    <xsl:for-each select="$interchange/edi-ns:functional-groups/edi-ns:group">
      <xsl:call-template name="parse-group">
        <xsl:with-param name="group" select="."/>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:element name="segment" namespace="http://marklogic.com/edi/xml">
      <xsl:element name="segment-identifier" namespace="http://marklogic.com/edi/xml">
        <xsl:text>IEA</xsl:text>
      </xsl:element>
      <xsl:element name="fields" namespace="http://marklogic.com/edi/xml">
        <xsl:attribute name="count"><xsl:number value="2"/></xsl:attribute>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="1"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi-ns:functional-groups/@count"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="2"/></xsl:attribute>
          <xsl:value-of select="$interchange/edi-ns:control-number"/>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="parse-group">
    <xsl:param name="group"/>
    <xsl:element name="segment" namespace="http://marklogic.com/edi/xml">
      <xsl:element name="segment-identifier" namespace="http://marklogic.com/edi/xml">
        <xsl:text>GS</xsl:text>
      </xsl:element>
      <xsl:element name="fields" namespace="http://marklogic.com/edi/xml">
        <xsl:attribute name="count"><xsl:number value="8"/></xsl:attribute>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="1"/></xsl:attribute>
          <xsl:value-of select="$group/edi-ns:functional-code"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="2"/></xsl:attribute>
          <xsl:value-of select="$group/edi-ns:sender"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="3"/></xsl:attribute>
          <xsl:value-of select="$group/edi-ns:receiver"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="4"/></xsl:attribute>
          <xsl:value-of select="$group/edi-ns:date-format"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="5"/></xsl:attribute>
          <xsl:value-of select="$group/edi-ns:time-format"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="6"/></xsl:attribute>
          <xsl:value-of select="$group/edi-ns:control-number"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="7"/></xsl:attribute>
          <xsl:value-of select="$group/edi-ns:responsible-agency"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="8"/></xsl:attribute>
          <xsl:value-of select="$group/edi-ns:document-identifier"/>
        </xsl:element>
      </xsl:element>
    </xsl:element>
      <xsl:for-each select="$group/edi-ns:transaction-sets/edi-ns:transaction-set">
        <xsl:call-template name="parse-set">
          <xsl:with-param name="set" select="."/>
        </xsl:call-template>
      </xsl:for-each>
      <xsl:element name="segment" namespace="http://marklogic.com/edi/xml">
        <xsl:element name="segment-identifier" namespace="http://marklogic.com/edi/xml">
          <xsl:text>GE</xsl:text>
        </xsl:element>
        <xsl:element name="fields" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="count"><xsl:number value="2"/></xsl:attribute>
          <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
            <xsl:attribute name="index"><xsl:number value="1"/></xsl:attribute>
            <xsl:value-of select="$group/edi-ns:transaction-sets/@count"/>
          </xsl:element>
          <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
            <xsl:attribute name="index"><xsl:number value="2"/></xsl:attribute>
            <xsl:value-of select="$group/edi-ns:control-number"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
  </xsl:template>
  
  <xsl:template name="parse-set">
    <xsl:param name="set"/>
    <xsl:variable name="segment-count" select="0"/>
    <xsl:element name="segment" namespace="http://marklogic.com/edi/xml">
      <xsl:element name="segment-identifier" namespace="http://marklogic.com/edi/xml">
        <xsl:text>ST</xsl:text>
      </xsl:element>
      <xsl:element name="fields" namespace="http://marklogic.com/edi/xml">
        <xsl:attribute name="count"><xsl:number value="2"/></xsl:attribute>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="1"/></xsl:attribute>
          <xsl:value-of select="$set/edi-ns:transaction-id"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="2"/></xsl:attribute>
          <xsl:value-of select="$set/edi-ns:control-number"/>
        </xsl:element>
      </xsl:element>
    </xsl:element>
      <xsl:for-each select="$set/*[local-name(.) != 'control-number' and local-name(.) != 'transaction-id']">
        <xsl:call-template name="parse-element">
          <xsl:with-param name="element" select="."/>
        </xsl:call-template>
      </xsl:for-each>
      <xsl:element name="segment" namespace="http://marklogic.com/edi/xml">
        <xsl:element name="segment-identifier" namespace="http://marklogic.com/edi/xml">
          <xsl:text>SE</xsl:text>
        </xsl:element>
        <xsl:element name="fields" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="count"><xsl:number value="2"/></xsl:attribute>
          <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
            <xsl:attribute name="index"><xsl:number value="1"/></xsl:attribute>
            <xsl:number value="$segment-count"/>
          </xsl:element>
          <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
            <xsl:attribute name="index"><xsl:number value="2"/></xsl:attribute>
            <xsl:value-of select="$set/edi-ns:control-number"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
  </xsl:template>
  
  <xsl:template name="parse-element">
    <xsl:param name="element"/>
    <xsl:choose>
      <xsl:when test="local-name($element) = 'functional-group-response'">
        <xsl:variable name="segment-count" value="$segment-count + 1"/>
        <xsl:element name="segment" namespace="http://marklogic.com/edi/xml">
          <xsl:element name="segment-identifier" namespace="http://marklogic.com/edi/xml">
            <xsl:text>AK1</xsl:text>
          </xsl:element>
          <xsl:element name="fields" namespace="http://marklogic.com/edi/xml">
            <xsl:attribute name="count"><xsl:number value="3"/></xsl:attribute>
            <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
              <xsl:attribute name="index"><xsl:number value="1"/></xsl:attribute>
              <xsl:value-of select="$element/edi-ns:functional-identifier"/>
            </xsl:element>
            <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
              <xsl:attribute name="index"><xsl:number value="2"/></xsl:attribute>
              <xsl:value-of select="$element/edi-ns:control-number"/>
            </xsl:element>
            <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
              <xsl:attribute name="index"><xsl:number value="3"/></xsl:attribute>
              <xsl:value-of select="$element/edi-ns:identifier-code"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:when>
      <xsl:when test="local-name($element) = 'transaction-set-response-header'">
        <xsl:variable name="segment-count" value="$segment-count + 1"/>
        <xsl:element name="segment" namespace="http://marklogic.com/edi/xml">
          <xsl:element name="segment-identifier" namespace="http://marklogic.com/edi/xml">
            <xsl:text>AK2</xsl:text>
          </xsl:element>
          <xsl:element name="fields" namespace="http://marklogic.com/edi/xml">
            <xsl:attribute name="count"><xsl:number value="3"/></xsl:attribute>
            <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
              <xsl:attribute name="index"><xsl:number value="1"/></xsl:attribute>
              <xsl:value-of select="$element/edi-ns:transaction-set-identifier"/>
            </xsl:element>
            <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
              <xsl:attribute name="index"><xsl:number value="2"/></xsl:attribute>
              <xsl:value-of select="$element/edi-ns:control-number"/>
            </xsl:element>
            <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
              <xsl:attribute name="index"><xsl:number value="3"/></xsl:attribute>
              <xsl:value-of select="$element/edi-ns:convention-reference"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        <xsl:for-each select="$element/edi-ns:error-identification">
          <xsl:call-template name="parse-error">
            <xsl:with-param name="error" select="."/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="local-name($element) = 'transaction-set-response-trailer'">
       <xsl:element name="segment" namespace="http://marklogic.com/edi/xml">
          <xsl:variable name="segment-count" value="$segment-count + 1"/>
          <xsl:element name="segment-identifier" namespace="http://marklogic.com/edi/xml">
            <xsl:text>IK5</xsl:text>
          </xsl:element>
          <xsl:element name="fields" namespace="http://marklogic.com/edi/xml">
            <xsl:attribute name="index"><xsl:number value="6"/></xsl:attribute>
            <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
              <xsl:attribute name="index"><xsl:number value="1"/></xsl:attribute>
              <xsl:value-of select="$element/edi-ns:transaction-status"/>
            </xsl:element>
            <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
              <xsl:attribute name="index"><xsl:number value="2"/></xsl:attribute>
              <xsl:value-of select="$element/edi-ns:error-code[1]"/>
            </xsl:element>
            <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
              <xsl:attribute name="index"><xsl:number value="3"/></xsl:attribute>
              <xsl:value-of select="$element/edi-ns:error-code[2]"/>
            </xsl:element>
            <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
              <xsl:attribute name="index"><xsl:number value="4"/></xsl:attribute>
              <xsl:value-of select="$element/edi-ns:error-code[3]"/>
            </xsl:element>
            <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
              <xsl:attribute name="index"><xsl:number value="5"/></xsl:attribute>
              <xsl:value-of select="$element/edi-ns:error-code[4]"/>
            </xsl:element>
            <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
              <xsl:attribute name="index"><xsl:number value="6"/></xsl:attribute>
              <xsl:value-of select="$element/edi-ns:error-code[5]"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:when>
      <xsl:when test="local-name($element) = 'functional-group-response-trailer'">
       <xsl:variable name="segment-count" value="$segment-count + 1"/>
       <xsl:element name="segment" namespace="http://marklogic.com/edi/xml">
          <xsl:element name="segment-identifier" namespace="http://marklogic.com/edi/xml">
            <xsl:text>AK9</xsl:text>
          </xsl:element>
          <xsl:element name="fields" namespace="http://marklogic.com/edi/xml">
            <xsl:attribute name="count"><xsl:number value="9"/></xsl:attribute>
            <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
              <xsl:attribute name="index"><xsl:number value="1"/></xsl:attribute>
              <xsl:value-of select="$element/edi-ns:acknowledgment-code"/>
            </xsl:element>
            <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
              <xsl:attribute name="index"><xsl:number value="2"/></xsl:attribute>
              <xsl:value-of select="$element/edi-ns:included-transaction-sets"/>
            </xsl:element>
            <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
              <xsl:attribute name="index"><xsl:number value="3"/></xsl:attribute>
              <xsl:value-of select="$element/edi-ns:received-transaction-sets"/>
            </xsl:element>
            <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
              <xsl:attribute name="index"><xsl:number value="4"/></xsl:attribute>
              <xsl:value-of select="$element/edi-ns:accepted-transaction-sets"/>
            </xsl:element>
            <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
              <xsl:attribute name="index"><xsl:number value="5"/></xsl:attribute>
              <xsl:value-of select="$element/edi-ns:error-code[1]"/>
            </xsl:element>
            <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
              <xsl:attribute name="index"><xsl:number value="6"/></xsl:attribute>
              <xsl:value-of select="$element/edi-ns:error-code[2]"/>
            </xsl:element>
            <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
              <xsl:attribute name="index"><xsl:number value="7"/></xsl:attribute>
              <xsl:value-of select="$element/edi-ns:error-code[3]"/>
            </xsl:element>
            <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
              <xsl:attribute name="index"><xsl:number value="8"/></xsl:attribute>
              <xsl:value-of select="$element/edi-ns:error-code[4]"/>
            </xsl:element>
            <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
              <xsl:attribute name="index"><xsl:number value="9"/></xsl:attribute>
              <xsl:value-of select="$element/edi-ns:error-code[5]"/>
            </xsl:element>
          </xsl:element>
        </xsl:element> 
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="parse-error">
    <xsl:param name="error"/>
    <xsl:variable name="segment-count" value="$segment-count + 1"/>
    <xsl:element name="segment" namespace="http://marklogic.com/edi/xml">
      <xsl:element name="segment-identifier" namespace="http://marklogic.com/edi/xml">
        <xsl:text>IK3</xsl:text>
      </xsl:element>
      <xsl:element name="fields" namespace="http://marklogic.com/edi/xml">
        <xsl:attribute name="count"><xsl:number value="4"/></xsl:attribute>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="1"/></xsl:attribute>
          <xsl:value-of select="$error/edi-ns:segment-identifier"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="2"/></xsl:attribute>
          <xsl:value-of select="$error/edi-ns:segment-position"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="3"/></xsl:attribute>
          <xsl:value-of select="$error/edi-ns:loop-identifier"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="4"/></xsl:attribute>
          <xsl:value-of select="$error/edi-ns:error-code"/>
        </xsl:element>
      </xsl:element>
    </xsl:element>
    <xsl:for-each select="$error/edi-ns:segment-context">
      <xsl:call-template name="parse-context">
        <xsl:with-param name="context" select="."/>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:for-each select="$error/edi-ns:business-unit-identifier">
       <xsl:element name="segment" namespace="http://marklogic.com/edi/xml">
         <xsl:variable name="segment-count" value="$segment-count + 1"/>
         <xsl:element name="segment-identifier" namespace="http://marklogic.com/edi/xml">
           <xsl:text>CTX</xsl:text>
         </xsl:element>
         <xsl:element name="fields" namespace="http://marklogic.com/edi/xml">
           <xsl:attribute name="count"><xsl:number value="1"/></xsl:attribute>
           <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
             <xsl:attribute name="index"><xsl:number value="1"/></xsl:attribute>
             <xsl:value-of select="."/>
           </xsl:element>
         </xsl:element> 
       </xsl:element>
    </xsl:for-each>
    <xsl:for-each select="$error/edi-ns:data-element">
      <xsl:call-template name="parse-element-error">
        <xsl:with-param name="element" select="."/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="parse-element-error">
    <xsl:param name="element"/>
    <xsl:element name="segment" namespace="http://marklogic.com/edi/xml">
      <xsl:variable name="segment-count" value="$segment-count + 1"/>
      <xsl:element name="segement-identifier" namespace="http://marklogic.com/edi/xml">
        <xsl:text>IK4</xsl:text>
      </xsl:element>
      <xsl:element name="fields" namespace="http://marklogic.com/edi/xml">
        <xsl:attribute name="count"><xsl:number value="4"/></xsl:attribute>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="1"/></xsl:attribute>
          <xsl:choose>
            <xsl:when test="$element/edi-ns:element-component-position">
              <xsl:element name="components" namespace="http://marklogic.com/edi/xml">
                <xsl:attribute name="count"><xsl:number value="3"/></xsl:attribute>
                <xsl:element name="component" namespace="http://marklogic.com/edi/xml">
                  <xsl:attribute name="index"><xsl:number value="1"/></xsl:attribute>
                  <xsl:value-of select="$element/edi-ns:element-position"/>
                </xsl:element>
                <xsl:element name="component" namespace="http://marklogic.com/edi/xml">
                  <xsl:attribute name="index"><xsl:number value="2"/></xsl:attribute>
                  <xsl:value-of select="$element/edi-ns:element-component-position"/>
                </xsl:element>
                <xsl:element name="component" namespace="http://marklogic.com/edi/xml">
                  <xsl:attribute name="index"><xsl:number value="3"/></xsl:attribute>
                  <xsl:value-of select="$element/edi-ns:element-repeating-position"/>
                </xsl:element>
              </xsl:element>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$element/edi-ns:element-position"/>
            </xsl:otherwise>
          </xsl:choose>          
        </xsl:element>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="2"/></xsl:attribute>
          <xsl:value-of select="$element/edi-ns:element-reference-number"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="3"/></xsl:attribute>
          <xsl:value-of select="$element/edi-ns:error-code"/>
        </xsl:element>
        <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="index"><xsl:number value="4"/></xsl:attribute>
          <xsl:value-of select="$element/edi-ns:bad-element"/>
        </xsl:element>
      </xsl:element>
    </xsl:element>
    <xsl:for-each select="$element/edi-ns:element-context">
      <xsl:call-template name="parse-context">
        <xsl:with-param name="error-context" select="."/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="parse-context">
    <xsl:param name="error-context"/>
    <xsl:element name="segment" namespace="http://marklogic.com/edi/xml">
      <xsl:variable name="segment-count" select="$segment-count + 1"/>
        <xsl:element name="segment-identifier" namespace="http://marklogic.com/edi/xml">
          <xsl:text>CTX</xsl:text>
        </xsl:element>
        <xsl:element name="fields" namespace="http://marklogic.com/edi/xml">
          <xsl:attribute name="count"><xsl:number value="5"/></xsl:attribute>
          <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
            <xsl:attribute name="index"><xsl:number value="1"/></xsl:attribute>
            <xsl:value-of select="./edi-ns:context-identification"/>
          </xsl:element>
          <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
            <xsl:attribute name="index"><xsl:number value="2"/></xsl:attribute>
            <xsl:value-of select="./edi-ns:segment-identification"/>
          </xsl:element>
          <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
            <xsl:attribute name="index"><xsl:number value="3"/></xsl:attribute>
            <xsl:value-of select="./edi-ns:segment-position"/>
          </xsl:element>
          <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
            <xsl:attribute name="index"><xsl:number value="4"/></xsl:attribute>
            <xsl:value-of select="./edi-ns:loop-identifier"/>
          </xsl:element>
          <xsl:element name="field" namespace="http://marklogic.com/edi/xml">
            <xsl:attribute name="index"><xsl:number value="5"/></xsl:attribute>
            <xsl:choose>
              <xsl:when test="./edi-ns:component-position">
              <xsl:element name="components" namespace="http://marklogic.com/edi/xml">
              <xsl:attribute name="count"><xsl:number value="3"/></xsl:attribute>
              <xsl:element name="component" namespace="http://marklogic.com/edi/xml">
                <xsl:attribute name="index"><xsl:number value="1"/></xsl:attribute>
                <xsl:value-of select="./edi-ns:element-position"/>
              </xsl:element>
              <xsl:element name="component" namespace="http://marklogic.com/edi/xml">
                <xsl:attribute name="index"><xsl:number value="2"/></xsl:attribute>
                <xsl:value-of select="./edi-ns:component-position"/>
              </xsl:element>
              <xsl:element name="component" namespace="http://marklogic.com/edi/xml">
                <xsl:attribute name="index"><xsl:number value="3"/></xsl:attribute>
                <xsl:value-of select="./edi-ns:repeating-position"/>
              </xsl:element>
            </xsl:element>
              </xsl:when>
              <xsl:otherwise><xsl:value-of select="./edi-ns:element-position"/></xsl:otherwise>
            </xsl:choose>
          </xsl:element>
        </xsl:element>
      </xsl:element>
  </xsl:template>
</xsl:stylesheet>