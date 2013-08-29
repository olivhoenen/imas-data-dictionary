<?xml version="1.0" encoding="UTF-8"?>
<!-- ITERIS
Jo Lister August 2013
Transformation of xsd and utilities into a single xsd;
This is required since the xsd2xml transformation cannot easily handle two sources of information on the complex types
For this reason, we have a 2-step transformation, merge and then transform.
We have to explicitly extract elements we need - this may lead to modifications required if the Data Dictionary structure should change
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">	
<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>	
<xsl:template match="/*">
		<xsl:element name="xs:schema">
		    <xsl:copy-of select="document('utilities/dd_support.xsd')/xs:schema/xs:complexType"/>
		    <xsl:copy-of select="document('utilities/dd_support.xsd')/xs:schema/xs:simpleType"/>
		    <xsl:copy-of select="document('utilities/dd_support.xsd')/xs:schema/xs:group"/>
		    <xsl:copy-of select="document('utilities/dd_support.xsd')/xs:schema/xs:element[@name='ids_properties']"/>
		    <xsl:copy-of select="document('utilities/dd_support.xsd')/xs:schema/xs:element[@name='code']"/>
		    <xsl:copy-of select="document('utilities/dd_support.xsd')/xs:schema/xs:element[@name='time']"/>
 		    <xsl:copy-of select="/xs:schema/xs:complexType"/>
		    <xsl:copy-of select="/xs:schema/xs:element"/>
       </xsl:element>	
</xsl:template>
	
</xsl:stylesheet>
