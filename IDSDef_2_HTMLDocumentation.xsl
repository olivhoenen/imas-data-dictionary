<?xml version="1.0" encoding="ISO-8859-1" standalone="yes"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./$GET[stylesheet]" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>
<xsl:stylesheet xmlns:yaslt="http://www.mod-xslt2.com/ns/2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" extension-element-prefixes="yaslt" xmlns:fn="http://www.w3.org/2005/02/xpath-functions" xmlns:local="http://www.example.com/functions/local" exclude-result-prefixes="local xs">
<xsl:output method="html" encoding="UTF-8" indent="yes"/>
  <xsl:template match="/*">
<xsl:result-document href="html_documentation/html_documentation.html">
    <html>
      <head>
       <title>Data Dictionary HTML documentation</title>
        <style type="text/css">
			p {color:black;font-size:12pt;font-weight:normal;}
			p.name {color:red;font-size:18pt;font-weight:bold;}
			p.welcome {color:#3333aa; font-size:20pt; font-weight:bold; text-align:center;}
			span.head {color:#3333aa; font-size:12pt; font-weight:bold; }
       </style>
      </head>
      <body>
              <p class="welcome">ITER Physics Data Model Documentation : Top level (list of all IDSs)</p>
<!-- First make a list of IDS with the Links-->
<table border="1">
        <thead style="color:#ff0000"><td>IDS name</td><td>Description</td><td>Max. occurrence number</td></thead>
<xsl:for-each select="IDS">
<tr>
	<td><a href="{@name}.html"><xsl:value-of select="@name"/></a></td>
	<td><xsl:value-of select="@documentation"/></td>
	<td><xsl:value-of select="@maxoccur"/></td>
</tr>
</xsl:for-each>
        </table>
<!-- Second: write the list of reusable structures from Utilities -->
 <p class="welcome">List of available Generic Structures</p>
 <p>Generic structures are data structures that can be found in various places of the Physics Data Model, as they are useful in several contexts. Typical examples are lists of standard spatial coordinates, description of plasma ion species, traceability / provenance information, etc.</p>
<p>This list of available generic structures is not restrictive since it can be freely expanded by Data Model designers. Note that the structure name is not the name of a Data Model node, therefore the generic structure names do not appear in the Data Dictionary HTML documentation. They are primarily used for the design of the Data Dictionary, but also they can be used in Fortran codes where they are implemented as derived types.
</p>
<table border="1">
        <thead style="color:#ff0000"><td>Generic structure name</td><td>Description</td></thead>
<xsl:for-each select="document('utilities/dd_support.xsd')/*/xs:complexType">
<tr>
	<td><xsl:value-of select="@name"/></td>
	<td><xsl:value-of select="xs:annotation/xs:documentation"/></td>
</tr>
</xsl:for-each>
<xsl:for-each select="document('utilities/dd_support.xsd')/*/xs:element">
<tr>
	<td><xsl:value-of select="@name"/></td>
	<td><xsl:value-of select="./xs:annotation/xs:documentation"/></td>
</tr>
</xsl:for-each>
</table>
</body>
</html>
</xsl:result-document>

<!--Third: write the detailed documentation of each IDS-->
<xsl:for-each select="IDS">
<xsl:result-document href="html_documentation/{@name}.html">
<html>
      <head>
       <title>Data Dictionary HTML documentation</title>
        <style type="text/css">
			p {color:black;font-size:12pt;font-weight:normal;}
			p.name {color:red;font-size:18pt;font-weight:bold;}
			p.welcome {color:#3333aa; font-size:20pt; font-weight:bold; text-align:center;}
			span.head {color:#3333aa; font-size:12pt; font-weight:bold; }
       </style>
      </head>
      <body>
        <p class="welcome">ITER Physics Data Model Documentation for <xsl:value-of select="@name"/></p>
        <p><xsl:value-of select="@documentation"/></p> <!-- Write the IDS description -->
        <p>Notation of array of structure indices: itime indicates a time index; i1, i2, i3, ... indicate other indices with their depth in the IDS. This notation clarifies the path of a given node, but should not be used to compare indices of different nodes (they may have different meanings).</p>
        <p>Lifecycle status: <xsl:value-of select="@lifecycle_status"/> since version <xsl:value-of select="@lifecycle_version"/></p> <!-- Write the IDS Lifecycle information -->
        <p><a href="html_documentation.html">Back to top IDS list</a></p>
        <table border="1">
        <thead style="color:#ff0000"><td>Full path name</td><td>Description</td><td>Data Type</td><td>Coordinates</td></thead>
        <xsl:apply-templates select="field"/>
        </table>
        <p><a href="html_documentation.html">Back to top IDS list</a></p>
</body>
</html>
</xsl:result-document>
        </xsl:for-each>

  </xsl:template>
  

  <xsl:template match="field">
    <tr>
<td><xsl:value-of select="@path_doc"/>

<xsl:if test="@maxOccurs>1 or @maxOccurs='unbounded'">{1:<xsl:value-of select="@maxOccurs"/>}</xsl:if>
<xsl:if test="@lifecycle_status"><p>Lifecycle status: <font color="red"><xsl:value-of select="@lifecycle_status"/></font> since version <xsl:value-of select="@lifecycle_version"/></p></xsl:if></td>

           <td><xsl:value-of select="@documentation"/>
           <xsl:if test="@type"> {<xsl:value-of select="@type"/>}</xsl:if>
           <xsl:if test="@Type"> {<xsl:value-of select="@Type"/>}</xsl:if>
          <xsl:if test="@units"> [<xsl:value-of select="@units"/>]</xsl:if>
                    <xsl:if test="@Units"> [<xsl:value-of select="@Units"/>]</xsl:if>

           </td>
           <td><xsl:value-of select="@data_type"/><xsl:if test="@maxoccur"> [max_size=<xsl:value-of select="@maxoccur"/>]</xsl:if></td>  
  
<td>
<xsl:if test="@coordinate1"> <!--If there is at least one axis-->
<table>
<tr><td>1- <xsl:value-of select="@coordinate1"/>
</td></tr>
<xsl:if test="@coordinate2">
<tr><td>2- <xsl:value-of select="@coordinate2"/>
</td></tr>
<xsl:if test="@coordinate3">
<tr><td>3- <xsl:value-of select="@coordinate3"/>
</td></tr>
<xsl:if test="@coordinate4">
<tr><td>4- <xsl:value-of select="@coordinate4"/>
</td></tr>
<xsl:if test="@coordinate5">
<tr><td>5- <xsl:value-of select="@coordinate5"/>
</td></tr>
<xsl:if test="@coordinate6">
<tr><td>6- <xsl:value-of select="@coordinate6"/>
</td></tr>
</xsl:if>
</xsl:if>
</xsl:if>
</xsl:if>
</xsl:if>
</table>
</xsl:if>
</td>
  </tr>
  <!-- Recursively process the children -->
  <xsl:apply-templates select="field"/>
 </xsl:template>
</xsl:stylesheet>
