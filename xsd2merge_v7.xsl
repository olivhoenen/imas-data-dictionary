<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:template match="/*">
		<xsl:element name="xs:schema"><xsl:copy-of select="/xs:schema/*"/>
		<xsl:copy-of select="document('utilities/dd_support.xsd')/xs:schema/xs:complexType"/>
</xsl:element>	</xsl:template>
	
</xsl:stylesheet>
