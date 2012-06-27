<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!-- This script transforms the CPO definition file of the ITM Phase 4 data structure into a template XML file intendend to contain the machine description-->
	<!-- It is an instance of the Phase 4 schema with only the nodes that are flagged as "machine description" (NB when coding the DS, all nodes in the upper hierarchy going down to a MD node must be flagged as MD) -->
	<!-- The arborescence is thus the same as in the original schema -->
	<!-- The node values are pre-filled with the variable documentation, it is expected that the data provider replaces the definitions by the actual values, thus creating a machine description XML file -->
	<!-- This file will then be used to put machine description in the ITM data base -->
	<!-- Written by F. Imbeaux -->
	<!-- Version 08/08/2009 : direclty generates the template in "hybrid format", Imbeaux -->
	<!-- Version 26/02/2011 : implemented arrays of structure and multiple occurrences, Imbeaux -->
	<!-- Scan for top-level elements -->
	<xsl:template match="/*">
		<xsl:apply-templates select="/*/xs:element" mode="declare_child"/>
	</xsl:template>
	<!-- First, we scan at the CPO level -->
	<xsl:template name="process_element" match="xs:element" mode="declare_child">
		<xsl:choose>
			<xsl:when test="@name">
				<xsl:choose>
					<xsl:when test="@type">

						<xsl:element name="{@name}">

					<xsl:call-template name="doComplexTypeDeclare">
						<xsl:with-param name="thisType" select="@type"/>
					</xsl:call-template>						
							<!--<xsl:apply-templates select="*/*/xs:element" mode="declare_child"/>-->
						</xsl:element>
					</xsl:when>
					<xsl:otherwise>
						<xsl:element name="{@name}">
							<xsl:apply-templates select="*/*/xs:element" mode="declare_child"/>
						</xsl:element>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="@ref">
					<xsl:call-template name="doRefDeclare">
						<xsl:with-param name="thisRef" select="@ref"/>
					</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="doRefDeclare">
		<xsl:param name="thisRef"/>
		<xsl:apply-templates select="document('DD_Support.xsd')/*/xs:element[@name=$thisRef]" mode="declare_child"/>
	</xsl:template>
	<xsl:template name="doComplexTypeDeclare">
		<xsl:param name="thisType"/>
		<xsl:apply-templates select="document('DD_Support.xsd')/*/xs:complexType[@name=$thisType]/*/xs:element" mode="declare_child"/> <!-- up to now, this assumes the complexType is in DD_support, it has to be extended to the case where the complexType is in the original xsd file itself, or even in an include -->
	</xsl:template>	
	
	
</xsl:stylesheet>
