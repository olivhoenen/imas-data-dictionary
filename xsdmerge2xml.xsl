<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!-- ITERIS
Jo Lister August 2013
Script to create an XML file from the merged xsd schema,  adding the appinfo nodes to the outputs 
Imbeaux and Lister inspirations over time
It works, but Jo believes that it could be pruned - to be done on a rainy day
-->
	<xsl:template match="/*">
		<!-- We have to trap other elements in the merged xsd file -->
		<xsl:apply-templates select="/*/xs:element[@name!='time' and @name!='ids_properties' and @name!='code' ]" mode="declare_child"/>
	</xsl:template>
	
	<xsl:template name="process_element" match="xs:element" mode="declare_child">
	<!-- First, we scan at the IDS level, select all xs:elements-->
		<xsl:choose>
			<xsl:when test="@name">
				<xsl:element name="{@name}">
				<!-- this element has a name, create an element with this name -->
					<xsl:apply-templates select="xs:annotation"/>
					<!-- add the documentation and appinfo from the schema -->
					<xsl:if test="@type">
					<!-- if the element has a type, expand it as a complex type-->
						<xsl:call-template name="doComplexTypeDeclare">
							<xsl:with-param name="thisType" select="@type"/>
						</xsl:call-template>
					</xsl:if>
					<!-- just drill down -->
					<xsl:apply-templates select="*/*/xs:element" mode="declare_child"/>
					<xsl:apply-templates select="*/*/xs:group"/>
					<xsl:apply-templates select="xs:complexType/xs:group"/>
				</xsl:element>
				<xsl:if test="@maxOccurs">
					<xsl:element name="{@name}">
						<xsl:apply-templates select="xs:annotation"/>
						<!-- add the documentation and appinfo from the schema -->
						<xsl:if test="@type">
						<!-- if the element has a type, expand it as a complex type-->
							<xsl:call-template name="doComplexTypeDeclare">
								<xsl:with-param name="thisType" select="@type"/>
							</xsl:call-template>
						</xsl:if>
						<!-- just drill down -->
						<xsl:apply-templates select="*/*/xs:element" mode="declare_child"/>
						<xsl:apply-templates select="*/*/xs:group"/>
						<xsl:apply-templates select="xs:complexType/xs:group"/>
					</xsl:element>
				</xsl:if>
			</xsl:when>
			<xsl:when test="@ref">
				<!-- if this has a reference, just expand the reference -->
				<xsl:call-template name="doRefDeclare">
					<xsl:with-param name="thisRef" select="@ref"/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="xs:annotation[ancestor::xs:element[@name='ids_properties']]">
		<!-- do not annotate IDS_Properties-->
	</xsl:template>
	
	<xsl:template match="xs:annotation">
		<xsl:apply-templates select="xs:documentation"/>
		<xsl:apply-templates select="xs:appinfo"/>
	</xsl:template>
	
	<xsl:template match="xs:group">
		<!-- expand any group -->
		<xsl:call-template name="doGroupDeclare">
			<xsl:with-param name="thisRef" select="@ref"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="xs:appinfo">
		<!-- expand appinfo -->
		<xsl:for-each select="child::*">
			<xsl:element name="{name()}">
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="xs:documentation">
		<xsl:element name="documentation">
		<!-- replicate documentation with all nodes-->
			<xsl:value-of select="."/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="doGroupDeclare">
		<!-- expand this group with a defined reference name, searching the support file -->
		<xsl:param name="thisRef"/>
		<xsl:for-each select="document('utilities/dd_support.xsd')/*/xs:group[@name=$thisRef]/xs:sequence/xs:element">
			<xsl:element name="{@name}">
				<xsl:value-of select="@fixed"/>
				<xsl:value-of select="@default"/>
			</xsl:element>
		</xsl:for-each>
		<xsl:for-each select="document('utilities/dd_support.xsd')/*/xs:group[@name='data_properties']/xs:sequence/xs:element">
			<xsl:element name="{@name}">
				<xsl:value-of select="@fixed"/>
				<xsl:value-of select="@default"/>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="doRefDeclare">
		<!-- expand this ref with a defined reference name, searching the support file -->
		<xsl:param name="thisRef"/>
		<xsl:apply-templates select="document('utilities/dd_support.xsd')/*/xs:element[@name=$thisRef]" mode="declare_child"/>
	</xsl:template>
	
	<xsl:template name="doComplexTypeDeclare">
		<!-- expand this complexType searching the local file-->
		<xsl:param name="thisType"/>
		<xsl:if test="not(xs:complexType)">
			<xsl:apply-templates select="/*/xs:complexType[@name=$thisType]/*/xs:element" mode="declare_child"/>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>
