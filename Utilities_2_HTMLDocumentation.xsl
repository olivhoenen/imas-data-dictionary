<?xml version="1.0" encoding="ISO-8859-1" standalone="yes"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./$GET[stylesheet]" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>
<!-- This XSLT creates a list of the existing generic Data Types from utilities/dd_support.xsd-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  xmlns:xs="http://www.w3.org/2001/XMLSchema">
<xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes"/>
  <xsl:template match="/*">
    <html>
      <head>
       <title>List of available Generic Structures</title>
        <style type="text/css">
			p {color:black;font-size:12pt;font-weight:normal;}
			p.name {color:red;font-size:18pt;font-weight:bold;}
			p.welcome {color:#3333aa; font-size:20pt; font-weight:bold; text-align:center;}
			span.head {color:#3333aa; font-size:12pt; font-weight:bold; }
       </style>
      </head>
      <body>
              <p class="welcome">List of available Generic Structures</p>
              <p>Generic structures are data structures that can be found in various places of the Physics Data Model, as they are useful in several contexts. Typical examples are lists of standard spatial coordinates, description of plasma ion species, traceability / provenance information, etc.</p>
<p>This list of available generic structures is not restrictive since it can be freely expanded by Data Model designers. Note that the structure name is not the name of a Data Model node, therefore the generic structure names do not appear in the Data Dictionary HTML documentation. They are primarily used for the design of the Data Dictionary, but also they can be used in Fortran codes where they are implemented as derived types.
</p>
<table border="1">
        <thead style="color:#ff0000"><td>Generic structure name</td><td>Description</td></thead>
<xsl:for-each select="xs:complexType">
<tr>
	<td><xsl:value-of select="@name"/></td>
	<td><xsl:value-of select="xs:annotation/xs:documentation"/></td>
</tr>
</xsl:for-each>
<xsl:for-each select="xs:element">
<tr>
	<td><xsl:value-of select="@name"/></td>
	<td><xsl:value-of select="xs:annotation/xs:documentation"/></td>
</tr>
</xsl:for-each>

        </table>
</body>
</html>
 </xsl:template>
</xsl:stylesheet>
