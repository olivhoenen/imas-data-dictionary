<?xml version="1.0" encoding="UTF-8"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./%24GET%5Bstylesheet%5D" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>
<xsl:stylesheet xmlns:yaslt="http://www.mod-xslt2.com/ns/2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" extension-element-prefixes="yaslt" xmlns:fn="http://www.w3.org/2005/02/xpath-functions" xmlns:local="http://www.example.com/functions/local" exclude-result-prefixes="local xs">

	<!-- -->
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="DD_GIT_DESCRIBE" as="xs:string" required="yes"/>

	<!-- This script transforms the collection of XSD files forming the Data Dictionary into a single XML file describing explicitly all nodes with their characteristics-->
	<!-- The resulting XML file makes further work on the data dictionary much easier, since it describes explicitely the whole schema (includes and references are solved) -->
	<!-- Author:F. Imbeaux, CEA, adapted from xsd2CPODef7 of EU-ITM -->
	<!-- 05/02/2014: Introduced a new attribute path_doc which marks arrays of structure by inserting (:) in the path, used only for documentation purposes (the original path attribute is left unchanged since it is used in the high level UAL generation). NB the method for filling path_doc could be used in the future to remove the limitation of location of the coordinates below struct_arrays -->
	<!-- CAUTION: Coordinate_path must also be written in the XSD with the (:) convention for arrays of structure -->
	<xsl:function name="local:getAbsolutePath" as="xs:string">
		<!-- Given a path resolves any ".." or "." terms 
	  to produce an absolute path -->
		<!-- Kindly taken from Eliot Kimber, http://www.dpawson.co.uk/xsl/sect2/N6052.html#d8250e163, Path between two nodes -->
		<xsl:param name="sourcePath" as="xs:string"/>
		<xsl:variable name="pathTokens" select="tokenize($sourcePath, '/')" as="xs:string*"/>
		<xsl:if test="false()">
			<xsl:message> + 
	  DEBUG local:getAbsolutePath(): Starting</xsl:message>
			<xsl:message> +       
	  sourcePath="<xsl:value-of select="$sourcePath"/>"</xsl:message>
		</xsl:if>
		<xsl:variable name="baseResult" select="string-join(local:makePathAbsolute($pathTokens, ()), 
	  '/')" as="xs:string"/>
		<xsl:variable name="result" as="xs:string" select="if (starts-with($sourcePath, '/') and 
	  not(starts-with($baseResult, '/')))
                  then concat('/', $baseResult)
                  else $baseResult
               "/>
		<xsl:if test="false()">
			<xsl:message> + 
DEBUG: 	  result="<xsl:value-of select="$result"/>"</xsl:message>
		</xsl:if>
		<xsl:value-of select="$result"/>
	</xsl:function>
	<xsl:function name="local:makePathAbsolute" as="xs:string*">
		<xsl:param name="pathTokens" as="xs:string*"/>
		<xsl:param name="resultTokens" as="xs:string*"/>
		<xsl:if test="false()">
			<xsl:message> + 
	  DEBUG: local:makePathAbsolute(): Starting...</xsl:message>
			<xsl:message> + 
	  DEBUG:    pathTokens="<xsl:value-of select="string-join($pathTokens, 
	  ',')"/>"</xsl:message>
			<xsl:message> + 
	  DEBUG:    resultTokens="<xsl:value-of select="string-join($resultTokens, 
	  ',')"/>"</xsl:message>
		</xsl:if>
		<xsl:sequence select="if (count($pathTokens) = 0)
	  then $resultTokens
	  else 
	  if ($pathTokens[1] = '.')
	  then local:makePathAbsolute($pathTokens[position() > 1], 
	  $resultTokens)
	  else 
	  if ($pathTokens[1] = '..')
	  then local:makePathAbsolute($pathTokens[position() > 1], 
	  $resultTokens[position() &lt; last()])
	  else local:makePathAbsolute($pathTokens[position() > 1], 
	  ($resultTokens, $pathTokens[1]))
	  "/>
	</xsl:function>
	<!-- A first scan is performed on the top-level elements to find out the IDS components and to declare them each time a IDS is found, its elements are scanned via apply'templates in IMPLEMENT mode -->
	<xsl:template match="/*">
		<IDSs>
		  <!-- Stores version of DD -->
		  <version>
		    <xsl:value-of select="$DD_GIT_DESCRIBE"/>
		  </version>
		  <!-- Stores COCOS choice for this version of DD -->
		  <cocos>
		    <xsl:value-of select="./xs:element/xs:annotation/xs:appinfo/cocos"/>
		  </cocos>
		<utilities>
        <!-- Declare complex types from Utilities -->
        <xsl:for-each select="document('utilities/dd_support.xsd')/*/xs:complexType">
        <field>
        <xsl:attribute name="name" select="@name"/>
        <xsl:attribute name="data_type" select="'structure'"/>
        <xsl:attribute name="structure_reference" select="'self'"/>
        <xsl:attribute name="documentation" select="xs:annotation/xs:documentation"/>
        <xsl:call-template name="doImplementType">
                   <xsl:with-param name="thisType" select="@name"/>
					<xsl:with-param name="currPath" select="''"/>    <!-- Overloading of this parameter to pass the information that we are processing the utilities section -->
					<xsl:with-param name="currPath_doc" select="''"/>
					<xsl:with-param name="aosLevel" select="1"/>
					<xsl:with-param name="aos3Parent" select="xs:annotation/xs:appinfo/aos3Parent"/>
					<xsl:with-param name="structure_reference" select="'self'"/>
          </xsl:call-template>
          </field>
        </xsl:for-each>
        <!-- Declare Elements from Utilities (only those being the root of a structure, simple elements are not needed in IDSDef.xml)-->
        <xsl:apply-templates select="document('utilities/dd_support.xsd')/*/xs:element[./xs:complexType]" mode="IMPLEMENT">
<xsl:with-param name="structure_reference" select="'self'"/>
<xsl:with-param name="aosLevel" select="1"/>
<xsl:with-param name="aos3Parent" select="xs:annotation/xs:appinfo/aos3Parent"/>
        </xsl:apply-templates> 
		</utilities>
	<!-- Scan for top-level elements (IDSs) -->
			<xsl:apply-templates select="*/*/*/xs:element" mode="DECLARE">
				<xsl:with-param name="currPath" select="''"/>
				<xsl:with-param name="currPath_doc" select="''"/>
				<xsl:with-param name="maxOcc" select="''"/>
			</xsl:apply-templates>
		</IDSs>
	</xsl:template>
	<xsl:template match="xs:element" mode="DECLARE">
		<xsl:param name="currPath"/>
		<xsl:param name="currPath_doc"/>
		<xsl:param name="maxOcc"/>
		<xsl:choose>
			<xsl:when test="@name">
				<xsl:choose>
					<!-- If it is declared as a IDS -->
					<xsl:when test="*/*/xs:element[@ref='ids_properties']">
						<IDS>
							<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
							<xsl:choose>
								<xsl:when test="$maxOcc">
									<!-- Case of ref (most IDSs are in a separate xsd file and are implemented by the doRefdeclare template, maxoccurs is passed through the maxOcc parameter -->
									<xsl:attribute name="maxoccur"><xsl:value-of select="$maxOcc"/></xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="maxoccur">1</xsl:attribute>
									<!-- In all other cases, maxoccurs is not defined, meaning 1 by default (W3C schema convention) -->
								</xsl:otherwise>
							</xsl:choose>
							<!-- Replicate DOCUMENTATION as an attribute-->
							<xsl:attribute name="documentation"><xsl:value-of select="xs:annotation/xs:documentation"/></xsl:attribute>
							<!-- Replicate LIFECYCLE information as an attribute-->
							<xsl:attribute name="lifecycle_status"><xsl:value-of select="xs:annotation/xs:appinfo/lifecycle_status"/></xsl:attribute>
							<xsl:attribute name="lifecycle_version"><xsl:value-of select="xs:annotation/xs:appinfo/lifecycle_version"/></xsl:attribute>
							<xsl:attribute name="lifecycle_last_change"><xsl:value-of select="xs:annotation/xs:appinfo/lifecycle_last_change"/></xsl:attribute>
							<xsl:if test="xs:annotation/xs:appinfo/specific_validation_rules"><xsl:attribute name="specific_validation_rules"><xsl:value-of select="xs:annotation/xs:appinfo/specific_validation_rules"/></xsl:attribute></xsl:if>
							<xsl:if test="xs:annotation/xs:appinfo/url"><xsl:attribute name="url"><xsl:value-of select="xs:annotation/xs:appinfo/url"/></xsl:attribute></xsl:if>
							<!-- Scan its components in IMPLEMENT mode -->
							<xsl:apply-templates select="xs:complexType" mode="IMPLEMENT">
								<xsl:with-param name="currPath" select="''"/>
								<xsl:with-param name="currPath_doc" select="''"/>
								<xsl:with-param name="aosLevel" select="1"/>
							</xsl:apply-templates>
							<xsl:choose>
								<xsl:when test="@name and @type">
									<xsl:call-template name="doImplementType">
										<xsl:with-param name="thisType" select="@type"/>
										<xsl:with-param name="currPath" select="''"/>
										<xsl:with-param name="currPath_doc" select="''"/>
										<xsl:with-param name="aosLevel" select="1"/>
									</xsl:call-template>
								</xsl:when>
							</xsl:choose>
						</IDS>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<!-- Scan all external references declared -->
			<xsl:when test="@ref">
				<xsl:call-template name="doRefDeclare">
					<xsl:with-param name="thisRef" select="@ref"/>
					<xsl:with-param name="maxOcc" select="@maxOccurs"/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!-- Handle include template in IMPLEMENT mode -->
	<xsl:template match="xs:include" mode="IMPLEMENT">
		<xsl:param name="actRef"/>
		<xsl:param name="currPath"/>
		<xsl:param name="currPath_doc"/>
		<xsl:param name="aosLevel"/>
		<xsl:apply-templates select="document(@schemaLocation)/*/xs:element[@name=$actRef]" mode="IMPLEMENT">
			<xsl:with-param name="currPath" select="$currPath"/>
			<xsl:with-param name="currPath_doc" select="$currPath_doc"/>
			<xsl:with-param name="aosLevel" select="$aosLevel"/>
		</xsl:apply-templates>
	</xsl:template>
	<!-- Handle ComplexType definition in IMPLEMENT mode -->
	<xsl:template match="xs:complexType" mode="IMPLEMENT">
		<xsl:param name="currPath"/>
		<xsl:param name="currPath_doc"/>
		<xsl:param name="aosLevel"/>
        <xsl:param name="aos3Parent"/>
        <xsl:param name="structure_reference"/>
		<xsl:param name="parentmachine"/>
		<xsl:param name="parenttime"/>
		<xsl:param name="parentunit"/>
		<xsl:param name="experimental"/>
		<!-- Treat here the representation attributes for a ComplexType structure-->
		<xsl:apply-templates select="xs:annotation/xs:appinfo[contains(string(.),'representation')]">
			<xsl:with-param name="currPath" select="$currPath"/>
			<xsl:with-param name="currPath_doc" select="$currPath_doc"/>
			<xsl:with-param name="aosLevel" select="$aosLevel"/>
			<xsl:with-param name="relPath" select="'yes'"/>
		</xsl:apply-templates>
		<!-- Start implementing all child elements of the complexType -->
		<xsl:apply-templates select="*/xs:element" mode="IMPLEMENT">
			<xsl:with-param name="currPath" select="$currPath"/>
			<xsl:with-param name="currPath_doc" select="$currPath_doc"/>
			<xsl:with-param name="aosLevel" select="$aosLevel"/>
            <xsl:with-param name="aos3Parent" select="$aos3Parent"/>
            <xsl:with-param name="structure_reference" select="$structure_reference"/>
			<xsl:with-param name="parentmachine" select="$parentmachine"/>
			<xsl:with-param name="parenttime" select="$parenttime"/>
			<xsl:with-param name="parentunit" select="$parentunit"/>
			<xsl:with-param name="experimental" select="$experimental"/>
		</xsl:apply-templates>
	</xsl:template>
	<!-- Handle element definition in implement mode. Here all data types are checked -->
	<xsl:template match="xs:element" mode="IMPLEMENT">
		<xsl:param name="currPath"/>
		<xsl:param name="currPath_doc"/>
		<xsl:param name="aosLevel"/>
		<xsl:param name="aos3Parent"/>
		<xsl:param name="parentmachine"/>
		<xsl:param name="parenttime"/>
		<xsl:param name="parentunit"/>
		<xsl:param name="experimental"/>
		<xsl:param name="structure_reference"/>
		<xsl:choose>
			<!-- If it is an external reference -->
			<xsl:when test="@ref">
				<xsl:call-template name="doRefImplement">
					<xsl:with-param name="thisRef" select="@ref"/>
					<xsl:with-param name="currPath" select="$currPath"/>
					<xsl:with-param name="currPath_doc" select="$currPath_doc"/>
					<xsl:with-param name="aosLevel" select="$aosLevel"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="@name">
				<xsl:choose>
					<!-- if the node is a leaf defined as a simple type -->
					<xsl:when test="@type='int_type' or @type='flt_type'  or @type='str_type' or @type='flt_1d_type' or @type='str_1d_type' or @type='int_1d_type'">
						<field>
							<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
							<xsl:choose>
								<xsl:when test="$currPath=''">
									<xsl:attribute name="path"><xsl:value-of select="@name"/></xsl:attribute>
									<xsl:attribute name="path_doc"><xsl:value-of select="@name"/><xsl:call-template name="AddToPathDoc"><xsl:with-param name="data_type" select="@type"/></xsl:call-template></xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="path"><xsl:value-of select="concat($currPath,'/',@name)"/></xsl:attribute>
									<xsl:attribute name="path_doc"><xsl:value-of select="concat($currPath_doc,'/',@name)"/><xsl:call-template name="AddToPathDoc"><xsl:with-param name="data_type" select="@type"/></xsl:call-template></xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:attribute name="documentation"><xsl:value-of select="xs:annotation/xs:documentation"/></xsl:attribute>
							<xsl:attribute name="data_type"><xsl:value-of select="@type"/></xsl:attribute>
							<xsl:for-each select="xs:annotation/xs:appinfo/*">
								<!-- Generic method for declaring all appinfo as attributes-->
								<xsl:attribute name="{name(.)}"><xsl:value-of select="."/></xsl:attribute>
								<!-- Write a timebasepath attribute (coordinate path relative to the nearest AoS parent) in case the appinfo is a coordinate to a timebase -->
										<xsl:if test="contains(lower-case(name(.)),'coordinate') and (ends-with(.,'time') or ../../../@name='time')">
										<xsl:attribute name="timebasepath">
										<xsl:choose><xsl:when test="$currPath=''"><xsl:call-template name="BuildRelativeAosParentPath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="../../../@name"/><xsl:with-param name="coordinatePath" select="''"/><xsl:with-param name="aosLevel" select="$aosLevel - 1"/><xsl:with-param name="structure_reference" select="$structure_reference"/></xsl:call-template></xsl:when><xsl:otherwise><xsl:call-template name="BuildRelativeAosParentPath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat($currPath_doc,'/',../../../@name)"/><xsl:with-param name="coordinatePath" select="''"/><xsl:with-param name="aosLevel" select="$aosLevel - 1"/><xsl:with-param name="structure_reference" select="$structure_reference"/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:attribute>
										</xsl:if>
							</xsl:for-each>
						</field>
					</xsl:when>
					<xsl:when test="xs:complexType/xs:group">
						<!-- if the node is a leaf defined with a complexType/Group -->
						<field>
							<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
							<xsl:choose>
								<xsl:when test="$currPath=''">
									<xsl:attribute name="path"><xsl:value-of select="@name"/></xsl:attribute>
									<xsl:attribute name="path_doc"><xsl:value-of select="@name"/><xsl:call-template name="AddToPathDoc"><xsl:with-param name="data_type" select="xs:complexType/xs:group/@ref"/></xsl:call-template></xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="path"><xsl:value-of select="concat($currPath,'/',@name)"/></xsl:attribute>
									<xsl:attribute name="path_doc"><xsl:value-of select="concat($currPath_doc,'/',@name)"/><xsl:call-template name="AddToPathDoc"><xsl:with-param name="data_type" select="xs:complexType/xs:group/@ref"/></xsl:call-template></xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:attribute name="documentation"><xsl:value-of select="xs:annotation/xs:documentation"/></xsl:attribute>
							<xsl:attribute name="data_type"><xsl:value-of select="xs:complexType/xs:group/@ref"/></xsl:attribute>
							<xsl:for-each select="xs:annotation/xs:appinfo/*">
								<!-- Generic method for declaring all appinfo as attributes-->
								<xsl:attribute name="{lower-case(name(.))}"><xsl:choose><xsl:when test="contains(lower-case(name(.)),'coordinate')"><xsl:choose><xsl:when test="$currPath=''"><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="../../../@name"/><xsl:with-param name="coordinatePath" select="."/></xsl:call-template></xsl:when><xsl:otherwise><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat($currPath_doc,'/',../../../@name)"/><xsl:with-param name="coordinatePath" select="."/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:when><xsl:otherwise><xsl:value-of select="."/></xsl:otherwise></xsl:choose></xsl:attribute>
										<!-- Write a timebasepath attribute (coordinate path relative to the nearest AoS parent) in case the appinfo is a coordinate to a timebase -->
										<xsl:if test="contains(lower-case(name(.)),'coordinate') and ends-with(.,'time')">
										<xsl:attribute name="timebasepath">
										<xsl:choose><xsl:when test="$currPath=''"><xsl:call-template name="BuildRelativeAosParentPath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="../../../@name"/><xsl:with-param name="coordinatePath" select="."/><xsl:with-param name="aosLevel" select="$aosLevel - 1"/><xsl:with-param name="structure_reference" select="$structure_reference"/><xsl:with-param name="utilities_aoscontext" select="../utilities_aoscontext"/></xsl:call-template></xsl:when><xsl:otherwise><xsl:call-template name="BuildRelativeAosParentPath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat($currPath_doc,'/',../../../@name)"/><xsl:with-param name="coordinatePath" select="."/><xsl:with-param name="aosLevel" select="$aosLevel - 1"/><xsl:with-param name="structure_reference" select="$structure_reference"/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:attribute>
										</xsl:if>
							</xsl:for-each>
						</field>
						<!-- Then we test if the type is real or complex, if so add *_error nodes to the structure for the errorbars -->
						<xsl:if test="(contains(xs:complexType/xs:group/@ref,'FLT') or contains(xs:complexType/xs:group/@ref,'CPX')) and not(contains(@name,'_limit_'))">
							<field>
								<!-- _error_upper field -->
								<xsl:attribute name="name"><xsl:value-of select="concat(@name,'_error_upper')"/></xsl:attribute>
								<xsl:choose>
									<xsl:when test="$currPath=''">
										<xsl:attribute name="path"><xsl:value-of select="concat(@name,'_error_upper')"/></xsl:attribute>
										<xsl:attribute name="path_doc"><xsl:value-of select="concat(@name,'_error_upper')"/><xsl:call-template name="AddToPathDoc"><xsl:with-param name="data_type" select="xs:complexType/xs:group/@ref"/></xsl:call-template></xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="path"><xsl:value-of select="concat($currPath,'/',@name,'_error_upper')"/></xsl:attribute>
										<xsl:attribute name="path_doc"><xsl:value-of select="concat($currPath_doc,'/',@name,'_error_upper')"/><xsl:call-template name="AddToPathDoc"><xsl:with-param name="data_type" select="xs:complexType/xs:group/@ref"/></xsl:call-template></xsl:attribute>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:attribute name="documentation"><xsl:value-of select="concat('Upper error for &quot;',@name,'&quot;')"/></xsl:attribute>
								<xsl:attribute name="data_type"><xsl:value-of select="xs:complexType/xs:group/@ref"/></xsl:attribute>
								<xsl:for-each select="xs:annotation/xs:appinfo/*">
									<!-- Generic method for declaring all appinfo as attributes-->
									<xsl:attribute name="{lower-case(name(.))}"><xsl:choose><xsl:when test="contains(lower-case(name(.)),'coordinate')"><xsl:choose><xsl:when test="$currPath=''"><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="../../../@name"/><xsl:with-param name="coordinatePath" select="."/></xsl:call-template></xsl:when><xsl:when test="contains(name(.),'change_nbc_previous_name')"><xsl:value-of select="."/><xsl:value-of select="'_error_upper'"/></xsl:when><xsl:otherwise><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat($currPath_doc,'/',../../../@name)"/><xsl:with-param name="coordinatePath" select="."/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:when><xsl:when test="contains(name(.),'change_nbc_previous_name')"><xsl:value-of select="."/><xsl:value-of select="'_error_upper'"/></xsl:when><xsl:otherwise><xsl:value-of select="."/></xsl:otherwise></xsl:choose></xsl:attribute>
										<!-- Write a timebasepath attribute (coordinate path relative to the nearest AoS parent) in case the appinfo is a coordinate to a timebase -->
										<xsl:if test="contains(lower-case(name(.)),'coordinate') and (ends-with(.,'time') or ../../../@name='time')">
										<xsl:attribute name="timebasepath">
										<xsl:choose><xsl:when test="$currPath=''"><xsl:call-template name="BuildRelativeAosParentPath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="../../../@name"/><xsl:with-param name="coordinatePath" select="."/><xsl:with-param name="aosLevel" select="$aosLevel - 1"/><xsl:with-param name="structure_reference" select="$structure_reference"/><xsl:with-param name="utilities_aoscontext" select="../utilities_aoscontext"/></xsl:call-template></xsl:when><xsl:otherwise><xsl:call-template name="BuildRelativeAosParentPath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat($currPath_doc,'/',../../../@name)"/><xsl:with-param name="coordinatePath" select="."/><xsl:with-param name="aosLevel" select="$aosLevel - 1"/><xsl:with-param name="structure_reference" select="$structure_reference"/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:attribute>
										</xsl:if>
								</xsl:for-each>
							</field>
							<field>
								<!-- _error_lower field -->
								<xsl:attribute name="name"><xsl:value-of select="concat(@name,'_error_lower')"/></xsl:attribute>
								<xsl:choose>
									<xsl:when test="$currPath=''">
										<xsl:attribute name="path"><xsl:value-of select="concat(@name,'_error_lower')"/></xsl:attribute>
										<xsl:attribute name="path_doc"><xsl:value-of select="concat(@name,'_error_lower')"/><xsl:call-template name="AddToPathDoc"><xsl:with-param name="data_type" select="xs:complexType/xs:group/@ref"/></xsl:call-template></xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="path"><xsl:value-of select="concat($currPath,'/',@name,'_error_lower')"/></xsl:attribute>
										<xsl:attribute name="path_doc"><xsl:value-of select="concat($currPath_doc,'/',@name,'_error_lower')"/><xsl:call-template name="AddToPathDoc"><xsl:with-param name="data_type" select="xs:complexType/xs:group/@ref"/></xsl:call-template></xsl:attribute>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:attribute name="documentation"><xsl:value-of select="concat('Lower error for &quot;',@name,'&quot;')"/></xsl:attribute>
								<xsl:attribute name="data_type"><xsl:value-of select="xs:complexType/xs:group/@ref"/></xsl:attribute>
								<xsl:for-each select="xs:annotation/xs:appinfo/*">
									<!-- Generic method for declaring all appinfo as attributes-->
									<xsl:attribute name="{lower-case(name(.))}"><xsl:choose><xsl:when test="contains(lower-case(name(.)),'coordinate')"><xsl:choose><xsl:when test="$currPath=''"><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="../../../@name"/><xsl:with-param name="coordinatePath" select="."/></xsl:call-template></xsl:when><xsl:otherwise><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat($currPath_doc,'/',../../../@name)"/><xsl:with-param name="coordinatePath" select="."/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:when><xsl:when test="contains(name(.),'change_nbc_previous_name')"><xsl:value-of select="."/><xsl:value-of select="'_error_lower'"/></xsl:when><xsl:otherwise><xsl:value-of select="."/></xsl:otherwise></xsl:choose></xsl:attribute>
										<!-- Write a timebasepath attribute (coordinate path relative to the nearest AoS parent) in case the appinfo is a coordinate to a timebase -->
										<xsl:if test="contains(lower-case(name(.)),'coordinate') and (ends-with(.,'time') or ../../../@name='time')">
										<xsl:attribute name="timebasepath">
										<xsl:choose><xsl:when test="$currPath=''"><xsl:call-template name="BuildRelativeAosParentPath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="../../../@name"/><xsl:with-param name="coordinatePath" select="."/><xsl:with-param name="aosLevel" select="$aosLevel - 1"/><xsl:with-param name="structure_reference" select="$structure_reference"/><xsl:with-param name="utilities_aoscontext" select="../utilities_aoscontext"/></xsl:call-template></xsl:when><xsl:otherwise><xsl:call-template name="BuildRelativeAosParentPath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat($currPath_doc,'/',../../../@name)"/><xsl:with-param name="coordinatePath" select="."/><xsl:with-param name="aosLevel" select="$aosLevel - 1"/><xsl:with-param name="structure_reference" select="$structure_reference"/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:attribute>
										</xsl:if>
								</xsl:for-each>
							</field>
							<field>
								<!-- _error_index field -->
								<xsl:attribute name="name"><xsl:value-of select="concat(@name,'_error_index')"/></xsl:attribute>
								<xsl:attribute name="lifecycle_status">obsolescent</xsl:attribute>
								<xsl:attribute name="lifecycle_version">3.38.1</xsl:attribute>
								<xsl:choose>
									<xsl:when test="$currPath=''">
										<xsl:attribute name="path"><xsl:value-of select="concat(@name,'_error_index')"/></xsl:attribute>
										<xsl:attribute name="path_doc"><xsl:value-of select="concat(@name,'_error_index')"/></xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="path"><xsl:value-of select="concat($currPath,'/',@name,'_error_index')"/></xsl:attribute>
										<xsl:attribute name="path_doc"><xsl:value-of select="concat($currPath_doc,'/',@name,'_error_index')"/></xsl:attribute>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:attribute name="documentation"><xsl:value-of select="concat('Index in the error_description list for &quot;',@name,'&quot;')"/></xsl:attribute>
								<xsl:attribute name="data_type">int_type</xsl:attribute>
<xsl:choose>
														<xsl:when test="contains($currPath_doc,'(itime)') or contains($aos3Parent,'yes')">
															<xsl:attribute name="type">dynamic</xsl:attribute> <!-- the node must be dynamic if it has any dynamic (type 3) AoS ancestor, although this is likely overkill to specify a time-dependent error expression -->
														</xsl:when>
														<xsl:otherwise>
															<xsl:attribute name="type">constant</xsl:attribute>														
														</xsl:otherwise>
														</xsl:choose>			
								   <xsl:if test="contains(./xs:annotation/xs:appinfo/change_nbc_description,'leaf_renamed')">
                                        <xsl:attribute name="change_nbc_version"><xsl:value-of select="./xs:annotation/xs:appinfo/change_nbc_version"/></xsl:attribute>	                                     
                                         <xsl:attribute name="change_nbc_description"><xsl:value-of select="./xs:annotation/xs:appinfo/change_nbc_description"/></xsl:attribute>	
                                        <xsl:attribute name="change_nbc_previous_name"><xsl:value-of select="concat(./xs:annotation/xs:appinfo/change_nbc_previous_name,'_error_index')"/></xsl:attribute>	   
								   </xsl:if>				
							</field>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<!-- Otherwise the type is defined somewhere else (dd_support.xsd) or is a complex type  -->
						<xsl:choose>
							<xsl:when test="@type">
								<!-- It is an external reference -->
								<field>
									<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
                                    <xsl:attribute name="structure_reference"><xsl:value-of select="@type"/></xsl:attribute>
									<xsl:choose>
										<xsl:when test="$currPath=''">
											<xsl:attribute name="path"><xsl:value-of select="@name"/></xsl:attribute>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="path"><xsl:value-of select="concat($currPath,'/',@name)"/></xsl:attribute>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:attribute name="documentation"><xsl:value-of select="xs:annotation/xs:documentation"/></xsl:attribute>
									<xsl:choose>
										<!-- It is an array of structures -->
										<xsl:when test="@maxOccurs='unbounded' or @maxOccurs &gt; 1">
											<xsl:attribute name="data_type">struct_array</xsl:attribute>
											<xsl:attribute name="maxoccur"><xsl:value-of select="@maxOccurs"/></xsl:attribute>
											<xsl:choose>
												<xsl:when test="$currPath_doc=''">
													<xsl:attribute name="path_doc"><xsl:value-of select="@name"/><xsl:call-template name="aosIndex"><xsl:with-param name="aosLevel" select="$aosLevel"/></xsl:call-template></xsl:attribute>
												</xsl:when>
												<xsl:otherwise>
													<xsl:attribute name="path_doc"><xsl:value-of select="concat($currPath_doc,'/',@name)"/><xsl:call-template name="aosIndex"><xsl:with-param name="aosLevel" select="$aosLevel"/></xsl:call-template></xsl:attribute>
												</xsl:otherwise>
											</xsl:choose>
											<xsl:for-each select="xs:annotation/xs:appinfo/*">
												<!-- Generic method for declaring all appinfo as attributes. There is a long, special treatement for coordinates because the path is indicated, otherwise treatment is just copying the attribute (see the value-of select . at the very end ...) -->
												<xsl:attribute name="{lower-case(name(.))}"><xsl:choose><xsl:when test="contains(lower-case(name(.)),'coordinate')"><xsl:choose><xsl:when test="../type='dynamic'"><xsl:choose><xsl:when test="$currPath=''"><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat(../../../@name,'(itime)')"/><xsl:with-param name="coordinatePath" select="."/></xsl:call-template></xsl:when><xsl:otherwise><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat($currPath_doc,'/',../../../@name,'(itime)')"/><xsl:with-param name="coordinatePath" select="."/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:when><xsl:otherwise><xsl:choose><xsl:when test="$currPath=''"><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat(../../../@name,'($aosLevel)')"/><xsl:with-param name="coordinatePath" select="."/></xsl:call-template></xsl:when><xsl:otherwise><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat($currPath_doc,'/',../../../@name,'($aosLevel)')"/><xsl:with-param name="coordinatePath" select="."/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:otherwise></xsl:choose></xsl:when><xsl:otherwise><xsl:value-of select="."/></xsl:otherwise></xsl:choose></xsl:attribute>
											</xsl:for-each>
										</xsl:when>
										<!-- It is a regular structure -->
										<xsl:otherwise>
											<xsl:attribute name="data_type">structure</xsl:attribute>
											<xsl:choose>
												<xsl:when test="$currPath_doc=''">
													<xsl:attribute name="path_doc"><xsl:value-of select="@name"/></xsl:attribute>
												</xsl:when>
												<xsl:otherwise>
													<xsl:attribute name="path_doc"><xsl:value-of select="concat($currPath_doc,'/',@name)"/></xsl:attribute>
												</xsl:otherwise>
											</xsl:choose>
											<xsl:for-each select="xs:annotation/xs:appinfo/*">
												<!-- Generic method for declaring all appinfo as attributes. There is a long, special treatement for coordinates because the path is indicated, otherwise treatment is just copying the attribute (see the value-of select . at the very end ...) -->
												<xsl:attribute name="{lower-case(name(.))}"><xsl:choose><xsl:when test="contains(lower-case(name(.)),'coordinate')"><xsl:choose><xsl:when test="$currPath=''"><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="../../../@name"/><xsl:with-param name="coordinatePath" select="."/></xsl:call-template></xsl:when><xsl:otherwise><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat($currPath_doc,'/',../../../@name)"/><xsl:with-param name="coordinatePath" select="."/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:when><xsl:otherwise><xsl:value-of select="."/></xsl:otherwise></xsl:choose></xsl:attribute>
											</xsl:for-each>
										</xsl:otherwise>
									</xsl:choose>
									<!-- Handle type definition via template doImplementType. Need to pass an appropriate path definition -->
									<xsl:choose>
										<xsl:when test="$currPath=''">
											<xsl:choose>
												<xsl:when test="@maxOccurs='unbounded' or @maxOccurs &gt; 1">
													<xsl:choose>
														<xsl:when test="xs:annotation/xs:appinfo/type='dynamic'">
															<xsl:call-template name="doImplementType">
																<xsl:with-param name="thisType" select="@type"/>
																<xsl:with-param name="currPath" select="@name"/>
																<xsl:with-param name="currPath_doc" select="concat(@name,'(itime)')"/>
																<xsl:with-param name="aosLevel" select="$aosLevel"/>
																<xsl:with-param name="aos3Parent" select="$aos3Parent"/>
															</xsl:call-template>
														</xsl:when>
														<xsl:otherwise>
															<xsl:call-template name="doImplementType">
																<xsl:with-param name="thisType" select="@type"/>
																<xsl:with-param name="currPath" select="@name"/>
																<xsl:with-param name="currPath_doc" select="concat(@name,'(i',$aosLevel,')')"/>
																<xsl:with-param name="aosLevel" select="$aosLevel+1"/>
																<xsl:with-param name="aos3Parent" select="$aos3Parent"/>
															</xsl:call-template>
														</xsl:otherwise>
													</xsl:choose>
												</xsl:when>
												<xsl:otherwise>
													<xsl:call-template name="doImplementType">
														<xsl:with-param name="thisType" select="@type"/>
														<xsl:with-param name="currPath" select="@name"/>
														<xsl:with-param name="currPath_doc" select="@name"/>
														<xsl:with-param name="aosLevel" select="$aosLevel"/>
														<xsl:with-param name="aos3Parent" select="$aos3Parent"/>
													</xsl:call-template>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:when>
										<xsl:otherwise>
											<xsl:choose>
												<xsl:when test="@maxOccurs='unbounded' or @maxOccurs &gt; 1">
													<xsl:choose>
														<xsl:when test="xs:annotation/xs:appinfo/type='dynamic'">
															<xsl:call-template name="doImplementType">
																<xsl:with-param name="thisType" select="@type"/>
																<xsl:with-param name="currPath" select="concat($currPath,'/',@name)"/>
																<xsl:with-param name="currPath_doc" select="concat($currPath_doc,'/',@name,'(itime)')"/>
																<xsl:with-param name="aosLevel" select="$aosLevel"/>
																<xsl:with-param name="aos3Parent" select="$aos3Parent"/>
															</xsl:call-template>
														</xsl:when>
														<xsl:otherwise>
															<xsl:call-template name="doImplementType">
																<xsl:with-param name="thisType" select="@type"/>
																<xsl:with-param name="currPath" select="concat($currPath,'/',@name)"/>
																<xsl:with-param name="currPath_doc" select="concat($currPath_doc,'/',@name,'(i',$aosLevel,')')"/>
																<xsl:with-param name="aosLevel" select="$aosLevel+1"/>
																<xsl:with-param name="aos3Parent" select="$aos3Parent"/>
															</xsl:call-template>
														</xsl:otherwise>
													</xsl:choose>
												</xsl:when>
												<xsl:otherwise>
													<xsl:call-template name="doImplementType">
														<xsl:with-param name="thisType" select="@type"/>
														<xsl:with-param name="currPath" select="concat($currPath,'/',@name)"/>
														<xsl:with-param name="currPath_doc" select="concat($currPath_doc,'/',@name)"/>
														<xsl:with-param name="aosLevel" select="$aosLevel"/>
														<xsl:with-param name="aos3Parent" select="$aos3Parent"/>
													</xsl:call-template>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:otherwise>
									</xsl:choose>
								</field>
							</xsl:when>
							<xsl:otherwise>
								<!-- It is a complexType -->
								<field>
									<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
									<xsl:attribute name="structure_reference"><xsl:value-of select="$structure_reference"/></xsl:attribute>
									<xsl:choose>
										<xsl:when test="$currPath=''">
											<xsl:attribute name="path"><xsl:value-of select="@name"/></xsl:attribute>
											<xsl:attribute name="path_doc"><xsl:value-of select="@name"/></xsl:attribute>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="path"><xsl:value-of select="concat($currPath,'/',@name)"/></xsl:attribute>
											<xsl:attribute name="path_doc"><xsl:value-of select="concat($currPath_doc,'/',@name)"/></xsl:attribute>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:attribute name="documentation"><xsl:value-of select="xs:annotation/xs:documentation"/></xsl:attribute>
									<xsl:choose>
										<!-- It is an array of structures -->
										<xsl:when test="@maxOccurs='unbounded' or @maxOccurs &gt; 1">
											<xsl:attribute name="data_type">struct_array</xsl:attribute>
											<xsl:attribute name="maxoccur"><xsl:value-of select="@maxOccurs"/></xsl:attribute>
											<xsl:if test="xs:annotation/xs:appinfo/coordinate1">
												<xsl:attribute name="coordinate1"><xsl:value-of select="xs:annotation/xs:appinfo/coordinate1"/></xsl:attribute>
											</xsl:if>
										</xsl:when>
										<!-- It is a regular structure -->
										<xsl:otherwise>
											<xsl:attribute name="data_type">structure</xsl:attribute>
											<!-- TREAT HERE THE CASE OF DIRECT BRANCHING OF A GROUP BELOW A STRUCTURE, OCCURS FOR SOME SIGNALS, NEED TO ADD A DATA CHILD -->
											<xsl:if test="xs:complexType/xs:sequence/xs:group">
												<field>
													<xsl:attribute name="name">data</xsl:attribute>
													<xsl:choose>
														<xsl:when test="$currPath=''">
															<xsl:attribute name="path"><xsl:value-of select="concat(@name,'/data')"/></xsl:attribute>
															<xsl:attribute name="path_doc"><xsl:value-of select="concat(@name,'/data')"/><xsl:call-template name="AddToPathDoc"><xsl:with-param name="data_type" select="xs:complexType/xs:sequence/xs:group/@ref"/></xsl:call-template></xsl:attribute>
														</xsl:when>
														<xsl:otherwise>
															<xsl:attribute name="path"><xsl:value-of select="concat($currPath,'/',@name,'/data')"/></xsl:attribute>
															<xsl:attribute name="path_doc"><xsl:value-of select="concat($currPath_doc,'/',@name,'/data')"/><xsl:call-template name="AddToPathDoc"><xsl:with-param name="data_type" select="xs:complexType/xs:sequence/xs:group/@ref"/></xsl:call-template></xsl:attribute>
														</xsl:otherwise>
													</xsl:choose>
													<xsl:attribute name="documentation"><xsl:value-of select="xs:annotation/xs:documentation"/></xsl:attribute>
													<xsl:attribute name="data_type"><xsl:value-of select="xs:complexType/xs:sequence/xs:group/@ref"/></xsl:attribute>
													<xsl:for-each select="xs:annotation/xs:appinfo/*">
														<!-- Generic method for declaring all appinfo as attributes-->
														<xsl:attribute name="{lower-case(name(.))}"><xsl:choose><xsl:when test="contains(lower-case(name(.)),'coordinate')"><xsl:choose><xsl:when test="$currPath=''"><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat(../../../@name,'/data')"/><xsl:with-param name="coordinatePath" select="concat('../',.)"/></xsl:call-template></xsl:when><xsl:otherwise><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat($currPath_doc,'/',../../../@name,'/data')"/><xsl:with-param name="coordinatePath" select="concat('../',.)"/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:when><xsl:otherwise><xsl:value-of select="."/></xsl:otherwise></xsl:choose></xsl:attribute>
														<!-- We just add ../ to all coordinates since their are viewed from the data node, one level below the original parent <xsl:value-of select="."/></xsl:attribute>-->
													</xsl:for-each>
												</field>
												<!-- Then we test if the type is real or complex, if so add *_error nodes to the structure for the errorbars -->
												<xsl:if test="(contains(xs:complexType/xs:sequence/xs:group/@ref,'FLT') or contains(xs:complexType/xs:sequence/xs:group/@ref,'CPX')) and not(contains(@name,'_limit_'))">
													<field>
														<!-- _error_upper field -->
														<xsl:attribute name="name"><xsl:value-of select="'data_error_upper'"/></xsl:attribute>
														<xsl:choose>
															<xsl:when test="$currPath=''">
																<xsl:attribute name="path"><xsl:value-of select="concat(@name,'/data_error_upper')"/></xsl:attribute>
																<xsl:attribute name="path_doc"><xsl:value-of select="concat(@name,'/data_error_upper')"/><xsl:call-template name="AddToPathDoc"><xsl:with-param name="data_type" select="xs:complexType/xs:sequence/xs:group/@ref"/></xsl:call-template></xsl:attribute>
															</xsl:when>
															<xsl:otherwise>
																<xsl:attribute name="path"><xsl:value-of select="concat($currPath,'/',@name,'/data_error_upper')"/></xsl:attribute>
																<xsl:attribute name="path_doc"><xsl:value-of select="concat($currPath_doc,'/',@name,'/data_error_upper')"/><xsl:call-template name="AddToPathDoc"><xsl:with-param name="data_type" select="xs:complexType/xs:sequence/xs:group/@ref"/></xsl:call-template></xsl:attribute>
															</xsl:otherwise>
														</xsl:choose>
														<xsl:attribute name="documentation">Upper error for &quot;data&quot;</xsl:attribute>
														<xsl:attribute name="data_type"><xsl:value-of select="xs:complexType/xs:sequence/xs:group/@ref"/></xsl:attribute>
														<xsl:for-each select="xs:annotation/xs:appinfo/*">
															<!-- Generic method for declaring all appinfo as attributes-->
															<xsl:attribute name="{lower-case(name(.))}"><xsl:choose><xsl:when test="contains(lower-case(name(.)),'coordinate')"><xsl:choose><xsl:when test="$currPath=''"><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat(../../../@name,'/data')"/><xsl:with-param name="coordinatePath" select="concat('../',.)"/></xsl:call-template></xsl:when><xsl:when test="contains(name(.),'change_nbc_previous_name')"><xsl:value-of select="."/><xsl:value-of select="'_error_upper'"/></xsl:when><xsl:otherwise><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat($currPath_doc,'/',../../../@name,'/data')"/><xsl:with-param name="coordinatePath" select="concat('../',.)"/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:when><xsl:otherwise><xsl:value-of select="."/></xsl:otherwise></xsl:choose></xsl:attribute>
															<!-- We just add ../ to all coordinates since their are viewed from the data node, one level below the original parent <xsl:value-of select="."/></xsl:attribute>-->
														</xsl:for-each>
													</field>
													<field>
														<!-- _error_lower field -->
														<xsl:attribute name="name"><xsl:value-of select="'data_error_lower'"/></xsl:attribute>
														<xsl:choose>
															<xsl:when test="$currPath=''">
																<xsl:attribute name="path"><xsl:value-of select="concat(@name,'/data_error_lower')"/></xsl:attribute>
																<xsl:attribute name="path_doc"><xsl:value-of select="concat(@name,'/data_error_lower')"/><xsl:call-template name="AddToPathDoc"><xsl:with-param name="data_type" select="xs:complexType/xs:sequence/xs:group/@ref"/></xsl:call-template></xsl:attribute>
															</xsl:when>
															<xsl:otherwise>
																<xsl:attribute name="path"><xsl:value-of select="concat($currPath,'/',@name,'/data_error_lower')"/></xsl:attribute>
																<xsl:attribute name="path_doc"><xsl:value-of select="concat($currPath_doc,'/',@name,'/data_error_lower')"/><xsl:call-template name="AddToPathDoc"><xsl:with-param name="data_type" select="xs:complexType/xs:sequence/xs:group/@ref"/></xsl:call-template></xsl:attribute>
															</xsl:otherwise>
														</xsl:choose>
														<xsl:attribute name="documentation">Lower error for &quot;data&quot;</xsl:attribute>
														<xsl:attribute name="data_type"><xsl:value-of select="xs:complexType/xs:sequence/xs:group/@ref"/></xsl:attribute>
														<xsl:for-each select="xs:annotation/xs:appinfo/*">
															<!-- Generic method for declaring all appinfo as attributes-->
															<xsl:attribute name="{lower-case(name(.))}"><xsl:choose><xsl:when test="contains(lower-case(name(.)),'coordinate')"><xsl:choose><xsl:when test="$currPath=''"><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat(../../../@name,'/data')"/><xsl:with-param name="coordinatePath" select="concat('../',.)"/></xsl:call-template></xsl:when><xsl:when test="contains(name(.),'change_nbc_previous_name')"><xsl:value-of select="."/><xsl:value-of select="'_error_lower'"/></xsl:when><xsl:otherwise><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat($currPath_doc,'/',../../../@name,'/data')"/><xsl:with-param name="coordinatePath" select="concat('../',.)"/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:when><xsl:otherwise><xsl:value-of select="."/></xsl:otherwise></xsl:choose></xsl:attribute>
															<!-- We just add ../ to all coordinates since their are viewed from the data node, one level below the original parent <xsl:value-of select="."/></xsl:attribute>-->
														</xsl:for-each>
													</field>
													<field>
														<!-- _error_index field -->
														<xsl:attribute name="name">data_error_index</xsl:attribute>
														<xsl:attribute name="lifecycle_status">obsolescent</xsl:attribute>
														<xsl:attribute name="lifecycle_version">3.38.1</xsl:attribute>
														<xsl:choose>
															<xsl:when test="$currPath=''">
																<xsl:attribute name="path"><xsl:value-of select="concat(@name,'/data_error_index')"/></xsl:attribute>
																<xsl:attribute name="path_doc"><xsl:value-of select="concat(@name,'/data_error_index')"/></xsl:attribute>
															</xsl:when>
															<xsl:otherwise>
																<xsl:attribute name="path"><xsl:value-of select="concat($currPath,'/',@name,'/data_error_index')"/></xsl:attribute>
																<xsl:attribute name="path_doc"><xsl:value-of select="concat($currPath_doc,'/',@name,'/data_error_index')"/></xsl:attribute>
															</xsl:otherwise>
														</xsl:choose>
														<xsl:attribute name="documentation">Index in the error_description list for &quot;data&quot;</xsl:attribute>
														<xsl:attribute name="data_type">int_type</xsl:attribute>
														<xsl:attribute name="type">constant</xsl:attribute>	
														<xsl:if test="contains(./xs:annotation/xs:appinfo/change_nbc_description,'leaf_renamed')">
                                        <xsl:attribute name="change_nbc_version"><xsl:value-of select="./xs:annotation/xs:appinfo/change_nbc_version"/></xsl:attribute>	                                     
                                         <xsl:attribute name="change_nbc_description"><xsl:value-of select="./xs:annotation/xs:appinfo/change_nbc_description"/></xsl:attribute>	
                                        <xsl:attribute name="change_nbc_previous_name"><xsl:value-of select="concat(./xs:annotation/xs:appinfo/change_nbc_previous_name,'_error_index')"/></xsl:attribute>	   
								   </xsl:if>																	
													</field>
												</xsl:if>
											</xsl:if>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:choose>
										<xsl:when test="$currPath=''">
											<xsl:apply-templates select="*/*/xs:element" mode="IMPLEMENT">
												<xsl:with-param name="currPath" select="@name"/>
												<xsl:with-param name="currPath_doc" select="@name"/>
												<xsl:with-param name="aosLevel" select="$aosLevel"/>
												<xsl:with-param name="aos3Parent" select="$aos3Parent"/>
											</xsl:apply-templates>
										</xsl:when>
										<xsl:otherwise>
											<xsl:apply-templates select="*/*/xs:element" mode="IMPLEMENT">
												<xsl:with-param name="currPath" select="concat($currPath, '/',@name)"/>
												<xsl:with-param name="currPath_doc" select="concat($currPath_doc, '/',@name)"/>
												<xsl:with-param name="aosLevel" select="$aosLevel"/>
												<xsl:with-param name="aos3Parent" select="$aos3Parent"/>
											</xsl:apply-templates>
										</xsl:otherwise>
									</xsl:choose>
								</field>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!--Scan references in DECLARE mode-->
	<xsl:template name="doRefDeclare">
		<xsl:param name="thisRef"/>
		<xsl:param name="maxOcc"/>
		<xsl:apply-templates select="/*/xs:include" mode="DECLARE">
			<xsl:with-param name="actRef" select="$thisRef"/>
			<xsl:with-param name="maxOcc" select="$maxOcc"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="document('utilities/dd_support.xsd')/*/xs:element[@name=$thisRef]" mode="DECLARE"/>
	</xsl:template>
	<xsl:template match="xs:include" mode="DECLARE">
		<xsl:param name="actRef"/>
		<xsl:param name="maxOcc"/>
		<xsl:apply-templates select="document(@schemaLocation)/*/xs:element[@name=$actRef]" mode="DECLARE">
			<xsl:with-param name="currPath" select="''"/>
			<xsl:with-param name="currPath_doc" select="''"/>
			<xsl:with-param name="maxOcc" select="$maxOcc"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template name="doRefImplement">
		<xsl:param name="thisRef"/>
		<xsl:param name="currPath"/>
		<xsl:param name="currPath_doc"/>
		<xsl:param name="aosLevel"/>
		<xsl:choose>
			<xsl:when test="document('utilities/dd_support.xsd')/*/xs:complexType[@name=$thisRef]">
				when the reference to be included is a complexType defined in utilities : NEVER HAPPENS
				CHECK RESULT HERE IF THIS APPEARS
				<xsl:apply-templates select="document('utilities.xsd')/*/xs:complexType[@name=$thisRef]" mode="IMPLEMENT">
					<xsl:with-param name="currPath" select="$currPath"/>
					<xsl:with-param name="currPath_doc" select="$currPath_doc"/>
					<xsl:with-param name="aosLevel" select="$aosLevel"/>
					<xsl:with-param name="parentmachine" select="yes"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="document('utilities/dd_support.xsd')/*/xs:element[@name=$thisRef]">
				<!-- when the reference to be included is an element defined in utilities -->
				<xsl:apply-templates select="document('utilities/dd_support.xsd')/*/xs:element[@name=$thisRef]" mode="IMPLEMENT">
					<xsl:with-param name="currPath" select="$currPath"/>
					<xsl:with-param name="currPath_doc" select="$currPath_doc"/>
					<xsl:with-param name="aosLevel" select="$aosLevel"/>
					<xsl:with-param name="structure_reference" select="$thisRef"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<!-- when the reference to be included is a whole additional xsd file -->
				<xsl:apply-templates select="/*/xs:include" mode="IMPLEMENT">
					<xsl:with-param name="actRef" select="$thisRef"/>
					<xsl:with-param name="currPath" select="$currPath"/>
					<xsl:with-param name="currPath_doc" select="$currPath_doc"/>
					<xsl:with-param name="aosLevel" select="$aosLevel"/>
					<xsl:with-param name="structure_reference" select="$thisRef"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="doImplementType">
		<xsl:param name="thisType"/>
		<xsl:param name="currPath"/>
		<xsl:param name="currPath_doc"/>
		<xsl:param name="aosLevel"/>
		<xsl:param name="aos3Parent"/>
		<xsl:param name="parentmachine"/>
		<xsl:param name="parenttime"/>
		<xsl:param name="structure_reference"/>
		<xsl:choose>
			<!-- for some of the complex Types, the time-dependence and machine description properties are defined by their parents -->
			<!-- in the schemas, this property is flagged by <xs:appinfo>parent-dependent</xs:appinfo> -->
			<!-- this is checked now, and  this information is passed using the parentmachine and parenttime parameters to the IMPLEMENT templates -->
			<!-- some draft of the parentunit information is done here ... not sure it is reliable yet for the units !! (used by ISE only for the moment) -->
			<xsl:when test="document('utilities/dd_support.xsd')/*/xs:complexType[@name=$thisType]">
				<!-- if the complexType definition is in Utilities-->
				<xsl:choose>
					<xsl:when test="contains(string(document('utilities/dd_support.xsd')/*/xs:complexType[@name=$thisType]/xs:annotation/xs:appinfo), 'parent-dependent')">
						<xsl:choose>
							<xsl:when test="contains(string(xs:annotation/xs:appinfo), 'machine description')">
								<xsl:choose>
									<xsl:when test="contains(string(xs:annotation/xs:documentation), 'Time-dependent')">
										<xsl:apply-templates select="document('utilities/dd_support.xsd')/*/xs:complexType[@name=$thisType]" mode="IMPLEMENT">
											<!--This fills the complexType from its definition in utilities (if it is there and not in the local schema)-->
											<xsl:with-param name="currPath" select="$currPath"/>
											<xsl:with-param name="currPath_doc" select="$currPath_doc"/>
											<xsl:with-param name="aosLevel" select="$aosLevel"/>
											<xsl:with-param name="parentmachine" select="'yes'"/>
											<xsl:with-param name="parenttime" select="'yes'"/>
											<xsl:with-param name="parentunit" select="substring-before(substring-after(string(xs:annotation/xs:documentation),'['),']')"/>
										</xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="document('utilities/dd_support.xsd')/*/xs:complexType[@name=$thisType]" mode="IMPLEMENT">
											<!--This fills the complexType from its definition in utilities (if it is there and not in the local schema)-->
											<xsl:with-param name="currPath" select="$currPath"/>
											<xsl:with-param name="currPath_doc" select="$currPath_doc"/>
											<xsl:with-param name="aosLevel" select="$aosLevel"/>
											<xsl:with-param name="parentmachine" select="'yes'"/>
											<xsl:with-param name="parentunit" select="substring-before(substring-after(string(xs:annotation/xs:documentation),'['),']')"/>
										</xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="contains(string(xs:annotation/xs:documentation), 'Time-dependent')">
										<xsl:apply-templates select="document('utilities/dd_support.xsd')/*/xs:complexType[@name=$thisType]" mode="IMPLEMENT">
											<!--This fills the complexType from its definition in utilities (if it is there and not in the local schema)-->
											<xsl:with-param name="currPath" select="$currPath"/>
											<xsl:with-param name="currPath_doc" select="$currPath_doc"/>
											<xsl:with-param name="aosLevel" select="$aosLevel"/>
											<xsl:with-param name="parenttime" select="'yes'"/>
											<xsl:with-param name="parentunit" select="substring-before(substring-after(string(xs:annotation/xs:documentation),'['),']')"/>
										</xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="document('utilities/dd_support.xsd')/*/xs:complexType[@name=$thisType]" mode="IMPLEMENT">
											<!--This fills the complexType from its definition in utilities (if it is there and not in the local schema)-->
											<xsl:with-param name="currPath" select="$currPath"/>
											<xsl:with-param name="currPath_doc" select="$currPath_doc"/>
											<xsl:with-param name="aosLevel" select="$aosLevel"/>
											<xsl:with-param name="parentunit" select="substring-before(substring-after(string(xs:annotation/xs:documentation),'['),']')"/>
										</xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<!-- No need to collect the information about the parents -->
						<!-- Just check whether the data is an experimental data type (has an implication for exp2ITM) -->
						<xsl:choose>
							<xsl:when test="$thisType='exp0D' or $thisType='exp1D' or $thisType='exp2D'">
								<xsl:apply-templates select="document('utilities/dd_support.xsd')/*/xs:complexType[@name=$thisType]" mode="IMPLEMENT">
									<!--This fills the complexType from its definition in utilities (if it is there and not in the local schema)-->
									<xsl:with-param name="currPath" select="$currPath"/>
									<xsl:with-param name="currPath_doc" select="$currPath_doc"/>
									<xsl:with-param name="aosLevel" select="$aosLevel"/>
									<xsl:with-param name="parentunit" select="substring-before(substring-after(string(xs:annotation/xs:documentation),'['),']')"/>
									<xsl:with-param name="experimental" select="$thisType"/>
								</xsl:apply-templates>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="document('utilities/dd_support.xsd')/*/xs:complexType[@name=$thisType]" mode="IMPLEMENT">
									<!--This fills the complexType from its definition in utilities (if it is there and not in the local schema)-->
									<xsl:with-param name="currPath" select="$currPath"/>
									<xsl:with-param name="currPath_doc" select="$currPath_doc"/>
									<xsl:with-param name="aosLevel" select="$aosLevel"/>
									<xsl:with-param name="aos3Parent" select="$aos3Parent"/>
									<xsl:with-param name="structure_reference" select="$structure_reference"/>																		
									<xsl:with-param name="parentunit" select="substring-before(substring-after(string(xs:annotation/xs:documentation),'['),']')"/>
								</xsl:apply-templates>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="/*/xs:complexType[@name=$thisType]">
				<!-- the definition of the Type is directly in the local schema -->
				<xsl:choose>
					<xsl:when test="contains(string(/*/xs:complexType[@name=$thisType]/xs:annotation/xs:appinfo), 'parent-dependent')">
						<xsl:choose>
							<xsl:when test="contains(string(xs:annotation/xs:appinfo), 'machine description')">
								<xsl:choose>
									<xsl:when test="contains(string(xs:annotation/xs:documentation), 'Time-dependent')">
										<xsl:apply-templates select="/*/xs:complexType[@name=$thisType]" mode="IMPLEMENT">
											<!--This fills the complexType from its definition in utilities (if it is there and not in the local schema)-->
											<xsl:with-param name="currPath" select="$currPath"/>
											<xsl:with-param name="currPath_doc" select="$currPath_doc"/>
											<xsl:with-param name="aosLevel" select="$aosLevel"/>
											<xsl:with-param name="aos3Parent" select="$aos3Parent"/>									
											<xsl:with-param name="parentmachine" select="'yes'"/>
											<xsl:with-param name="parenttime" select="'yes'"/>
											<xsl:with-param name="parentunit" select="substring-before(substring-after(string(xs:annotation/xs:documentation),'['),']')"/>
										</xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="/*/xs:complexType[@name=$thisType]" mode="IMPLEMENT">
											<xsl:with-param name="currPath" select="$currPath"/>
											<xsl:with-param name="currPath_doc" select="$currPath_doc"/>
											<xsl:with-param name="aosLevel" select="$aosLevel"/>
											<xsl:with-param name="aos3Parent" select="$aos3Parent"/>									
											<xsl:with-param name="parentmachine" select="'yes'"/>
											<xsl:with-param name="parentunit" select="substring-before(substring-after(string(xs:annotation/xs:documentation),'['),']')"/>
										</xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="contains(string(xs:annotation/xs:documentation), 'Time-dependent')">
										<xsl:apply-templates select="/*/xs:complexType[@name=$thisType]" mode="IMPLEMENT">
											<!--This fills the complexType from its definition in utilities (if it is there and not in the local schema)-->
											<xsl:with-param name="currPath" select="$currPath"/>
											<xsl:with-param name="currPath_doc" select="$currPath_doc"/>
											<xsl:with-param name="aosLevel" select="$aosLevel"/>
   									        <xsl:with-param name="aos3Parent" select="$aos3Parent"/>									
											<xsl:with-param name="parenttime" select="'yes'"/>
											<xsl:with-param name="parentunit" select="substring-before(substring-after(string(xs:annotation/xs:documentation),'['),']')"/>
										</xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="/*/xs:complexType[@name=$thisType]" mode="IMPLEMENT">
											<xsl:with-param name="currPath" select="$currPath"/>
											<xsl:with-param name="currPath_doc" select="$currPath_doc"/>
											<xsl:with-param name="aosLevel" select="$aosLevel"/>
											<xsl:with-param name="aos3Parent" select="$aos3Parent"/>									
											<xsl:with-param name="parentunit" select="substring-before(substring-after(string(xs:annotation/xs:documentation),'['),']')"/>
										</xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<!-- No need to collect the information about the parents -->
						<xsl:apply-templates select="/*/xs:complexType[@name=$thisType]" mode="IMPLEMENT">
							<xsl:with-param name="currPath" select="$currPath"/>
							<xsl:with-param name="currPath_doc" select="$currPath_doc"/>
							<xsl:with-param name="aosLevel" select="$aosLevel"/>
							<xsl:with-param name="aos3Parent" select="$aos3Parent"/>									
							<xsl:with-param name="parentunit" select="substring-before(substring-after(string(xs:annotation/xs:documentation),'['),']')"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>		
			<xsl:otherwise>
				<xsl:for-each select="/*/xs:include[not(contains(@schemaLocation,'utilities'))]">
					<!-- Complex Type not yet found, need to scan other included schemas -->
					<!-- FOUND INCLUDE <xsl:value-of select="@schemaLocation"/> -->
						<xsl:if test="document(@schemaLocation)/*/xs:complexType[@name=$thisType]">
							<!-- FOUND ELEMENT <xsl:value-of select="$thisType"/> -->
							<xsl:apply-templates select="document(@schemaLocation)/*/xs:complexType[@name=$thisType]" mode="IMPLEMENT">
								<!--This fills the complexType from its definition in the included schema (if it is there and not in the local schema, neither in utilities)-->
								<xsl:with-param name="currPath" select="$currPath"/>
								<xsl:with-param name="currPath_doc" select="$currPath_doc"/>
								<xsl:with-param name="aosLevel" select="$aosLevel"/>
								<xsl:with-param name="aos3Parent" select="$aos3Parent"/>									
							</xsl:apply-templates>
						</xsl:if>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Template to write the aosIndex to the path_doc attribute-->
	<xsl:template name="aosIndex">
		<xsl:param name="aosLevel"/>
		<xsl:choose>
			<xsl:when test="xs:annotation/xs:appinfo/type='dynamic'">(itime)</xsl:when>
			<xsl:otherwise>(i<xsl:value-of select="$aosLevel"/>)</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Below is the template dedicated to building absolute Path from the relative path, for the coordinate attributes-->
	<xsl:template name="BuildAbsolutePath">
		<xsl:param name="coordinate"/>
		<xsl:param name="currPath"/>
		<xsl:param name="coordinatePath"/>
		<xsl:choose>
     		<xsl:when test="starts-with($coordinatePath,'/')">
		       <!-- Case of a coordinate path expressed relative to the IDS root or nearest AoS parent (special case for the utilities section, e.g. /time). We then just get rid of the initial slash for the absolute coordinate attribute (to avoid users having to learn this initial / convention) -->
		       <xsl:value-of select="substring($coordinatePath,2)"/>  
		    </xsl:when>
			<xsl:when test="contains($coordinatePath,'...')">
				<!-- Case of a main coordinate, e.g. 1...N just reproduce it in the tag although remove any '../' at the beginning that could happen in case of a DATA/TIME construct -->
				<xsl:value-of select="replace($coordinatePath,'../','')"/>
			</xsl:when>
			<xsl:when test="contains($coordinatePath,'IDS')">
				<!-- Case of a coordinate in another IDS. In this case, absolute path is given, just reproduce it in the tag -->
				<xsl:value-of select="$coordinatePath"/>
			</xsl:when>
			<xsl:when test="contains($coordinatePath,' OR ')">
				<!-- Case of multiple possible coordinate nodes (maximum 2 OR statements considered) -->
				<xsl:choose>
                   <xsl:when test="contains(substring-after($coordinatePath,' OR '),' OR ')">
                        <xsl:value-of select="concat(local:getAbsolutePath(concat($currPath,'/',substring-before($coordinatePath,' OR '))),' OR ',local:getAbsolutePath(concat($currPath,'/',substring-before(substring-after($coordinatePath,' OR '),' OR '))),' OR ', local:getAbsolutePath(concat($currPath,'/',substring-after(substring-after($coordinatePath,' OR '),' OR '))))"/>
                   </xsl:when>
                   <xsl:otherwise>
  				        <xsl:value-of select="concat(local:getAbsolutePath(concat($currPath,'/',substring-before($coordinatePath,' OR '))),' OR ',local:getAbsolutePath(concat($currPath,'/',substring-after($coordinatePath,' OR '))))"/>             
                   </xsl:otherwise>				
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="contains($coordinatePath,'../')">
						<xsl:value-of select="local:getAbsolutePath(concat($currPath,'/',$coordinatePath))"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat($currPath,'/',$coordinatePath)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Template dedicated to building relative Path from the nearest static AoS parent, to calculate the time coordinate relative path for the new low level. It first calculates the absolute path of the coordinate, exactly as done in the BuildAbsolutePath template, then extracts the substring after the last AoS parent (detected thanks to aosLevel param) -->
		<!-- NB does handle the detection of (itime) in case of a dynamic AoS parent, but this attribute will anyway not be used in this case because there is no need to specify a time coordinate ! -->
	<xsl:template name="BuildRelativeAosParentPath">
		<xsl:param name="coordinate"/>
		<xsl:param name="currPath"/>
		<xsl:param name="coordinatePath"/>
		<xsl:param name="aosLevel"/>
		<xsl:param name="structure_reference"/>
		<xsl:param name="utilities_aoscontext"/>
		<xsl:choose>
		      <xsl:when test="starts-with($coordinatePath,'/')">
		       <!-- Case of a coordinate path expressed relative to the IDS root (special case needed for the utilities section but also directly understandable in the main IDS section by the Low Level, e.g. /time). We then keep the initial slash and display it as it is, the AL will know how to interpret it -->
		       <xsl:value-of select="$coordinatePath"/>  
		    </xsl:when>
			<xsl:when test="contains($coordinatePath,'...')">
				<!-- Case of a main coordinate, e.g. 1...N just reproduce it in the tag although remove any '../' at the beginning that could happen in case of a DATA/TIME construct -->
				<xsl:value-of select="replace($coordinatePath,'../','')"/>
			</xsl:when>
			<xsl:when test="contains($coordinatePath,'IDS')">
				<!-- Case of a coordinate in another IDS. In this case, absolute path is given, just reproduce it in the tag -->
				<xsl:value-of select="$coordinatePath"/>
			</xsl:when>
			<xsl:when test="contains($currPath,'(i1)')">
			    <!-- There is at least one static AoS ancestor, process the path to make it relative to the nearest one -->
				<xsl:choose>
					<xsl:when test="contains($coordinatePath,'../')">
						<xsl:value-of select="substring-after(local:getAbsolutePath(concat($currPath,'/',$coordinatePath)),concat('(i',$aosLevel,')/'))"/>
					</xsl:when>
					<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="$coordinatePath"> <!--if coordinatePath is not empty-->
						    <xsl:value-of select="substring-after(concat($currPath,'/',$coordinatePath),concat('(i',$aosLevel,')/'))"/>
						</xsl:when>
						<xsl:otherwise>  
							<xsl:value-of select="substring-after($currPath,concat('(i',$aosLevel,')/'))"/>
						</xsl:otherwise>
						</xsl:choose>		
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
			<!-- Case with no static AoS ancestor, simply calculate the absolute path as in the BuilAbsolutePath template -->
                <xsl:choose>
                    <xsl:when test="contains($structure_reference,'self')">
                	       <!-- Case of a coordinate path expressed relative to the root of the utilities complexType or element (special case for the utilities section). We then keep the initial anti-slash in the utilities section only and display it as it is, the AL will transform it properly -->
                    		<xsl:choose>
						    <xsl:when test="$coordinatePath and $utilities_aoscontext"> <!--if coordinatePath and utilities_aoscontext are not empty. Case of a relative path going above the top of the utilities complex Type, in such case we assume that the path is valid wrt the parent aos root and thus we don't add the \, even for utilities (the AL will handle it with the AoS context) -->
						    <xsl:value-of select="local:getAbsolutePath($coordinatePath)"/>
						    </xsl:when>
						    <xsl:when test="$coordinatePath"> <!--if coordinatePath is not empty-->
						    <xsl:value-of select="concat('\',local:getAbsolutePath($coordinatePath))"/>
						    </xsl:when>
						    <xsl:otherwise> <!--Then it is a time array itself arriving with the information in $currPath in utilities (this may be a specific processing but should be the only case -->
						    <xsl:value-of select="concat('\',$currPath)"/>
						    </xsl:otherwise>
						    </xsl:choose>
                    </xsl:when>
					<xsl:when test="contains($coordinatePath,'../')">
						<xsl:value-of select="local:getAbsolutePath(concat($currPath,'/',$coordinatePath))"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
						<xsl:when test="$coordinatePath"> <!--if coordinatePath is not empty-->
						    <xsl:value-of select="concat($currPath,'/',$coordinatePath)"/>
						</xsl:when>
						<xsl:otherwise>  
							 <xsl:value-of select="$currPath"/>
						</xsl:otherwise>
						</xsl:choose>					
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Adding parenthesis at the end of path_doc as a function of the number of dimensions -->
	<xsl:template name="AddToPathDoc">
		<xsl:param name="data_type"/>
		<xsl:choose>
			<xsl:when test="contains($data_type,'1d') or contains($data_type,'1D')">(:)</xsl:when>
			<xsl:when test="contains($data_type,'2d') or contains($data_type,'2D')">(:,:)</xsl:when>
			<xsl:when test="contains($data_type,'3d') or contains($data_type,'3D')">(:,:,:)</xsl:when>
			<xsl:when test="contains($data_type,'4d') or contains($data_type,'4D')">(:,:,:,:)</xsl:when>
			<xsl:when test="contains($data_type,'5d') or contains($data_type,'5D')">(:,:,:,:,:)</xsl:when>
			<xsl:when test="contains($data_type,'6d') or contains($data_type,'6D')">(:,:,:,:,:,:)</xsl:when>
		</xsl:choose>
	</xsl:template>			
</xsl:stylesheet>
