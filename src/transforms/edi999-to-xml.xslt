<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:ex="http://edi4ml/edi/xml#">
  <xsl:template match="/">
    <xsl:element name="implementation-acknowledgement" namespace="http://edi4ml/edi/999#">
      <xsl:attribute name="segment-count" namespace="http://edi4ml/edi/metadata#">
        <xsl:number value="max(/ex:edi-document/ex:interchanges/ex:interchange/@ex:end-index/number(.)) - 
          min(/ex:edi-document/ex:interchanges/ex:interchange/@ex:start-index/number(.)) + 1"/>
      </xsl:attribute>
      <xsl:for-each select="/ex:edi-document/ex:interchanges/ex:interchange">
        <xsl:call-template name="interchange">
          <xsl:with-param name="interchange-node" select="."/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="interchange">
    <xsl:param name="interchange-node"/>
    <xsl:element name="interchange" namespace="http://edi4ml/edi/common#">
      <xsl:attribute name="start-index" namespace="http://edi4ml/edi/metadata#"><xsl:value-of
				select="$interchange-node/@ex:start-index" /></xsl:attribute>
	  <xsl:attribute name="stop-index" namespace="http://edi4ml/edi/metadata#"><xsl:value-of
				select="$interchange-node/@ex:end-index" /></xsl:attribute>
      <xsl:element name="authorization" namespace="http://edi4ml/edi/common#">
        <xsl:element name="qualifier" namespace="http://edi4ml/edi/common#">
          <xsl:value-of select="$interchange-node/ex:authorization/ex:qualifier"/>
        </xsl:element>
          <xsl:element name="information" namespace="http://edi4ml/edi/common#">
            <xsl:value-of select="$interchange-node/ex:authorization/ex:information"/>
          </xsl:element>
      </xsl:element>
      <xsl:element name="security" namespace="http://edi4ml/edi/common#">
        <xsl:element name="qualifier" namespace="http://edi4ml/edi/common#">
          <xsl:value-of select="$interchange-node/ex:security/ex:qualifier"/>
        </xsl:element>
          <xsl:element name="information" namespace="http://edi4ml/edi/common#">
            <xsl:value-of select="$interchange-node/ex:security/ex:information"/>
          </xsl:element>
      </xsl:element>
      <xsl:element name="sender" namespace="http://edi4ml/edi/common#">
        <xsl:element name="qualifier" namespace="http://edi4ml/edi/common#">
          <xsl:value-of select="$interchange-node/ex:sender/ex:qualifier"/>
        </xsl:element>
          <xsl:element name="identifier" namespace="http://edi4ml/edi/common#">
            <xsl:value-of select="$interchange-node/ex:sender/ex:identifier"/>
          </xsl:element>
      </xsl:element>
      <xsl:element name="receiver" namespace="http://edi4ml/edi/common#">
        <xsl:element name="qualifier" namespace="http://edi4ml/edi/common#">
          <xsl:value-of select="$interchange-node/ex:receiver/ex:qualifier"/>
        </xsl:element>
        <xsl:element name="identifier" namespace="http://edi4ml/edi/common#">
          <xsl:value-of select="$interchange-node/ex:receiver/ex:identifier"/>
        </xsl:element>
      </xsl:element>
      <xsl:element name="format" namespace="http://edi4ml/edi/common#">
        <xsl:element name="interchange-date" namespace="http://edi4ml/edi/common#">
          <xsl:value-of select="$interchange-node/ex:interchange-date"/>
        </xsl:element>
        <xsl:element name="interchange-time" namespace="http://edi4ml/edi/common#">
          <xsl:value-of select="$interchange-node/ex:interchange-time"/>
        </xsl:element>
        <xsl:element name="component-separator" namespace="http://edi4ml/edi/common#">
          <xsl:value-of select="$interchange-node/ex:component-separator"/>
        </xsl:element>
      </xsl:element>
      <xsl:element name="interchange-standard" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$interchange-node/ex:standard-identifier"/>
      </xsl:element>
      <xsl:element name="control-version" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$interchange-node/ex:control-version"/>
      </xsl:element>
      <xsl:element name="control-number" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$interchange-node/ex:control-number"/>
      </xsl:element>
      <xsl:element name="acknowledgement-required" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$interchange-node/ex:acknowledgement-required"/>
      </xsl:element>
      <xsl:element name="usage" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$interchange-node/ex:usage-indicator"/>
      </xsl:element>
      <xsl:element name="functional-groups" namespace="http://edi4ml/edi/common#">
        <xsl:attribute name="count" namespace="http://edi4ml/edi/common#">
          <xsl:value-of select="$interchange-node/ex:functional-groups/@ex:count"/>
        </xsl:attribute>
        <xsl:for-each select="$interchange-node/ex:functional-groups/ex:functional-group">
          <xsl:call-template name="group">
            <xsl:with-param name="group-node" select="."/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="group">
    <xsl:param name="group-node"/>
    <xsl:element name="functional-group" namespace="http://edi4ml/edi/common#">
      <xsl:attribute name="start-index" namespace="http://edi4ml/edi/metadata#"><xsl:value-of
				select="$group-node/@ex:start-index" /></xsl:attribute>
	  <xsl:attribute name="stop-index" namespace="http://edi4ml/edi/metadata#"><xsl:value-of
				select="$group-node/@ex:end-index" /></xsl:attribute>
      <xsl:element name="functional-code" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$group-node/ex:functional-code"/>
      </xsl:element>
      <xsl:element name="sender" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$group-node/ex:application-sender"/>
      </xsl:element>
      <xsl:element name="receiver" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$group-node/ex:application-receiver"/>
      </xsl:element>
      <xsl:element name="date-format" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$group-node/ex:date-format"/>
      </xsl:element>
      <xsl:element name="time-format" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$group-node/ex:time-format"/>
      </xsl:element>
      <xsl:element name="control-number" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$group-node/ex:control-number"/>
      </xsl:element>
      <xsl:element name="responsible-agency" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$group-node/ex:responsible-agency-code"/>
      </xsl:element>
      <xsl:element name="document-identifier" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$group-node/ex:document-identifier"/>
      </xsl:element>
      <xsl:element name="transaction-sets" namespace="http://edi4ml/edi/common#">
        <xsl:attribute name="count" namespace="http://edi4ml/edi/common#">
          <xsl:value-of select="$group-node/ex:transaction-sets/@ex:count"/>
        </xsl:attribute>
        <xsl:for-each select="$group-node/ex:transaction-sets/ex:transaction-set">
          <xsl:call-template name="transactionset">
    	    <xsl:with-param name="set-node" select="."/>
    	  </xsl:call-template>
        </xsl:for-each>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="transactionset">
    <xsl:param name="set-node"/>
    <xsl:element name="transaction-set" namespace="http://edi4ml/edi/common#">
      <xsl:attribute name="start-index" namespace="http://edi4ml/edi/metadata#"><xsl:value-of
				select="$set-node/@ex:start-index" /></xsl:attribute>
	  <xsl:attribute name="stop-index" namespace="http://edi4ml/edi/metadata#"><xsl:value-of
				select="$set-node/@ex:end-index" /></xsl:attribute>
	  <xsl:attribute name="segment-count" namespace="http://edi4ml/edi/metadata#">
        <xsl:number
				value="number($set-node/@ex:end-index) - number($set-node/@ex:start-index) + 1" />
      </xsl:attribute>
      <xsl:element name="transaction-id" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$set-node/ex:id"/>
      </xsl:element>
      <xsl:element name="control-number" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$set-node/ex:control-number"/>
      </xsl:element>
      <xsl:element name="document-identifier" namespace="http://edi4ml/edi/common#">
        <xsl:value-of select="$set-node/ex:document-identifier"/>
      </xsl:element>
      <!--  Begin Format Specific Handling Here -->
      <xsl:for-each select="$set-node/ex:segments/ex:segment[./ex:segment-identifier = ('AK1', 'AK2', 'AK9')]">
        <xsl:variable name="segment-index" select="./@ex:index"/>
        <xsl:choose>
          <xsl:when test="./ex:segment-identifier='AK1'">
            <xsl:call-template name="AK1">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="./ex:segment-identifier='AK2'">
            <xsl:call-template name="AK2">
              <xsl:with-param name="segment" select="."/>
              <xsl:with-param name="segments" select="$set-node/ex:segments/ex:segment[./@ex:index > $segment-index]"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="./ex:segment-identifier='AK9'">
            <xsl:call-template name="AK9">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise/>
        </xsl:choose>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="AK1">
    <xsl:param name="segment"/>
    <xsl:element name="functional-group-response" namespace="http://edi4ml/edi/999#">
      <xsl:attribute name="segment-index" namespace="http://edi4ml/edi/metadata#"><xsl:value-of
				select="$segment/@ex:index" /></xsl:attribute>
      <xsl:element name="functional-identifier" namespace="http://edi4ml/edi/999#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="control-number" namespace="http://edi4ml/edi/999#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
      <xsl:element name="identifier-code" namespace="http://edi4ml/edi/999#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="AK2">
    <xsl:param name="segment"/>
    <xsl:param name="segments"/>
    <xsl:variable name="next-index" select="min($segments[./ex:segment-identifier=('AK2', 'AK9') and
      ./@ex:index/number(.) gt number($segment/@ex:index)]/@ex:index)"/>
    <xsl:element name="transaction-set-response-header" namespace="http://edi4ml/edi/999#">
      <xsl:attribute name="segment-index" namespace="http://edi4ml/edi/metadata#"><xsl:value-of
				select="$segment/@ex:index" /></xsl:attribute>
      <xsl:element name="transaction-set-identifier" namespace="http://edi4ml/edi/999#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="control-number" namespace="http://edi4ml/edi/999#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
      <xsl:element name="convention-reference" namespace="http://edi4ml/edi/999#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
      <xsl:for-each select="$segments[./@ex:index/number(.) lt number($next-index) and ./ex:segment-identifier = 'IK3']">
        <xsl:variable name="start-index" select="./@ex:index"/>
        <xsl:variable name="stop-index" select="min($segments[./ex:segment-identifier=('IK3', 'IK5') and ./@ex:index/number(.) gt number($start-index)]/@ex:index)"/>
            <xsl:call-template name="IK3">
              <xsl:with-param name="segment" select="."/>
              <xsl:with-param name="segments" select="$segments[./@ex:index/number(.) gt number($start-index) and ./@ex:index/number(.) lt $stop-index]"/>
            </xsl:call-template>
      </xsl:for-each>
      <xsl:for-each select="$segments[./@ex:index/number(.) lt number($next-index) and ./ex:segment-identifier = 'IK5']">
            <xsl:call-template name="IK5">
              <xsl:with-param name="segment" select="."/>
            </xsl:call-template>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="IK3">
    <xsl:param name="segment"/>
    <xsl:param name="segments"/>
    <xsl:variable name="start-index" select="./@ex:index"/>
    <xsl:variable name="context-stop" select="min($segments[./ex:segment-identifier = 'IK4']/@ex:index)"/>
    <xsl:element name="error-identification" namespace="http://edi4ml/edi/999#">
      <xsl:attribute name="segment-index" namespace="http://edi4ml/edi/metadata#"><xsl:value-of
				select="$segment/@ex:index" /></xsl:attribute>
      <xsl:element name="segment-identifier" namespace="http://edi4ml/edi/999#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="segment-position" namespace="http://edi4ml/edi/999#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
      <xsl:element name="loop-identifier" namespace="http://edi4ml/edi/999#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
      <xsl:element name="error-code" namespace="http://edi4ml/edi/999#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
      <xsl:for-each select="$segments[./ex:segment-identifier = 'CTX' and ./@ex:index/number(.) lt number($context-stop)]">
        <xsl:call-template name="CTX">
          <xsl:with-param name="context-node" select="."/>
          <xsl:with-param name="loop-identifier" select="$segment/ex:segment-identifier"/>
        </xsl:call-template>
      </xsl:for-each>
      <xsl:for-each select="$segments[./ex:segment-identifier = 'IK4']">
        <xsl:variable name="ik-loop-start" select="./@ex:index"/>
        <xsl:variable name="ik-loop-stop" select="min(($segments[./ex:segment-identifer = ('IK4', 'IK3') and 
          ./@ex:index/number(.) gt number($ik-loop-start)]/@ex:index, max($segments/@ex:index) + 1))"/>
        <xsl:call-template name="IK4">
          <xsl:with-param name="segment" select="."/>
          <xsl:with-param name="segments" select="$segments[./@ex:index/number(.) gt number($ik-loop-start) and ./@ex:index/number(.) lt number($ik-loop-stop)]"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="CTX">
    <xsl:param name="context-node"/>
    <xsl:param name="loop-identifier"/>
    <xsl:variable name="context" select="$context-node/ex:fields/ex:field[./@ex:index=1]"/>
    <xsl:choose>
      <xsl:when test="$loop-identifier = 'IK3'">
        <xsl:choose>
          <xsl:when test="$context-node/ex:fields/@ex:count = 1">
            <xsl:element name="business-unit-identifier" namespace="http://edi4ml/edi/999#">
              <xsl:attribute name="segment-index" namespace="http://edi4ml/edi/metadata#"><xsl:value-of
				select="$context-node/@ex:index" /></xsl:attribute>
              <xsl:choose>
                <xsl:when test="$context/ex:components/ex:component">
                  <xsl:element name="context-name" namespace="http://edi4ml/edi/999#">
                    <xsl:value-of select="$context/ex:components/ex:component[@ex:index=1]"/> 
                  </xsl:element>
                  <xsl:element name="context-reference" namespace="http://edi4ml/edi/999#">
                    <xsl:value-of select="$context/ex:components/ex:component[@ex:index=2]"/>
                  </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:element name="context-name" namespace="http://edi4ml/edi/999#">
                    <xsl:value-of select="$context"/>
                  </xsl:element>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:element name="segment-context" namespace="http://edi4ml/edi/999#">
              <xsl:attribute name="segment-index" namespace="http://edi4ml/edi/metadata#"><xsl:value-of
				select="$context-node/@ex:index" /></xsl:attribute>
              <xsl:choose>
                <xsl:when test="$context/ex:components/ex:component">
                  <xsl:element name="context-name" namespace="http://edi4ml/edi/999#">
                    <xsl:value-of select="$context/ex:components/ex:component[@ex:index=1]"/> 
                  </xsl:element>
                  <xsl:element name="context-reference" namespace="http://edi4ml/edi/999#">
                    <xsl:value-of select="$context/ex:components/ex:component[@ex:index=2]"/>
                  </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:element name="context-name" namespace="http://edi4ml/edi/999#">
                    <xsl:value-of select="$context"/>
                  </xsl:element>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:element name="segment-identification" namespace="http://edi4ml/edi/999#">
                <xsl:value-of select="$context-node/ex:fields/ex:field[./@ex:index=2]"/>
              </xsl:element>
              <xsl:element name="segment-position" namespace="http://edi4ml/edi/999#">
                <xsl:value-of select="$context-node/ex:fields/ex:field[./@ex:index=3]"/>
              </xsl:element>
              <xsl:element name="loop-identifier" namespace="http://edi4ml/edi/999#">
                <xsl:value-of select="$context-node/ex:fields/ex:field[./@ex:index=4]"/>
              </xsl:element>
              <xsl:if test="$context-node/ex:fields/ex:field[./@ex:index=5]">
			<xsl:element name="position-in-segment" namespace="http://edi4ml/edi/999#">
				<xsl:choose>
					<xsl:when
						test="$context-node/ex:fields/ex:field[./@ex:index=5]/ex:components/ex:component">
						<xsl:element name="element-position" namespace="http://edi4ml/edi/999#">
							<xsl:value-of
								select="$context-node/ex:fields/ex:field[./@ex:index=5]/ex:components/ex:component[./@ex:index=1]" />
						</xsl:element>
						<xsl:element name="component-position" namespace="http://edi4ml/edi/999#">
							<xsl:value-of
								select="$context-node/ex:fields/ex:field[./@ex:index=5]/ex:components/ex:component[./@ex:index=2]" />
						</xsl:element>
						<xsl:element name="repeating-position" namespace="http://edi4ml/edi/999#">
							<xsl:value-of
								select="$context-node/ex:fields/ex:field[./@ex:index=5]/ex:components/ex:component[./@ex:index=3]" />
						</xsl:element>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$context-node/ex:fields/ex:field[./@ex:index=5]" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:if test="$context-node/ex:fields/ex:field[./@ex:index=6]">
				<xsl:element name="reference" namespace="http://edi4ml/edi/999#">
					<xsl:element name="reference-number" namespace="http://edi4ml/edi/999#">
						<xsl:value-of
							select="$context-node/ex:fields/ex:field[./@ex:index=6]/ex:components/ex:component[./@ex:index=1]" />
					</xsl:element>
					<xsl:element name="reference-number" namespace="http://edi4ml/edi/999#">
						<xsl:value-of
							select="$context-node/ex:fields/ex:field[./@ex:index=6]/ex:components/ex:component[./@ex:index=2]" />
					</xsl:element>
				</xsl:element>
			</xsl:if>
		</xsl:if>
            </xsl:element>
          </xsl:otherwise>
        </xsl:choose>        
      </xsl:when>
      <xsl:otherwise>
      <xsl:element name="element-context" namespace="http://edi4ml/edi/999#">
        <xsl:attribute name="segment-index" namespace="http://edi4ml/edi/metadata#"><xsl:value-of
				select="$context-node/@ex:index" /></xsl:attribute>
        <xsl:choose>
          <xsl:when test="$context/ex:components/ex:component">
            <xsl:element name="context-name" namespace="http://edi4ml/edi/999#">
              <xsl:value-of select="$context/ex:components/ex:component[@ex:index=1]"/> 
             </xsl:element>
             <xsl:element name="context-reference" namespace="http://edi4ml/edi/999#">
               <xsl:value-of select="$context/ex:components/ex:component[@ex:index=2]"/>
             </xsl:element>
           </xsl:when>
           <xsl:otherwise>
             <xsl:element name="context-name" namespace="http://edi4ml/edi/999#">
               <xsl:value-of select="$context"/>
             </xsl:element>
           </xsl:otherwise>
         </xsl:choose>
         <xsl:element name="segment-identification" namespace="http://edi4ml/edi/999#">
           <xsl:value-of select="$context-node/ex:fields/ex:field[./@ex:index=2]"/>
         </xsl:element>
         <xsl:element name="segment-position" namespace="http://edi4ml/edi/999#">
                <xsl:value-of select="$context-node/ex:fields/ex:field[./@ex:index=3]"/>
              </xsl:element>
              <xsl:element name="loop-identifier" namespace="http://edi4ml/edi/999#">
                <xsl:value-of select="$context-node/ex:fields/ex:field[./@ex:index=4]"/>
              </xsl:element>
             <xsl:if test="$context-node/ex:fields/ex:field[./@ex:index=5]">
			<xsl:element name="position-in-segment" namespace="http://edi4ml/edi/999#">
				<xsl:choose>
					<xsl:when
						test="$context-node/ex:fields/ex:field[./@ex:index=5]/ex:components/ex:component">
						<xsl:element name="element-position" namespace="http://edi4ml/edi/999#">
							<xsl:value-of
								select="$context-node/ex:fields/ex:field[./@ex:index=5]/ex:components/ex:component[./@ex:index=1]" />
						</xsl:element>
						<xsl:element name="component-position" namespace="http://edi4ml/edi/999#">
							<xsl:value-of
								select="$context-node/ex:fields/ex:field[./@ex:index=5]/ex:components/ex:component[./@ex:index=2]" />
						</xsl:element>
						<xsl:element name="repeating-position" namespace="http://edi4ml/edi/999#">
							<xsl:value-of
								select="$context-node/ex:fields/ex:field[./@ex:index=5]/ex:components/ex:component[./@ex:index=3]" />
						</xsl:element>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$context-node/ex:fields/ex:field[./@ex:index=5]" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:if test="$context-node/ex:fields/ex:field[./@ex:index=6]">
				<xsl:element name="reference" namespace="http://edi4ml/edi/999#">
					<xsl:element name="reference-number" namespace="http://edi4ml/edi/999#">
						<xsl:value-of
							select="$context-node/ex:fields/ex:field[./@ex:index=6]/ex:components/ex:component[./@ex:index=1]" />
					</xsl:element>
					<xsl:element name="reference-number" namespace="http://edi4ml/edi/999#">
						<xsl:value-of
							select="$context-node/ex:fields/ex:field[./@ex:index=6]/ex:components/ex:component[./@ex:index=2]" />
					</xsl:element>
				</xsl:element>
			</xsl:if>
		</xsl:if>
            </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="IK4">
    <xsl:param name="segment"/>
    <xsl:param name="segments"/>
    <xsl:variable name="position-field" select="$segment/ex:fields/ex:field[@ex:index=1]"/>
    <xsl:element name="data-element" namespace="http://edi4ml/edi/999#">
      <xsl:attribute name="segment-index" namespace="http://edi4ml/edi/metadata#"><xsl:value-of
				select="$segment/@ex:index" /></xsl:attribute>
      <xsl:choose>
        <xsl:when test="$position-field/ex:components/ex:component">
          <xsl:element name="element-position" namespace="http://edi4ml/edi/999#">
            <xsl:value-of select="$position-field/ex:components/ex:component[./@ex:index=1]"/>
          </xsl:element>
          <xsl:element name="element-component-position" namespace="http://edi4ml/edi/999#">
            <xsl:value-of select="$position-field/ex:components/ex:component[./@ex:index=2]"/>
          </xsl:element>
          <xsl:element name="element-repeating-position" namespace="http://edi4ml/edi/999#">
            <xsl:value-of select="$position-field/ex:components/ex:component[./@ex:index=3]"/>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="element-position" namespace="http://edi4ml/edi/999#">
            <xsl:value-of select="$position-field"/>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>      
      <xsl:element name="element-reference-number" namespace="http://edi4ml/edi/999#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
      <xsl:element name="error-code" namespace="http://edi4ml/edi/999#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
      <xsl:element name="bad-element" namespace="http://edi4ml/edi/999#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
      <xsl:for-each select="$segments[./ex:segment-identifier = 'CTX']">
        <xsl:call-template name="CTX">
          <xsl:with-param name="context-node" select="."/>
          <xsl:with-param name="loop-identifier" select="$segment/ex:segment-identifier"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="IK5">
    <xsl:param name="segment"/>
    <xsl:element name="transaction-set-response-trailer" namespace="http://edi4ml/edi/999#">
      <xsl:attribute name="segment-index" namespace="http://edi4ml/edi/metadata#"><xsl:value-of
				select="$segment/@ex:index" /></xsl:attribute>
      <xsl:element name="transaction-status" namespace="http://edi4ml/edi/999#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:for-each select="$segment/ex:fields/ex:field[./@ex:index > 1]">
        <xsl:element name="error-code" namespace="http://edi4ml/edi/999#">
          <xsl:attribute name="index" namespace="http://edi4ml/edi/metadata#"><xsl:value-of select="./@ex:index"/></xsl:attribute>
          <xsl:value-of select="."/>
        </xsl:element>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="AK9">
    <xsl:param name="segment"/>
    <xsl:element name="functional-group-response-trailer" namespace="http://edi4ml/edi/999#">
      <xsl:attribute name="segment-index" namespace="http://edi4ml/edi/metadata#"><xsl:value-of
				select="$segment/@ex:index" /></xsl:attribute>
      <xsl:element name="acknowledgment-code" namespace="http://edi4ml/edi/999#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
      </xsl:element>
      <xsl:element name="included-transaction-sets" namespace="http://edi4ml/edi/999#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]"/>
      </xsl:element>
      <xsl:element name="received-transaction-sets" namespace="http://edi4ml/edi/999#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]"/>
      </xsl:element>
      <xsl:element name="accepted-transaction-sets" namespace="http://edi4ml/edi/999#">
        <xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]"/>
      </xsl:element>
      <xsl:for-each select="$segment/ex:fields/ex:field[./@ex:index > 4]">
        <xsl:element name="error-code" namespace="http://edi4ml/edi/999#">
          <xsl:value-of select="."/>
        </xsl:element>
      </xsl:for-each> 
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>