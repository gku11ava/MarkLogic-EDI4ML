  <!-- Example transform to convert an EDI999 type message from the generic 
	edi-document into a context-specific XML document. EDI 999 Implementation 
	Acknowledgements are sent out by the receiving system to acknowledge receipt 
	of a message. This document makes use of 3 different namespaces: http://edi4ml/edi/common# 
	are for shared XML elements that can be reused between different EDI types. 
	These are the common Interchange, Functional Groups and Transaction Set elements. 
	http://edi4ml/edi/metadata# are for positional/count information that identifies 
	where a particular piece of information is located. Positional information 
	is useful, but not necessary while count information particularly the count 
	of segments in a transaction set, is required. http://edi4ml/edi/999# are 
	for XML elements specific to the 999 message type -->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ex="http://edi4ml/edi/xml#">

	<xsl:variable name="segments" select="/ex:edi-document/ex:segments" />
	<xsl:key name="segment-identifier" match="ex:segment"
		use="ex:segment-identifier" />

	<xsl:template match="/">
		<xsl:element name="implementation-acknowledgement"
			namespace="http://edi4ml/edi/999#">
			<xsl:attribute name="segment-count" namespace="http://edi4ml/edi/metadata#"><xsl:value-of
				select="$segments/@ex:count" /></xsl:attribute>
			<xsl:for-each select="key('segment-identifier', 'ISA')">
				<xsl:variable name="control-number" select="./ex:fields/ex:field[@ex:index=13]" />
				<!-- Find the matching IEA segment for the current interchange -->
				<xsl:variable name="end-segment"
					select="key('segment-identifier', 'IEA')[./ex:fields/ex:field[./@ex:index=2] = $control-number]" />
				<xsl:call-template name="parse-interchange">
					<xsl:with-param name="header" select="." />
					<xsl:with-param name="footer" select="$end-segment" />
				</xsl:call-template>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>

	<!-- Convert ISA and corresponding IEA segments into an interchange and 
		process any segments between these two segments as functional groups and 
		transaction sets -->
	<xsl:template name="parse-interchange">
		<xsl:param name="header" />
		<xsl:param name="footer" />
		<xsl:element name="interchange" namespace="http://edi4ml/edi/common#">
			<!-- This tracks the segment indexes of the ISA and IEA segments so we 
				can easily convert back to the generic edi-document XML -->
			<xsl:attribute name="start-index" namespace="http://edi4ml/edi/metadata#"><xsl:value-of
				select="$header/@ex:index" /></xsl:attribute>
			<xsl:attribute name="stop-index" namespace="http://edi4ml/edi/metadata#"><xsl:value-of
				select="$footer/@ex:index" /></xsl:attribute>
			<xsl:element name="authorization" namespace="http://edi4ml/edi/common#">
				<xsl:element name="qualifier" namespace="http://edi4ml/edi/common#">
					<xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=1]" />
				</xsl:element>
				<xsl:element name="information" namespace="http://edi4ml/edi/common#">
					<xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=2]" />
				</xsl:element>
			</xsl:element>
			<xsl:element name="security" namespace="http://edi4ml/edi/common#">
				<xsl:element name="qualifier" namespace="http://edi4ml/edi/common#">
					<xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=3]" />
				</xsl:element>
				<xsl:element name="information" namespace="http://edi4ml/edi/common#">
					<xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=4]" />
				</xsl:element>
			</xsl:element>
			<xsl:element name="sender" namespace="http://edi4ml/edi/common#">
				<xsl:element name="qualifier" namespace="http://edi4ml/edi/common#">
					<xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=5]" />
				</xsl:element>
				<xsl:element name="identifier" namespace="http://edi4ml/edi/common#">
					<xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=6]" />
				</xsl:element>
			</xsl:element>
			<xsl:element name="receiver" namespace="http://edi4ml/edi/common#">
				<xsl:element name="qualifier" namespace="http://edi4ml/edi/common#">
					<xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=7]" />
				</xsl:element>
				<xsl:element name="identifier" namespace="http://edi4ml/edi/common#">
					<xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=8]" />
				</xsl:element>
			</xsl:element>
			<xsl:element name="format" namespace="http://edi4ml/edi/common#">
				<xsl:element name="interchange-date" namespace="http://edi4ml/edi/common#">
					<xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=9]" />
				</xsl:element>
				<xsl:element name="interchange-time" namespace="http://edi4ml/edi/common#">
					<xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=10]" />
				</xsl:element>
				<xsl:element name="component-separator" namespace="http://edi4ml/edi/common#">
					<xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=16]" />
				</xsl:element>
			</xsl:element>
			<xsl:element name="interchange-standard" namespace="http://edi4ml/edi/common#">
				<xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=11]" />
			</xsl:element>
			<xsl:element name="control-version" namespace="http://edi4ml/edi/common#">
				<xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=12]" />
			</xsl:element>
			<xsl:element name="control-number" namespace="http://edi4ml/edi/common#">
				<xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=13]" />
			</xsl:element>
			<xsl:element name="acknowledgement-required" namespace="http://edi4ml/edi/common#">
				<xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=14]" />
			</xsl:element>
			<xsl:element name="usage" namespace="http://edi4ml/edi/common#">
				<xsl:value-of select="$header/ex:fields/ex:field[./@ex:index=15]" />
			</xsl:element>
			<xsl:element name="functional-groups" namespace="http://edi4ml/edi/common#">
				<xsl:attribute name="count" namespace="http://edi4ml/edi/common#">
          <xsl:value-of select="$footer/ex:fields/ex:field[./@ex:index=1]" />
        </xsl:attribute>
				<xsl:for-each
					select="key('segment-identifier', 'GS')[./@ex:index/number(.) lt number($footer/@ex:index) and 
            ./@ex:index/number(.) gt number($header/@ex:index)]">
					<xsl:variable name="control-number"
						select="./ex:fields/ex:field[./@ex:index=6]" />
					<!-- Find the matching GE segment for the current functional group -->
					<xsl:variable name="end-segment"
						select="key('segment-identifier', 'GE')[./ex:fields/ex:field[./@ex:index=2] = $control-number]" />
					<xsl:call-template name="parse-group">
						<xsl:with-param name="group-header" select="." />
						<xsl:with-param name="group-trailer" select="$end-segment" />
					</xsl:call-template>
				</xsl:for-each>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<!-- Build a functional group from the provided GS and GE segments. Any 
		segments within are parsed into transaction sets -->
	<xsl:template name="parse-group">
		<xsl:param name="group-header" />
		<xsl:param name="group-trailer" />
		<xsl:element name="functional-group" namespace="http://edi4ml/edi/common#">
			<!-- This tracks the segment indexes of the ISA and IEA segments so we 
				can easily convert back to the generic edi-document XML -->
			<xsl:attribute name="start-index" namespace="http://edi4ml/edi/metadata#"><xsl:value-of
				select="$group-header/@ex:index" /></xsl:attribute>
			<xsl:attribute name="stop-index" namespace="http://edi4ml/edi/metadata#"><xsl:value-of
				select="$group-trailer/@ex:index" /></xsl:attribute>
			<xsl:element name="functional-code" namespace="http://edi4ml/edi/common#">
				<xsl:value-of select="$group-header/ex:fields/ex:field[./@ex:index=1]" />
			</xsl:element>
			<xsl:element name="sender" namespace="http://edi4ml/edi/common#">
				<xsl:value-of select="$group-header/ex:fields/ex:field[./@ex:index=2]" />
			</xsl:element>
			<xsl:element name="receiver" namespace="http://edi4ml/edi/common#">
				<xsl:value-of select="$group-header/ex:fields/ex:field[./@ex:index=3]" />
			</xsl:element>
			<xsl:element name="date-format" namespace="http://edi4ml/edi/common#">
				<xsl:value-of select="$group-header/ex:fields/ex:field[./@ex:index=4]" />
			</xsl:element>
			<xsl:element name="time-format" namespace="http://edi4ml/edi/common#">
				<xsl:value-of select="$group-header/ex:fields/ex:field[./@ex:index=5]" />
			</xsl:element>
			<xsl:element name="control-number" namespace="http://edi4ml/edi/common#">
				<xsl:value-of select="$group-header/ex:fields/ex:field[./@ex:index=6]" />
			</xsl:element>
			<xsl:element name="responsible-agency" namespace="http://edi4ml/edi/common#">
				<xsl:value-of select="$group-header/ex:fields/ex:field[./@ex:index=7]" />
			</xsl:element>
			<xsl:element name="document-identifier" namespace="http://edi4ml/edi/common#">
				<xsl:value-of select="$group-header/ex:fields/ex:field[./@ex:index=8]" />
			</xsl:element>
			<xsl:element name="transaction-sets" namespace="http://edi4ml/edi/common#">
				<xsl:attribute name="count" namespace="http://edi4ml/edi/common#">
          <xsl:value-of
					select="$group-trailer/ex:fields/ex:field[./@ex:index=1]" />
        </xsl:attribute>
				<xsl:for-each
					select="key('segment-identifier', 'ST')[./@ex:index/number(.) lt $group-trailer/@ex:index/number(.) 
            and ./@ex:index/number(.) gt number($group-header/@ex:index)]">
					<xsl:variable name="control-number"
						select="./ex:fields/ex:field[./@ex:index=2]" />
					<!-- Get the SE segment that corresponds to the current transaction 
						set -->
					<xsl:variable name="end-segment"
						select="key('segment-identifier', 'SE')[./ex:fields/ex:field[./@ex:index=2] = $control-number]" />
					<xsl:call-template name="parse-set">
						<xsl:with-param name="set-header" select="." />
						<xsl:with-param name="set-trailer" select="$end-segment" />
					</xsl:call-template>
				</xsl:for-each>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<!-- Parse the ST and SE segments into a transaction set. EDI Transaction 
		type specific handling is used to parse the segments contained within the 
		ST and SE segments -->
	<xsl:template name="parse-set">
		<xsl:param name="set-header" />
		<xsl:param name="set-trailer" />
		<xsl:element name="transaction-set" namespace="http://edi4ml/edi/common#">
			<!-- This tracks the segment indexes of the ISA and IEA segments so we 
				can easily convert back to the generic edi-document XML -->
			<xsl:attribute name="start-index" namespace="http://edi4ml/edi/metadata#"><xsl:value-of
				select="$set-header/@ex:index" /></xsl:attribute>
			<xsl:attribute name="stop-index" namespace="http://edi4ml/edi/metadata#"><xsl:value-of
				select="$set-trailer/@ex:index" /></xsl:attribute>
			<xsl:attribute name="segment-count" namespace="http://edi4ml/edi/metadata#">
        <xsl:number
				value="number($set-trailer/@ex:index) - number($set-header/@ex:index) + 1" />
      </xsl:attribute>
			<xsl:element name="transaction-id" namespace="http://edi4ml/edi/common#">
				<xsl:value-of select="$set-header/ex:fields/ex:field[./@ex:index=1]" />
			</xsl:element>
			<xsl:element name="control-number" namespace="http://edi4ml/edi/common#">
				<xsl:value-of select="$set-header/ex:fields/ex:field[./@ex:index=2]" />
			</xsl:element>
			<xsl:element name="document-identifier" namespace="http://edi4ml/edi/common#">
				<xsl:value-of select="$set-header/ex:fields/ex:field[./@ex:index=3]" />
			</xsl:element>
			<!-- Begin Format Specific Handling Here -->
			<xsl:for-each
				select="$segments/ex:segment[./@ex:index/number(.) lt $set-trailer/@ex:index/number(.) and
          (./ex:segment-identifier='AK1' or ./ex:segment-identifier='AK2' or ./ex:segment-identifier='AK9')]">
				<xsl:choose>
					<xsl:when test="./ex:segment-identifier='AK1'">
						<xsl:call-template name="AK1">
							<xsl:with-param name="segment" select="." />
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="./ex:segment-identifier='AK2'">
						<xsl:call-template name="AK2">
							<xsl:with-param name="segment" select="." />
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="./ex:segment-identifier='AK9'">
						<xsl:call-template name="AK9">
							<xsl:with-param name="segment" select="." />
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise />
				</xsl:choose>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>

	<!-- In EDI 999, the AK1 segment is the functional-group response section 
		for a transaction -->
	<xsl:template name="AK1">
		<xsl:param name="segment" />
		<xsl:element name="functional-group-response" namespace="http://edi4ml/edi/999#">
			<xsl:attribute name="segment-index" namespace="http://edi4ml/edi/metadata#"><xsl:value-of
				select="$segment/@ex:index" /></xsl:attribute>
			<xsl:element name="functional-identifier" namespace="http://edi4ml/edi/999#">
				<xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]" />
			</xsl:element>
			<xsl:element name="control-number" namespace="http://edi4ml/edi/999#">
				<xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]" />
			</xsl:element>
			<xsl:element name="identifier-code" namespace="http://edi4ml/edi/999#">
				<xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]" />
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<!-- The AK2 segment is the transaction set response header for a transaction 
		set. It must contain an IK5 or transaction set response trailer and may contain 
		one or more IK3 segments to indicate any errors -->
	<xsl:template name="AK2">
		<xsl:param name="segment" />
		<xsl:variable name="segment-index" select="./@ex:index" />
		<xsl:variable name="next-index"
			select="min($segments/ex:segment[(./ex:segment-identifier='AK2' or ./ex:segment-identifier='AK9') and
        ./@ex:index/number(.) gt number($segment/@ex:index)]/@ex:index)" />
		<xsl:element name="transaction-set-response-header"
			namespace="http://edi4ml/edi/999#">
			<xsl:attribute name="segment-index" namespace="http://edi4ml/edi/metadata#"><xsl:value-of
				select="$segment/@ex:index" /></xsl:attribute>
			<xsl:element name="transaction-set-identifier" namespace="http://edi4ml/edi/999#">
				<xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]" />
			</xsl:element>
			<xsl:element name="control-number" namespace="http://edi4ml/edi/999#">
				<xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]" />
			</xsl:element>
			<xsl:element name="convention-reference" namespace="http://edi4ml/edi/999#">
				<xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]" />
			</xsl:element>
			<!-- Errors are reported under IK3 segments -->
			<xsl:for-each
				select="key('segment-identifier', 'IK3')[./@ex:index/number(.) lt number($next-index) and 
          ./@ex:index/number(.) gt number($segment/@ex:index)]">
				<xsl:call-template name="IK3">
					<xsl:with-param name="segment" select="." />
				</xsl:call-template>
			</xsl:for-each>
			<!-- Transaction set response trailer -->
			<xsl:for-each
				select="key('segment-identifier', 'IK5')[./@ex:index/number(.) lt number($next-index) and
          ./@ex:index/number(.) gt number($segment/@ex:index)]">
				<xsl:call-template name="IK5">
					<xsl:with-param name="segment" select="." />
				</xsl:call-template>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>

	<!-- Errors at the segment level are reported in IK3 segments. These include 
		some CTX context segments identifying the error and where it occurs. IK4 
		segments may be included to identify specific elements/fields where the error 
		occurs. -->
	<xsl:template name="IK3">
		<xsl:param name="segment" />
		<xsl:variable name="context-stop-index"
			select="min($segments/ex:segment[(./ex:segment-identifier='IK3' or ./ex:segment-identifier='IK4'
        or ./ex:segment-identifier='IK5') and ./@ex:index/number(.) gt number($segment/@ex:index)]/@ex:index)" />
		<xsl:variable name="loop-stop-index"
			select="min(key('segment-identifier', 'IK5')[./@ex:index/number(.) gt number($segment/@ex:index)]/@ex:index)" />
		<xsl:element name="error-identification" namespace="http://edi4ml/edi/999#">
			<xsl:attribute name="segment-index" namespace="http://edi4ml/edi/metadata#"><xsl:value-of
				select="$segment/@ex:index" /></xsl:attribute>
			<xsl:element name="segment-identifier" namespace="http://edi4ml/edi/999#">
				<xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]" />
			</xsl:element>
			<xsl:element name="segment-position" namespace="http://edi4ml/edi/999#">
				<xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]" />
			</xsl:element>
			<xsl:element name="loop-identifier" namespace="http://edi4ml/edi/999#">
				<xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]" />
			</xsl:element>
			<xsl:element name="error-code" namespace="http://edi4ml/edi/999#">
				<xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]" />
			</xsl:element>
			<!-- Get the Segment and Business Contexts -->
			<xsl:for-each
				select="key('segment-identifier', 'CTX')[./@ex:index/number(.) lt number($context-stop-index) and 
          ./@ex:index/number(.) gt number($segment/@ex:index)]">
				<xsl:call-template name="CTX">
					<xsl:with-param name="context" select="." />
					<xsl:with-param name="loop-identifier"
						select="$segment/ex:segment-identifier" />
				</xsl:call-template>
			</xsl:for-each>
			<!-- Get element/field level details -->
			<xsl:for-each
				select="key('segment-identifier', 'IK4')[./@ex:index/number(.) lt number($loop-stop-index) and
          ./@ex:index/number(.) gt number($segment/@ex:index)]">
				<xsl:call-template name="IK4">
					<xsl:with-param name="segment" select="." />
				</xsl:call-template>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>

	<xsl:template name="CTX">
		<xsl:param name="context" />
		<xsl:param name="loop-identifier" />
		<xsl:choose>
			<xsl:when test="$context/ex:fields/@ex:count=1">
				<xsl:element name="business-unit-identifier" namespace="http://edi4ml/edi/999#">
					<xsl:attribute name="segment-index" namespace="http://edi4ml/edi/metadata#"><xsl:value-of
						select="$context/@ex:index" /></xsl:attribute>
					<xsl:call-template name="context-identification">
		              <xsl:with-param name="field" select="$context/ex:fields/ex:field[./@ex:index=1]"/>
		            </xsl:call-template>
				</xsl:element>
			</xsl:when>
			<!-- IK3 Context with multiple fields is a segment context -->
			<xsl:when test="$loop-identifier='IK3'">
				<xsl:element name="segment-context" namespace="http://edi4ml/edi/999#">
					<xsl:attribute name="segment-index" namespace="http://edi4ml/edi/metadata#"><xsl:value-of
						select="$context/@ex:index" /></xsl:attribute>
					<xsl:call-template name="build-context">
						<xsl:with-param name="segment" select="$context" />
					</xsl:call-template>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise> <!-- Loop Identifier is IK4. This is an element context -->
				<xsl:element name="element-context" namespace="http://edi4ml/edi/999#">
					<xsl:attribute name="segment-index" namespace="http://edi4ml/edi/metadata#"><xsl:value-of
						select="$context/@ex:index" /></xsl:attribute>
					<xsl:call-template name="build-context">
						<xsl:with-param name="segment" select="$context" />
					</xsl:call-template>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="build-context">
		<xsl:param name="segment" />
		<xsl:call-template name="context-identification">
		  <xsl:with-param name="field" select="$segment/ex:fields/ex:field[./@ex:index=1]"/>
		</xsl:call-template>
		<xsl:element name="segment-identification" namespace="http://edi4ml/edi/999#">
			<xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]" />
		</xsl:element>
		<xsl:element name="segment-position" namespace="http://edi4ml/edi/999#">
			<xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]" />
		</xsl:element>
		<xsl:element name="loop-identifier" namespace="http://edi4ml/edi/999#">
			<xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]" />
		</xsl:element>
		<xsl:if test="$segment/ex:fields/ex:field[./@ex:index=5]">
			<xsl:element name="position-in-segment" namespace="http://edi4ml/edi/999#">
				<xsl:choose>
					<xsl:when
						test="$segment/ex:fields/ex:field[./@ex:index=5]/ex:components/ex:component">
						<xsl:element name="element-position" namespace="http://edi4ml/edi/999#">
							<xsl:value-of
								select="$segment/ex:fields/ex:field[./@ex:index=5]/ex:components/ex:component[./@ex:index=1]" />
						</xsl:element>
						<xsl:element name="component-position" namespace="http://edi4ml/edi/999#">
							<xsl:value-of
								select="$segment/ex:fields/ex:field[./@ex:index=5]/ex:components/ex:component[./@ex:index=2]" />
						</xsl:element>
						<xsl:element name="repeating-position" namespace="http://edi4ml/edi/999#">
							<xsl:value-of
								select="$segment/ex:fields/ex:field[./@ex:index=5]/ex:components/ex:component[./@ex:index=3]" />
						</xsl:element>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=5]" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:if test="$segment/ex:fields/ex:field[./@ex:index=6]">
				<xsl:element name="reference" namespace="http://edi4ml/edi/999#">
					<xsl:element name="reference-number" namespace="http://edi4ml/edi/999#">
						<xsl:value-of
							select="$segment/ex:fields/ex:field[./@ex:index=6]/ex:components/ex:component[./@ex:index=1]" />
					</xsl:element>
					<xsl:element name="reference-number" namespace="http://edi4ml/edi/999#">
						<xsl:value-of
							select="$segment/ex:fields/ex:field[./@ex:index=6]/ex:components/ex:component[./@ex:index=2]" />
					</xsl:element>
				</xsl:element>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template name="context-identification">
	  <xsl:param name="field"/>
	  <xsl:choose>
	    <xsl:when test="$field/ex:components/ex:component">
		  <xsl:element name="context-name" namespace="http://edi4ml/edi/999#">
		    <xsl:value-of select="$field/ex:components/ex:component[@ex:index=1]" />
	      </xsl:element>
		  <xsl:element name="context-reference" namespace="http://edi4ml/edi/999#">
		    <xsl:value-of select="$field/ex:components/ex:component[@ex:index=2]" />
		  </xsl:element>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:element name="context-name" namespace="http://edi4ml/edi/999#">
			<xsl:value-of select="$field" />
		  </xsl:element>
		</xsl:otherwise>
	  </xsl:choose>
	</xsl:template>
	
	<xsl:template name="IK4">
		<xsl:param name="segment" />
		<xsl:variable name="loop-stop-index"
			select="min($segments/ex:segment[(./ex:segment-identifier='IK4' or ./ex:segment-identifier='IK3' 
        or ./ex:segment-identifier='IK5') and ./@ex:index/number(.) gt $segment/@ex:index/number(.) ]/@ex:index)" />
		<xsl:variable name="position-field"
			select="$segment/ex:fields/ex:field[@ex:index=1]" />
		<xsl:element name="data-element" namespace="http://edi4ml/edi/999#">
			<xsl:attribute name="segment-index" namespace="http://edi4ml/edi/metadata#"><xsl:value-of
				select="$segment/@ex:index" /></xsl:attribute>
			<xsl:choose>
				<xsl:when test="$position-field/ex:components/ex:component">
					<xsl:element name="element-position" namespace="http://edi4ml/edi/999#">
						<xsl:value-of
							select="$position-field/ex:components/ex:component[./@ex:index=1]" />
					</xsl:element>
					<xsl:element name="element-component-position"
						namespace="http://edi4ml/edi/999#">
						<xsl:value-of
							select="$position-field/ex:components/ex:component[./@ex:index=2]" />
					</xsl:element>
					<xsl:element name="element-repeating-position"
						namespace="http://edi4ml/edi/999#">
						<xsl:value-of
							select="$position-field/ex:components/ex:component[./@ex:index=3]" />
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:element name="element-position" namespace="http://edi4ml/edi/999#">
						<xsl:value-of select="$position-field" />
					</xsl:element>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:element name="element-reference-number" namespace="http://edi4ml/edi/999#">
				<xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]" />
			</xsl:element>
			<xsl:element name="error-code" namespace="http://edi4ml/edi/999#">
				<xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]" />
			</xsl:element>
			<xsl:element name="bad-element" namespace="http://edi4ml/edi/999#">
				<xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]" />
			</xsl:element>
			<xsl:for-each
				select="key('segment-identifier', 'CTX')[./@ex:index/number(.) lt number($loop-stop-index) and
          ./@ex:index/number(.) gt number($segment/@ex:index)]">
				<xsl:call-template name="CTX">
					<xsl:with-param name="context" select="." />
					<xsl:with-param name="loop-identifier"
						select="$segment/ex:segment-identifier" />
				</xsl:call-template>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>

	<xsl:template name="IK5">
		<xsl:param name="segment" />
		<xsl:element name="transaction-set-response-trailer"
			namespace="http://edi4ml/edi/999#">
			<xsl:attribute name="segment-index" namespace="http://edi4ml/edi/metadata#"><xsl:value-of
				select="$segment/@ex:index" /></xsl:attribute>
			<xsl:element name="transaction-status" namespace="http://edi4ml/edi/999#">
				<xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]" />
			</xsl:element>
			<xsl:for-each select="$segment/ex:fields/ex:field[./@ex:index > 1]">
				<xsl:element name="error-code" namespace="http://edi4ml/edi/999#">
					<xsl:value-of select="." />
				</xsl:element>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>

	<xsl:template name="AK9">
		<xsl:param name="segment" />
		<xsl:element name="functional-group-response-trailer"
			namespace="http://edi4ml/edi/999#">
			<xsl:attribute name="segment-index" namespace="http://edi4ml/edi/metadata#"><xsl:value-of
				select="$segment/@ex:index" /></xsl:attribute>
			<xsl:element name="acknowledgment-code" namespace="http://edi4ml/edi/999#">
				<xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=1]" />
			</xsl:element>
			<xsl:element name="included-transaction-sets" namespace="http://edi4ml/edi/999#">
				<xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=2]" />
			</xsl:element>
			<xsl:element name="received-transaction-sets" namespace="http://edi4ml/edi/999#">
				<xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=3]" />
			</xsl:element>
			<xsl:element name="accepted-transaction-sets" namespace="http://edi4ml/edi/999#">
				<xsl:value-of select="$segment/ex:fields/ex:field[./@ex:index=4]" />
			</xsl:element>
			<xsl:for-each select="$segment/ex:fields/ex:field[./@ex:index > 4]">
				<xsl:element name="error-code" namespace="http://edi4ml/edi/999#">
					<xsl:value-of select="." />
				</xsl:element>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>

