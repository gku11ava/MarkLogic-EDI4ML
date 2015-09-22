<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:ex="http://marklogic.com/edi/xml">
  <xsl:template match="/">
    <xsl:element name="edi-document" namespace="http://marklogic.com/edi/xml">
      <ex:document-type>999</ex:document-type>
<!--  -->      <xsl:for-each select="ex:interchanges/ex:interchange">
        <xsl:call-template name="interchange">
          <xsl:with-param name="interchange-node"/>
        </xsl:call-template>
      </xsl:for-each> -->
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="interchange">
    <xsl:param name="interchange-node"/>
    <xsl:copy>
      <xsl:for-each select="interchange-node/*">
        <xsl:choose>
          <xsl:when test="fn:node-name(.) = 'functional-groups'">
          	<xsl:copy>
              <xsl:attribute name="count">
                <xsl:value-of select="./@count"/>
          	  </xsl:attribute>
          	  <xsl:for-each select="./ex:group">
          	    <xsl:call-template name="group">
          	      <xsl:with-param name="group-node" select="."/>
          	    </xsl:call-template>
          	  </xsl:for-each>
          	</xsl:copy>
          </xsl:when>
          <xsl:when test="fn:starts-with(fn:node-name(.), 'original-')"/>
          <xsl:otherwise>
            <xsl:copy-of/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="group">
    <xsl:param name="group-node"/>
    <xsl:copy>
    	<xsl:for-each select="group-node/*">
    	  <xsl:choose>
    	    <xsl:when test="fn:node-name(.) = 'transaction-sets">
    	      <xsl:copy>
    	        <xsl:attribute name="count">
    	          <xsl:value-of select="./@count"/>
    	        </xsl:attribute>
    	        <xsl:for-each select="./ex:transaction-set">
    	          <xsl:call-template name="transactionset">
    	            <xsl:with-param name="set-node" select="."/>
    	          </xsl:call-template>
    	        </xsl:for-each>
    	      </xsl:copy>
    	    </xsl:when>
    	    <xsl:when test="fn:starts-with()fn:node-name(.), 'original-')"/>
    	    <xsl:otherwise>
    	      <xsl:copy-of/>
    	    </xsl:otherwise>
    	  </xsl:choose>
    	</xsl:for-each>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="transactionset">
    <xsl:param name="set-node"/>
    <xsl:copy>
    	<xsl:for-each select="set-node/*">
    	  <xsl:choose>
    	    <xsl:when test="fn:starts-with(fn:node-name(.), 'original-')"/>
    	    <xsl:when test="fn:node-name(.) = 'segments'">
    	      <xsl:for-each select="./ex:segment">
    	        <xsl:call-template name="segment">
    	          <xsl:with-param name="segment-node" select="."/>
    	          <xsl:with-param name="segments" select="set-node/ex:segments"/>
    	        </xsl:call-template>
    	      </xsl:for-each>
    	    </xsl:when>
    	    <xsl:otherwise>
    	      <xsl:copy-of/>
    	    </xsl:otherwise>
    	  </xsl:choose>
    	</xsl:for-each>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="segment">
    <xsl:param name="segment-node"/>
    <xsl:param name="segments"/>
    <xsl:choose>
      <xsl:when test="segment-node/ex:segment-identifier = 'AK1'">
        <xsl:call-template name="AK1">
          <xsl:with-param name="segment-node" select="segment-node"/>
          <xsl:with-param name="segments" select="segments"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="segment-node/ex:segment-identifier = 'AK2'">
        <xsl:call-template name="AK2">
          <xsl:with-param name="segment-node" select="segment-node"/>
          <xsl:with-param name="segments" select="segments"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="segment-node/ex:segment-identifier = 'IK3'">
        <xsl:call-template name="IK3">
          <xsl:with-param name="segment-node" select="segment-node"/>
          <xsl:with-param name="segments" select="segments"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="segment-node/ex:segment-identifier = 'AK9'">
        <xsl:call-template name="AK9">
          <xsl:with-param name="segment-node" select="segment-node"/>
          <xsl:with-param name="segments" select="segments"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="AK1">
    <xsl:param name="segment-node"/>
    <xsl:param name="segments"/>
    <xsl:element name="functional-group-response" namespace="http://marklogic.com/edi/999">
      <xsl:element name="functional-identifier" namespace="http://marklogic.com/edi/999">
        <xsl:value-of select="segment-node/ex:fields/ex:field[./@index=1]"/>
      </xsl:element>
      <xsl:element name="group-control-number" namespace="http://marklogic.com/edi/999">
        <xsl:value-of select="segment-node/ex:fields/ex:field[./@index=2]"/>
      </xsl:element>
      <xsl:element name="identifier-code" namespace="http://marklogic.com/edi/999">
        <xsl:value-of select="segment-node/ex:fields/ex:field[./@index=3]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="AK2">
    <xsl:param name="segment-node"/>
    <xsl:param name="segments"/>
    <xsl:element name="transaction-set-response-header" namespace="http://marklogic.com/edi/999">
      <xsl:element name="transaction-set-identifier" namespace="http://marklogic.com/edi/999">
        <xsl:value-of select="segment-node/ex:fields/ex:field[./@index=1]"/>
      </xsl:element>
      <xsl:element name="set-control-number" namespace="http://marklogic.com/edi/999">
        <xsl:value-of select="segment-node/ex:fields/ex:field[./@index=2]"/>
      </xsl:element>
      <xsl:element name="convention-reference" namespace="http://marklogic.com/edi/999">
        <xsl:value-of select="segment-node/ex:fields/ex:field[./@index=3]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="IK3">
    <xsl:param name="segment-node"/>
    <xsl:param name="segments"/>
    <xsl:element name="error-identification" namespace="http://marklogic.com/edi/999">
      <xsl:element name="segment-identifier" namespace="http://marklogic.com/edi/999">
        <xsl:value-of select="segment-node/ex:fields/ex:field[./@index=1]"/>
      </xsl:element>
      <xsl:element name="segment-position" namespace="http://marklogic.com/edi/999">
        <xsl:value-of select="segment-node/ex:fields/ex:field[./@index=2]"/>
      </xsl:element>
      <xsl:element name="loop-identifier" namespace="http://marklogic.com/edi/999">
        <xsl:value-of select="segment-node/ex:fields/ex:field[./@index=3]"/>
      </xsl:element>
      <xsl:element name="error-code" namespace="http://marklogic.com/edi/999">
        <xsl:value-of select="segment-node/ex:fields/ex:field[./@index=4]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="CTX">
    <xsl:param name="segment-node"/>
    <xsl:param name="segments"/>
    <xsl:param name="loop-parent"/>
    <xsl:variable name="context" select="segment-node/ex:fields/ex:field[./@index=1]"/>
    <xsl:choose>
      <xsl:when test="loop-parent/ex:segment-identifier = 'IK3' and segment-node/ex:fields/@count = 1">
        <xsl:element name="business-unit-identifier" namespace="http://marklogic.com/edi/999">
          <xsl:choose>
            <xsl:when test="context/ex:components/ex:component">
              <xsl:element name="context-name" namespace="http://marklogic.com/edi/999">
                <xsl:value-of select="context/ex:components/ex:component[@index=1]"/> 
              </xsl:element>
              <xsl:element name="context-reference" namespace="http://marklogic.com/edi/999">
                <xsl:value-of select="context/ex:components/ex:component[@index=2]"/>
              </xsl:element>
            </xsl:when>
            <xsl:otherwise>
              <xsl:element name="context-name" namespace="http://marklogic.com/edi/999">
                <xsl:value-of select="context"/>
              </xsl:element>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:element>
      </xsl:when>
      <xsl:when test="loop-parent/ex:segment-identifier = 'IK3' and segment-node/ex:fields/ex:field/@count > 1">
        <xsl:element name="segment-context" namespace="http://marklogic.com/edi/999">
          <xsl:choose>
            <xsl:when test="context/ex:components/ex:component">
              <xsl:element name="context-name" namespace="http://marklogic.com/edi/999">
                <xsl:value-of select="context/ex:components/ex:component[@index=1]"/> 
              </xsl:element>
              <xsl:element name="context-reference" namespace="http://marklogic.com/edi/999">
                <xsl:value-of select="context/ex:components/ex:component[@index=2]"/>
              </xsl:element>
            </xsl:when>
            <xsl:otherwise>
              <xsl:element name="context-name" namespace="http://marklogic.com/edi/999">
                <xsl:value-of select="context"/>
              </xsl:element>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="IK4">
    <xsl:param name="segment-node"/>
    <xsl:param name="segments"/>
    <xsl:variable name="position-field" select="segment-node/ex:fields/ex:field[@index=1]"/>
    <xsl:element name="data-element" namespace="http://marklogic.com/edi/999">
      <xsl:choose>
        <xsl:when test="position-field/ex:components/ex:component">
          <xsl:element name="element-position" namespace="http://marklogic.com/edi/999">
            <xsl:value-of select="position-field/ex:components/ex:component[./@index=1]"/>
          </xsl:element>
          <xsl:element name="element-component-position" namespace="http://marklogic.com/edi/999">
            <xsl:value-of select="position-field/ex:components/ex:component[./@index=2]"/>
          </xsl:element>
          <xsl:element name="element-repeating-position" namespace="http://marklogic.com/edi/999">
            <xsl:value-of select="position-field/ex:components/ex:component[./@index=3]"/>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="element-position" namespace="http://marklogic.com/edi/999">
            <xsl:value-of select="position-field"/>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>      
      <xsl:element name="element-reference-number" namespace="http://marklogic.com/edi/999">
        <xsl:value-of select="segment/node/ex:fields/ex:field[./@index=2]"/>
      </xsl:element>
      <xsl:element name="error-code" namespace="http://marklogic.com/edi/999">
        <xsl:value-of select="segment/node/ex:fields/ex:field[./@index=3]"/>
      </xsl:element>
      <xsl:element name="bad-element" namespace="http://marklogic.com/edi/999">
        <xsl:value-of select="segment/node/ex:fields/ex:field[./@index=4]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="IK5">
    <xsl:param name="segment-node"/>
    <xsl:param name="segments"/>
    <xsl:element name="transaction-set-response-trailer" namespace="http://marklogic.com/edi/999">
      <xsl:element name="transaction-status" namespace="http://marklogic.com/edi/999">
        <xsl:value-of select="segment-node/ex:fields/ex:field[./@index=1]"/>
      </xsl:element>
      <xsl:for-each select="segment-node/ex:fields/ex:field[./@index > 1]">
        <xsl:element name="error-code" namespace="http://marklogic.com/edi/999">
          <xsl:value-of select="."/>
        </xsl:element>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="AK9">
    <xsl:param name="segment-node"/>
    <xsl:param name="segments"/>
    <xsl:element name="functional-group-response-trailer" namespace="http://marklogic.com/edi/999">
      <xsl:element name="acknowledgment-code" namespace="http://marklogic.com/edi/999">
        <xsl:value-of select="segment-node/ex:fields/ex:field[./@index=1]"/>
      </xsl:element>
      <xsl:element name="included-transaction-sets" namespace="http://marklogic.com/edi/999">
        <xsl:value-of select="segment-node/ex:fields/ex:field[./@index=2]"/>
      </xsl:element>
      <xsl:element name="received-transaction-sets" namespace="http://marklogic.com/edi/999">
        <xsl:value-of select="segment-node/ex:fields/ex:field[./@index=3]"/>
      </xsl:element>
      <xsl:element name="accepted-transaction-sets" namespace="http://marklogic.com/edi/999">
        <xsl:value-of select="segment-node/ex:fields/ex:field[./@index=4]"/>
      </xsl:element>
      <xsl:for-each select="segment-node/ex:fields/ex:field[./@index > 4]">
        <xsl:element name="error-code" namespace="http://marklogic.com/edi/999">
          <xsl:value-of select="."/>
        </xsl:element>
      </xsl:for-each> 
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>



<!-- 
<?xml version="1.0" encoding="UTF-8"?>
<ex:edi-document xmlns:ex="http://marklogic.com/edi/xml">
  <ex:interchanges count="1">
    <ex:interchange start-index="1" end-index="15">
      <ex:original-header>ISA*00* *00* *ZZ*445498161 *ZZ*100000013*110113*0930*^*00501*000000002*0*P*:</ex:original-header>
      <ex:original-footer>IEA*1*000000002</ex:original-footer>
      <ex:control-number>000000002</ex:control-number>
      <ex:control-version>00501</ex:control-version>
      <ex:authorization>
  <ex:qualifier>00</ex:qualifier>
  <ex:information> </ex:information>
      </ex:authorization>
      <ex:security>
  <ex:qualifier>00</ex:qualifier>
  <ex:information> </ex:information>
      </ex:security>
      <ex:sender>
  <ex:qualifier>ZZ</ex:qualifier>
  <ex:identifier>445498161 </ex:identifier>
      </ex:sender>
      <ex:receiver>
  <ex:qualifier>ZZ</ex:qualifier>
  <ex:identifier>100000013</ex:identifier>
      </ex:receiver>
      <ex:interchange-date>110113</ex:interchange-date>
      <ex:interchange-time>0930</ex:interchange-time>
      <ex:standard-identifier>^</ex:standard-identifier>
      <ex:acknowlegement-required>0</ex:acknowlegement-required>
      <ex:usage-indicator>P</ex:usage-indicator>
      <ex:component-separator>:</ex:component-separator>
      <ex:functional-groups count="1">
  <ex:group start-index="2" end-index="14">
    <ex:original-header>GS*FA*445498161*100000013*20110113*09300789*2*X*005010X231</ex:original-header>
    <ex:original-footer>GE*1*2</ex:original-footer>
    <ex:control-number>2</ex:control-number>
    <ex:functional-code>FA</ex:functional-code>
    <ex:application-sender>445498161</ex:application-sender>
    <ex:application-receiver>100000013</ex:application-receiver>
    <ex:date-format>20110113</ex:date-format>
    <ex:time-format>09300789</ex:time-format>
    <ex:responsible-agency-code>X</ex:responsible-agency-code>
    <ex:document-identifier>005010X231</ex:document-identifier>
    <ex:transaction-sets count="1">
      <ex:transaction-set start-index="3">
        <ex:original-header>ST*999*2001*005010X231</ex:original-header>
        <ex:original-footer>SE*11*2001</ex:original-footer>
        <ex:id>999</ex:id>
        <ex:control-number>2001</ex:control-number>
        <ex:segments count="9">
    <ex:segment index="4" set-position="1">
      <ex:segment-text>AK1*HS*108*005010X279A1</ex:segment-text>
      <ex:segment-identifier>AK1</ex:segment-identifier>
      <ex:fields count="3">
        <ex:field index="1">HS</ex:field>
        <ex:field index="2">108</ex:field>
        <ex:field index="3">005010X279A1</ex:field>
      </ex:fields>
    </ex:segment>
    <ex:segment index="5" set-position="2">
      <ex:segment-text>AK2*270*000000001*005010X279A1</ex:segment-text>
      <ex:segment-identifier>AK2</ex:segment-identifier>
      <ex:fields count="3">
        <ex:field index="1">270</ex:field>
        <ex:field index="2">000000001</ex:field>
        <ex:field index="3">005010X279A1</ex:field>
      </ex:fields>
    </ex:segment>
    <ex:segment index="6" set-position="3">
      <ex:segment-text>IK3*TRN*10*2000*8</ex:segment-text>
      <ex:segment-identifier>IK3</ex:segment-identifier>
      <ex:fields count="4">
        <ex:field index="1">TRN</ex:field>
        <ex:field index="2">10</ex:field>
        <ex:field index="3">2000</ex:field>
        <ex:field index="4">8</ex:field>
      </ex:fields>
    </ex:segment>
    <ex:segment index="7" set-position="4">
      <ex:segment-text>CTX*SITUATIONAL TRIGGER*TRN*10*2000*3</ex:segment-text>
      <ex:segment-identifier>CTX</ex:segment-identifier>
      <ex:fields count="5">
        <ex:field index="1">SITUATIONAL TRIGGER</ex:field>
        <ex:field index="2">TRN</ex:field>
        <ex:field index="3">10</ex:field>
        <ex:field index="4">2000</ex:field>
        <ex:field index="5">3</ex:field>
      </ex:fields>
    </ex:segment>
    <ex:segment index="8" set-position="5">
      <ex:segment-text>CTX*TRN02</ex:segment-text>
      <ex:segment-identifier>CTX</ex:segment-identifier>
      <ex:fields count="1">
        <ex:field index="1">TRN02</ex:field>
      </ex:fields>
    </ex:segment>
    <ex:segment index="9" set-position="6">
      <ex:segment-text>IK4*3**4*9HPPES000</ex:segment-text>
      <ex:segment-identifier>IK4</ex:segment-identifier>
      <ex:fields count="4">
        <ex:field index="1">3</ex:field>
        <ex:field index="2"/>
        <ex:field index="3">4</ex:field>
        <ex:field index="4">9HPPES000</ex:field>
      </ex:fields>
    </ex:segment>
    <ex:segment index="10" set-position="7">
      <ex:segment-text>CTX*SITUATIONAL TRIGGER*TRN*10*2000*3</ex:segment-text>
      <ex:segment-identifier>CTX</ex:segment-identifier>
      <ex:fields count="5">
        <ex:field index="1">SITUATIONAL TRIGGER</ex:field>
        <ex:field index="2">TRN</ex:field>
        <ex:field index="3">10</ex:field>
        <ex:field index="4">2000</ex:field>
        <ex:field index="5">3</ex:field>
      </ex:fields>
    </ex:segment>
    <ex:segment index="11" set-position="8">
      <ex:segment-text>IK5*R*5</ex:segment-text>
      <ex:segment-identifier>IK5</ex:segment-identifier>
      <ex:fields count="2">
        <ex:field index="1">R</ex:field>
        <ex:field index="2">5</ex:field>
      </ex:fields>
    </ex:segment>
    <ex:segment index="12" set-position="9">
      <ex:segment-text>AK9*R*1*1*0</ex:segment-text>
      <ex:segment-identifier>AK9</ex:segment-identifier>
      <ex:fields count="4">
        <ex:field index="1">R</ex:field>
        <ex:field index="2">1</ex:field>
        <ex:field index="3">1</ex:field>
        <ex:field index="4">0</ex:field>
      </ex:fields>
    </ex:segment>
        </ex:segments>
      </ex:transaction-set>
    </ex:transaction-sets>
  </ex:group>
      </ex:functional-groups>
    </ex:interchange>
  </ex:interchanges>
</ex:edi-document>
-->
 