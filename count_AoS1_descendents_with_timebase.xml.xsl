<?xml version="1.0" encoding="ISO-8859-1" standalone="yes"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./$GET[stylesheet]" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>
<!-- This stylesheet counts, from the derived dd_data_dictionary.xml file, for each top level static AoS (type 1), the number of dynamic nodes carrying a time base below it (i.e. outside of AoS type 3, which count only as one dynamic node because it's represented as a single MDS+ node (one time base).-->
<!-- This is used to generate the MDS+ model file with an optimal size, pre-setting all needed dynamic signals -->
<!-- The result is stored in an XML file, indicating for each top level static AoS the number of required dynamic descendents for the MDS+ model file -->
<!-- A completely generic algorithm couldn't be found, but the present one covers all cases encountered in the DD so far, and will the AoS with an error if an unexpected is encountered -->
<!-- The cases treated so far are : static AoS with 0 to 4 (non-nested) static AoS descendents and any number of dynamic AoS descendents. A static AoS descendent having no dynamic signal in it counts for 0 and doesn't break the algorithm -->
<xsl:stylesheet xmlns:yaslt="http://www.mod-xslt2.com/ns/2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" extension-element-prefixes="yaslt" xmlns:fn="http://www.w3.org/2005/02/xpath-functions" xmlns:local="http://www.example.com/functions/local" exclude-result-prefixes="local xs">
	<xsl:output method="xml" encoding="UTF-8"/>
	<!-- Function for multiplying the number of descendents with timebasepath attribute by the occurrence of the child AoS -->
	<xsl:function name="local:count-nodes" as="xs:anyAtomicType">
		<xsl:param name="nodes" as="node()*"/>
		<xsl:value-of select="$nodes[1]/@maxoccur*count($nodes[1]//field[@timebasepath])" />
	</xsl:function>
	<xsl:function name="local:count-nodes-2-non-nested" as="xs:anyAtomicType">
		<xsl:param name="nodes" as="node()*"/>
		<xsl:value-of select="$nodes[1]/@maxoccur*count($nodes[1]//field[@timebasepath]) + $nodes[2]/@maxoccur*count($nodes[2]//field[@timebasepath])" />
	</xsl:function>
	<xsl:function name="local:count-nodes-3-non-nested" as="xs:anyAtomicType">
		<xsl:param name="nodes" as="node()*"/>
		<xsl:value-of select="$nodes[1]/@maxoccur*count($nodes[1]//field[@timebasepath]) + $nodes[2]/@maxoccur*count($nodes[2]//field[@timebasepath]) + $nodes[3]/@maxoccur*count($nodes[3]//field[@timebasepath])" />
	</xsl:function>
	<xsl:function name="local:count-nodes-4-non-nested" as="xs:anyAtomicType">
		<xsl:param name="nodes" as="node()*"/>
		<xsl:choose>
		<xsl:when test="$nodes[3]//field[@maxoccur and not(@maxoccur='unbounded')]"> <!-- Case of node[4] being nested being node[3] -->
		      <xsl:value-of select="$nodes[1]/@maxoccur*count($nodes[1]//field[@timebasepath]) + $nodes[2]/@maxoccur*count($nodes[2]//field[@timebasepath]) + $nodes[3]/@maxoccur*count($nodes[3]//field[@timebasepath]) +  $nodes[3]/@maxoccur * $nodes[4]/@maxoccur*count($nodes[4]//field[@timebasepath])" />
		</xsl:when>
        <xsl:otherwise>    <!-- Case of 4 non-nested AoS nodes -->
		    <xsl:value-of select="$nodes[1]/@maxoccur*count($nodes[1]//field[@timebasepath]) + $nodes[2]/@maxoccur*count($nodes[2]//field[@timebasepath]) + $nodes[3]/@maxoccur*count($nodes[3]//field[@timebasepath]) + $nodes[4]/@maxoccur*count($nodes[4]//field[@timebasepath])" />
        </xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	<xsl:template match="/*">
		<IDSs>
			<xsl:for-each select="IDS">
				<xsl:element name="IDS">
					<xsl:attribute name="name" select="@name"/>
					<xsl:apply-templates select=".//field[@data_type='struct_array' and not(@maxoccur='unbounded')]"/>
				</xsl:element>
			</xsl:for-each>
		</IDSs>
	</xsl:template>
	<xsl:template name="count_dynamic_signals" match="field">
		<xsl:if test="not(ancestor::*[@data_type='struct_array'])">
			<!-- Do something only if this is the top level of AoS (not other AoS ancestor), since this is the only one corresponding to an explicit node in the MDS model tree, otherwise skip the whole template -->
			<xsl:element name="{@name}">
				<xsl:choose>
					<!--<xsl:when test=".//field[@maxoccur and not(contains(@maxoccur,'unbounded'))]">-->
					<xsl:when test="not(.//field[@maxoccur and .//field[@timebasepath]])">
						<!-- When there is no static AoS descendent with dynamic signals below this node : just count 1) all fields having a timebasepath attribute 2) all AoS type 3 (unbounded) but avoiding couting nested AoS type 2 since they don't introduce an additional timebase -->
						<xsl:attribute name="max_dynamic_nodes" select="(count(.//field[@timebasepath]) + count(.//field[@maxoccur='unbounded' and not(ancestor::*[@maxoccur='unbounded'])])) * @maxoccur"/>
						<!-- Count all fields having a timebasepath argument + the AoS3 which are dynamic as well -->
					</xsl:when>
					<xsl:when test="count(.//field[@maxoccur and .//field[@timebasepath]])=1"> <!-- When there is a single static AoS descendent -->
						<!-- The first term with the check of no nested struct_array ancestors avoid counting twice the children of further static AoS descendents ... which are also counted (correctly) in the local:count-nodes function ... -->
						<xsl:attribute name="max_dynamic_nodes" select="(count(.//field[@timebasepath] and not(ancestor::*[@data_type='struct_array' and ancestor::*[@data_type='struct_array']])) + count(.//field[@maxoccur='unbounded' and not(ancestor::*[@maxoccur='unbounded'])]) + local:count-nodes(.//field[@maxoccur and .//field[@timebasepath]]) ) * @maxoccur"/>
					</xsl:when>
					<xsl:when test="count(.//field[@maxoccur and .//field[@timebasepath]])=2"> <!-- When there are two non-nested static AoS descendents -->
						<!-- The first term with the check of no nested struct_array ancestors avoid counting twice the children of further static AoS descendents ... which are also counted (correctly) in the local:count-nodes function ... -->
						<xsl:attribute name="max_dynamic_nodes" select="(count(.//field[@timebasepath] and not(ancestor::*[@data_type='struct_array' and ancestor::*[@data_type='struct_array']])) + count(.//field[@maxoccur='unbounded' and not(ancestor::*[@maxoccur='unbounded'])]) + local:count-nodes-2-non-nested(.//field[@maxoccur and .//field[@timebasepath]]) ) * @maxoccur"/>
					</xsl:when>
					<xsl:when test="count(.//field[@maxoccur and .//field[@timebasepath]])=3"> <!-- When there are three non-nested static AoS descendents -->
						<!-- The first term with the check of no nested struct_array ancestors avoid counting twice the children of further static AoS descendents ... which are also counted (correctly) in the local:count-nodes function ... -->
						<xsl:attribute name="max_dynamic_nodes" select="(count(.//field[@timebasepath] and not(ancestor::*[@data_type='struct_array' and ancestor::*[@data_type='struct_array']])) + count(.//field[@maxoccur='unbounded' and not(ancestor::*[@maxoccur='unbounded'])]) + local:count-nodes-3-non-nested(.//field[@maxoccur and .//field[@timebasepath]]) ) * @maxoccur"/>
					</xsl:when>
					<xsl:when test="count(.//field[@maxoccur and .//field[@timebasepath]])=4"> <!-- When there are 4 non-nested static AoS descendents -->
						<!-- The first term with the check of no nested struct_array ancestors avoid counting twice the children of further static AoS descendents ... which are also counted (correctly) in the local:count-nodes function ... -->
						<xsl:attribute name="max_dynamic_nodes" select="(count(.//field[@timebasepath and not(ancestor::*[@data_type='struct_array' and ancestor::*[@data_type='struct_array']])]) + count(.//field[@maxoccur='unbounded' and not(ancestor::*[@maxoccur='unbounded'])]) + local:count-nodes-4-non-nested(.//field[@maxoccur and .//field[@timebasepath]]) ) * @maxoccur"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="max_dynamic_nodes" select="'ERROR : unexpected case'"/>
					</xsl:otherwise>
				</xsl:choose>
				<!--<xsl:sequence select=".//field[@timebasepath]"/>-->
				<!--<xsl:attribute name='cumul'><xsl:value-of>local:count-nodes(<xsl:sequence select=".//field[@timebasepath]"/>)</xsl:value-of></xsl:attribute>-->
			</xsl:element>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
