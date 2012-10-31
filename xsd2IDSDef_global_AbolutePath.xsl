<?xml version="1.0" encoding="UTF-8"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./%24GET%5Bstylesheet%5D" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>
<xsl:stylesheet xmlns:yaslt="http://www.mod-xslt2.com/ns/2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" extension-element-prefixes="yaslt" xmlns:fn="http://www.w3.org/2005/02/xpath-functions" xmlns:local="http://www.example.com/functions/local" exclude-result-prefixes="local xs">
	<!-- -->
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!-- This script transforms the collection of XSD files forming the Data Dictionary into a single XML file describing explicitly all nodes with their characteristics-->
	<!-- The resulting XML file makes further work on the data dictionary much easier, since it describes explicitely the whole schema (includes and references are solved) -->
	<!-- Author:F. Imbeaux, CEA, adapted from xsd2CPODef7 of EU-ITM -->
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
	<!-- Scan for top-level elements -->
	<xsl:template match="/*">
		<IDSs>
			<xsl:apply-templates select="*/*/*/xs:element" mode="DECLARE">
				<xsl:with-param name="currPath" select="''"/>
				<xsl:with-param name="maxOcc" select="''"/>
			</xsl:apply-templates>
		</IDSs>
	</xsl:template>
	<xsl:template match="xs:element" mode="DECLARE">
		<xsl:param name="currPath"/>
		<xsl:param name="maxOcc"/>
		<xsl:choose>
			<xsl:when test="@name">
				<xsl:choose>
					<!-- If it is declared as a IDS -->
					<xsl:when test="*/*/xs:element[@ref='IDS_Properties']">
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
							<!-- Scan its components in IMPLEMENT mode -->
							<xsl:apply-templates select="xs:complexType" mode="IMPLEMENT">
								<xsl:with-param name="currPath" select="''"/>
							</xsl:apply-templates>
							<xsl:choose>
								<xsl:when test="@name and @type">
									<xsl:call-template name="doImplementType">
										<xsl:with-param name="thisType" select="@type"/>
										<xsl:with-param name="currPath" select="''"/>
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
		<xsl:apply-templates select="document(@schemaLocation)/*/xs:element[@name=$actRef]" mode="IMPLEMENT">
			<xsl:with-param name="currPath" select="$currPath"/>
		</xsl:apply-templates>
	</xsl:template>
	<!-- Handle ComplexType definition in IMPLEMENT mode -->
	<xsl:template match="xs:complexType" mode="IMPLEMENT">
		<xsl:param name="currPath"/>
		<xsl:param name="parentmachine"/>
		<xsl:param name="parenttime"/>
		<xsl:param name="parentunit"/>
		<xsl:param name="experimental"/>
		<!-- Treat here the representation attributes for a ComplexType structure-->
		<xsl:apply-templates select="xs:annotation/xs:appinfo[contains(string(.),'representation')]">
			<xsl:with-param name="currPath" select="$currPath"/>
			<xsl:with-param name="relPath" select="'yes'"/>
		</xsl:apply-templates>
		<!-- Start implementing all child elements of the complexType -->
		<xsl:apply-templates select="*/xs:element" mode="IMPLEMENT">
			<xsl:with-param name="currPath" select="$currPath"/>
			<xsl:with-param name="parentmachine" select="$parentmachine"/>
			<xsl:with-param name="parenttime" select="$parenttime"/>
			<xsl:with-param name="parentunit" select="$parentunit"/>
			<xsl:with-param name="experimental" select="$experimental"/>
		</xsl:apply-templates>
	</xsl:template>
	<!-- Handle element definition in implement mode. Here all data types are checked -->
	<xsl:template match="xs:element" mode="IMPLEMENT">
		<xsl:param name="currPath"/>
		<xsl:param name="parentmachine"/>
		<xsl:param name="parenttime"/>
		<xsl:param name="parentunit"/>
		<xsl:param name="experimental"/>
		<xsl:choose>
			<!-- If it is an external reference -->
			<xsl:when test="@ref">
				<xsl:call-template name="doRefImplement">
					<xsl:with-param name="thisRef" select="@ref"/>
					<xsl:with-param name="currPath" select="$currPath"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="@name">
				<xsl:choose>
					<!-- if the node is a leaf defined as a simple type -->
					<xsl:when test="@type='int_type' or @type='flt_type'  or @type='str_type' or @type='flt_1d_type'">
						<field>
							<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
							<xsl:choose>
								<xsl:when test="$currPath=''">
									<xsl:attribute name="path"><xsl:value-of select="@name"/></xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="path"><xsl:value-of select="concat($currPath,'/',@name)"/></xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:attribute name="documentation"><xsl:value-of select="xs:annotation/xs:documentation"/></xsl:attribute>
							<xsl:attribute name="data_type"><xsl:value-of select="@type"/></xsl:attribute>
							<xsl:for-each select="xs:annotation/xs:appinfo/*">
								<!-- Generic method for declaring all appinfo as attributes-->
								<xsl:attribute name="{name(.)}"><xsl:value-of select="."/></xsl:attribute>
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
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="path"><xsl:value-of select="concat($currPath,'/',@name)"/></xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:attribute name="documentation"><xsl:value-of select="xs:annotation/xs:documentation"/></xsl:attribute>
							<xsl:attribute name="data_type"><xsl:value-of select="xs:complexType/xs:group/@ref"/></xsl:attribute>
							<xsl:for-each select="xs:annotation/xs:appinfo/*">
								<!-- Generic method for declaring all appinfo as attributes-->
								<xsl:attribute name="{lower-case(name(.))}"><xsl:choose><xsl:when test="contains(lower-case(name(.)),'axis')"><xsl:choose><xsl:when test="$currPath=''"><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="axis" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="../../../@name"/><xsl:with-param name="axisPath" select="."/></xsl:call-template></xsl:when><xsl:otherwise><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="axis" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat($currPath,'/',../../../@name)"/><xsl:with-param name="axisPath" select="."/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:when><xsl:otherwise><xsl:value-of select="."/></xsl:otherwise></xsl:choose></xsl:attribute>
							</xsl:for-each>
						</field>
					</xsl:when>
					<xsl:otherwise>
						<!-- Otherwise the type is defined somewhere else (utilities.xsd) or is a complex type  -->
						<xsl:choose>
							<xsl:when test="@type">
								<!-- It is an external reference -->
								<field>
									<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
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
										<xsl:when test="@maxOccurs='unbounded'">
											<xsl:attribute name="data_type">struct_array</xsl:attribute>
										</xsl:when>
										<!-- It is a regular structure -->
										<xsl:otherwise>
											<xsl:attribute name="data_type">structure</xsl:attribute>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:for-each select="xs:annotation/xs:appinfo/*">
										<!-- Generic method for declaring all appinfo as attributes-->
	<xsl:attribute name="{lower-case(name(.))}"><xsl:choose><xsl:when test="contains(lower-case(name(.)),'axis')"><xsl:choose><xsl:when test="$currPath=''"><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="axis" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="../../../@name"/><xsl:with-param name="axisPath" select="."/></xsl:call-template></xsl:when><xsl:otherwise><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="axis" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat($currPath,'/',../../../@name)"/><xsl:with-param name="axisPath" select="."/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:when><xsl:otherwise><xsl:value-of select="."/></xsl:otherwise></xsl:choose></xsl:attribute>									</xsl:for-each>
									<!-- Handle type definition via template doImplementType. Need to pass an appropriate path definition -->
									<xsl:choose>
										<xsl:when test="$currPath=''">
											<xsl:call-template name="doImplementType">
												<xsl:with-param name="thisType" select="@type"/>
												<xsl:with-param name="currPath" select="@name"/>
											</xsl:call-template>
										</xsl:when>
										<xsl:otherwise>
											<xsl:call-template name="doImplementType">
												<xsl:with-param name="thisType" select="@type"/>
												<xsl:with-param name="currPath" select="concat($currPath,'/',@name)"/>
											</xsl:call-template>
										</xsl:otherwise>
									</xsl:choose>
								</field>
							</xsl:when>
							<xsl:otherwise>
								<!-- It is a complexType -->
								<field>
									<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
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
										<xsl:when test="@maxOccurs='unbounded'">
											<xsl:attribute name="data_type">struct_array</xsl:attribute>
											<xsl:if test="xs:annotation/xs:appinfo/axis1 or xs:annotation/xs:appinfo/Axis1">
												<xsl:attribute name="axis1"><xsl:value-of select="xs:annotation/xs:appinfo/axis1"/><xsl:value-of select="xs:annotation/xs:appinfo/Axis1"/></xsl:attribute>
											</xsl:if>
										</xsl:when>
										<!-- It is a regular structure -->
										<xsl:otherwise>
											<xsl:attribute name="data_type">structure</xsl:attribute>
											<!-- TREAT HERE THE CASE OF DIRECT BRANCHING OF A GROUP BELOW A STRUCTURE, OCCURS FOR SOME SIGNALS, NEED TO ADD A DATA CHILD -->
											<xsl:if test="xs:complexType/xs:sequence/xs:group">
												<field>
													<xsl:attribute name="name">Data</xsl:attribute>
													<xsl:choose>
														<xsl:when test="$currPath=''">
															<xsl:attribute name="path"><xsl:value-of select="concat(@name,'/Data')"/></xsl:attribute>
														</xsl:when>
														<xsl:otherwise>
															<xsl:attribute name="path"><xsl:value-of select="concat($currPath,'/',@name,'/Data')"/></xsl:attribute>
														</xsl:otherwise>
													</xsl:choose>
													<xsl:attribute name="documentation"><xsl:value-of select="xs:annotation/xs:documentation"/></xsl:attribute>
													<xsl:attribute name="data_type"><xsl:value-of select="xs:complexType/xs:sequence/xs:group/@ref"/></xsl:attribute>
													<xsl:for-each select="xs:annotation/xs:appinfo/*">
														<!-- Generic method for declaring all appinfo as attributes-->
	<xsl:attribute name="{lower-case(name(.))}"><xsl:choose><xsl:when test="contains(lower-case(name(.)),'axis')"><xsl:choose><xsl:when test="$currPath=''"><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="axis" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat(../../../@name,'/Data')"/><xsl:with-param name="axisPath" select="concat('../',.)"/></xsl:call-template></xsl:when><xsl:otherwise><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="axis" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat($currPath,'/',../../../@name,'/Data')"/><xsl:with-param name="axisPath" select="concat('../',.)"/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:when><xsl:otherwise><xsl:value-of select="."/></xsl:otherwise></xsl:choose></xsl:attribute>														
														
														
														
														<!--<xsl:attribute name="{name(.)}"><xsl:if test="contains(name(.),'Axis') or contains(name(.),'axis') ">../</xsl:if>--><!-- We just add ../ to all Axes since their are viewed from Data, one level below the original parent <xsl:value-of select="."/></xsl:attribute>-->
													</xsl:for-each>
												</field>
											</xsl:if>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:choose>
										<xsl:when test="$currPath=''">
											<xsl:apply-templates select="*/*/xs:element" mode="IMPLEMENT">
												<xsl:with-param name="currPath" select="@name"/>
											</xsl:apply-templates>
										</xsl:when>
										<xsl:otherwise>
											<xsl:apply-templates select="*/*/xs:element" mode="IMPLEMENT">
												<xsl:with-param name="currPath" select="concat($currPath, '/',@name)"/>
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
		<xsl:apply-templates select="document('Utilities/DD_Support.xsd')/*/xs:element[@name=$thisRef]" mode="DECLARE"/>
	</xsl:template>
	<xsl:template match="xs:include" mode="DECLARE">
		<xsl:param name="actRef"/>
		<xsl:param name="maxOcc"/>
		<xsl:apply-templates select="document(@schemaLocation)/*/xs:element[@name=$actRef]" mode="DECLARE">
			<xsl:with-param name="currPath" select="''"/>
			<xsl:with-param name="maxOcc" select="$maxOcc"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template name="doRefImplement">
		<xsl:param name="thisRef"/>
		<xsl:param name="currPath"/>
		<xsl:choose>
			<xsl:when test="document('Utilities/DD_Support.xsd')/*/xs:complexType[@name=$thisRef]">
				when the reference to be included is a complexType defined in utilities : NEVER HAPPENS
				CHECK RESULT HERE IF THIS APPEARS
				<xsl:apply-templates select="document('utilities.xsd')/*/xs:complexType[@name=$thisRef]" mode="IMPLEMENT">
					<xsl:with-param name="currPath" select="$currPath"/>
					<xsl:with-param name="parentmachine" select="yes"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="document('Utilities/DD_Support.xsd')/*/xs:element[@name=$thisRef]">
				<!-- when the reference to be included is an element defined in utilities -->
				<xsl:apply-templates select="document('Utilities/DD_Support.xsd')/*/xs:element[@name=$thisRef]" mode="IMPLEMENT">
					<xsl:with-param name="currPath" select="$currPath"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<!-- when the reference to be included is a whole additional xsd file -->
				<xsl:apply-templates select="/*/xs:include" mode="IMPLEMENT">
					<xsl:with-param name="actRef" select="$thisRef"/>
					<xsl:with-param name="currPath" select="$currPath"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="doImplementType">
		<xsl:param name="thisType"/>
		<xsl:param name="currPath"/>
		<xsl:param name="parentmachine"/>
		<xsl:param name="parenttime"/>
		<xsl:choose>
			<!-- for some of the complex Types, the time-dependence and machine description properties are defined by their parents -->
			<!-- in the schemas, this property is flagged by <xs:appinfo>parent-dependent</xs:appinfo> -->
			<!-- this is checked now, and  this information is passed using the parentmachine and parenttime parameters to the IMPLEMENT templates -->
			<!-- some draft of the parentunit information is done here ... not sure it is reliable yet for the units !! (used by ISE only for the moment) -->
			<xsl:when test="document('Utilities/DD_Support.xsd')/*/xs:complexType[@name=$thisType]">
				<!-- if the complexType definition is in Utilities-->
				<xsl:choose>
					<xsl:when test="contains(string(document('Utilities/DD_Support.xsd')/*/xs:complexType[@name=$thisType]/xs:annotation/xs:appinfo), 'parent-dependent')">
						<xsl:choose>
							<xsl:when test="contains(string(xs:annotation/xs:appinfo), 'machine description')">
								<xsl:choose>
									<xsl:when test="contains(string(xs:annotation/xs:documentation), 'Time-dependent')">
										<xsl:apply-templates select="document('Utilities/DD_Support.xsd')/*/xs:complexType[@name=$thisType]" mode="IMPLEMENT">
											<!--This fills the complexType from its definition in utilities (if it is there and not in the local schema)-->
											<xsl:with-param name="currPath" select="$currPath"/>
											<xsl:with-param name="parentmachine" select="'yes'"/>
											<xsl:with-param name="parenttime" select="'yes'"/>
											<xsl:with-param name="parentunit" select="substring-before(substring-after(string(xs:annotation/xs:documentation),'['),']')"/>
										</xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="document('Utilities/DD_Support.xsd')/*/xs:complexType[@name=$thisType]" mode="IMPLEMENT">
											<!--This fills the complexType from its definition in utilities (if it is there and not in the local schema)-->
											<xsl:with-param name="currPath" select="$currPath"/>
											<xsl:with-param name="parentmachine" select="'yes'"/>
											<xsl:with-param name="parentunit" select="substring-before(substring-after(string(xs:annotation/xs:documentation),'['),']')"/>
										</xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="contains(string(xs:annotation/xs:documentation), 'Time-dependent')">
										<xsl:apply-templates select="document('Utilities/DD_Support.xsd')/*/xs:complexType[@name=$thisType]" mode="IMPLEMENT">
											<!--This fills the complexType from its definition in utilities (if it is there and not in the local schema)-->
											<xsl:with-param name="currPath" select="$currPath"/>
											<xsl:with-param name="parenttime" select="'yes'"/>
											<xsl:with-param name="parentunit" select="substring-before(substring-after(string(xs:annotation/xs:documentation),'['),']')"/>
										</xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="document('Utilities/DD_Support.xsd')/*/xs:complexType[@name=$thisType]" mode="IMPLEMENT">
											<!--This fills the complexType from its definition in utilities (if it is there and not in the local schema)-->
											<xsl:with-param name="currPath" select="$currPath"/>
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
								<xsl:apply-templates select="document('Utilities/DD_Support.xsd')/*/xs:complexType[@name=$thisType]" mode="IMPLEMENT">
									<!--This fills the complexType from its definition in utilities (if it is there and not in the local schema)-->
									<xsl:with-param name="currPath" select="$currPath"/>
									<xsl:with-param name="parentunit" select="substring-before(substring-after(string(xs:annotation/xs:documentation),'['),']')"/>
									<xsl:with-param name="experimental" select="$thisType"/>
								</xsl:apply-templates>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="document('Utilities/DD_Support.xsd')/*/xs:complexType[@name=$thisType]" mode="IMPLEMENT">
									<!--This fills the complexType from its definition in utilities (if it is there and not in the local schema)-->
									<xsl:with-param name="currPath" select="$currPath"/>
									<xsl:with-param name="parentunit" select="substring-before(substring-after(string(xs:annotation/xs:documentation),'['),']')"/>
								</xsl:apply-templates>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
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
											<xsl:with-param name="parentmachine" select="'yes'"/>
											<xsl:with-param name="parenttime" select="'yes'"/>
											<xsl:with-param name="parentunit" select="substring-before(substring-after(string(xs:annotation/xs:documentation),'['),']')"/>
										</xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="/*/xs:complexType[@name=$thisType]" mode="IMPLEMENT">
											<xsl:with-param name="currPath" select="$currPath"/>
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
											<xsl:with-param name="parenttime" select="'yes'"/>
											<xsl:with-param name="parentunit" select="substring-before(substring-after(string(xs:annotation/xs:documentation),'['),']')"/>
										</xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="/*/xs:complexType[@name=$thisType]" mode="IMPLEMENT">
											<xsl:with-param name="currPath" select="$currPath"/>
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
							<xsl:with-param name="parentunit" select="substring-before(substring-after(string(xs:annotation/xs:documentation),'['),']')"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Below is the template dedicated to building absolute Path from the relative path, for the Axis attributes-->
	<xsl:template name="BuildAbsolutePath">
		<xsl:param name="axis"/>
		<xsl:param name="currPath"/>
		<xsl:param name="axisPath"/>
		<xsl:choose>
			<xsl:when test="contains($axisPath,'...')">
				<!-- Case of a main axis, directly print the 1...N prescription -->
				<xsl:value-of select="$axisPath"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="contains($axisPath,'../')">
						<xsl:value-of select="local:getAbsolutePath(concat($currPath,'/',$axisPath))"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat($currPath,'/',$axisPath)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
