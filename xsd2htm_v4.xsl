<?xml version="1.0" encoding="ISO-8859-1" standalone="yes"?>
<?modxslt-stylesheet Type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./$GET[stylesheet]" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet Type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  xmlns:xs="http://www.w3.org/2001/XMLSchema">
<xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes"/>
  <xsl:template match="/*">
    <html>
      <head>
       <title>Demonstration 11</title>
        <style Type="text/css">
			p {color:black;font-size:12pt;font-weight:normal;}
			p.name {color:red;font-size:18pt;font-weight:bold;}
			p.welcome {color:#3333aa; font-size:20pt; font-weight:bold; text-align:center;}
			span.head {color:#3333aa; font-size:12pt; font-weight:bold; }
       </style>
      </head>
      <body>
        <p class="welcome">ITER Physics Data Model Documentation for <xsl:value-of select="//xs:element/@name"/></p>
        <p>The Data Dictionary (XSD file) is transformed into this documentation on the fly.</p>
        <xsl:apply-templates select="xs:include"/>
        <b></b>
       <p><a href="doc_D.htm">Documentation syntax</a><xsl:text>  </xsl:text>
        <a href="doc_M.htm">Matlab syntax</a><xsl:text>  </xsl:text>
        <a href="doc_F.htm">Fortran syntax</a></p>
        <br />
        <table border="1">
        <thead style="color:#ff0000"><td>Full path name</td><td>Description</td><td>Character</td><td>Axes</td></thead>
        <xsl:apply-templates select="xs:element"/>
        </table>
     </body>
    </html>
  </xsl:template>
  
<xsl:template match="*">
  <xsl:apply-templates />
</xsl:template>

<xsl:template match="xs:include">
  <b>Include file: </b><xsl:value-of select="@schemaLocation" /><br />
</xsl:template>

<xsl:template match="xs:appinfo|xs:documentation"></xsl:template>

  <xsl:template match="xs:element">
   <xsl:variable name="language">D</xsl:variable>
  <xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'" />
 <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />

 <tr><td>
  <xsl:for-each select="ancestor-or-self::xs:element"> <!-- we should remove the root name -->
     <xsl:choose>
		<xsl:when test="$language='D' ">
			<xsl:text>/</xsl:text><xsl:value-of select="@name" /><xsl:value-of select="@ref" /> 
		</xsl:when>
		<xsl:when test="$language='F' ">
			<xsl:text>%</xsl:text><xsl:value-of select="translate(@name, $uppercase, $smallcase)" /><xsl:value-of select="translate(@ref, $uppercase, $smallcase)" />
		</xsl:when>
		<xsl:when test="$language='M' ">
			<xsl:text>.</xsl:text><xsl:value-of select="translate(@name, $smallcase, $uppercase)" /><xsl:value-of select="translate(@ref, $smallcase, $uppercase)" />
		</xsl:when>
	</xsl:choose>				
   </xsl:for-each> <xsl:if test="@maxOccurs>1 or @maxOccurs='unbounded'"> {1:<xsl:value-of select="@maxOccurs"/>}</xsl:if></td>

<xsl:if test="@name !='' ">           
           <td><xsl:value-of select="xs:annotation/xs:documentation"/>
          <xsl:if test="xs:annotation/xs:appinfo/Type = 'STATIC' "> {STATIC}</xsl:if><xsl:if test="xs:annotation/xs:appinfo/Type = 'SIGNAL' "> {SIGNAL}</xsl:if><xsl:if test="xs:annotation/xs:appinfo/Type = 'CONSTANT' "> {CONSTANT}</xsl:if><xsl:if test="xs:annotation/xs:appinfo/Units">[<xsl:value-of select="xs:annotation/xs:appinfo/Units"/>]</xsl:if></td>
           <td><xsl:value-of select="xs:complexType/xs:group/@ref"/>&#160;<xsl:if test="@Type"><a><xsl:attribute name="href">Put the correct URL here</xsl:attribute><i><xsl:value-of select="@Type" /></i></a></xsl:if>
</td>  
 </xsl:if>
 
 
 
<td>
<xsl:if test="xs:annotation/xs:appinfo/Axis1"><table>
<tr><td>1-
<xsl:if test="node()"><xsl:value-of select="xs:annotation/xs:appinfo/Axis1/."/></xsl:if>
<xsl:if test="not(node())">1..N</xsl:if>
</td></tr>
<xsl:if test="xs:annotation/xs:appinfo/Axis2">
<tr><td>2-
<xsl:if test="node()"><xsl:value-of select="xs:annotation/xs:appinfo/Axis2/."/></xsl:if>
<xsl:if test="not(node())">1..N</xsl:if>
</td></tr>
<xsl:if test="xs:annotation/xs:appinfo/Axis3">
<tr><td>3-
<xsl:if test="node()"><xsl:value-of select="xs:annotation/xs:appinfo/Axis3/."/></xsl:if>
<xsl:if test="not(node())">1..N</xsl:if>
</td></tr>
</xsl:if>
</xsl:if>
</table>
</xsl:if>

<!--<xsl:if test="xs:complexType/xs:group/@ref  and not(@ref) and not(xs:annotation/xs:appinfo/Axis) and not(contains(xs:complexType/xs:group/@ref,'0D' ))">(1..N)</xsl:if> -->
</td>
<xsl:if test="@ref !=''"><td colspan="2"><a><xsl:attribute name="href">http://crppwww.epfl.ch/~lister/euitmschemas/schemas.php?schema=<xsl:value-of select="@ref" />&amp;view=xsd2htm11</xsl:attribute><i><xsl:value-of select="@ref" /></i></a></td></xsl:if>

  </tr>
  <xsl:apply-templates />
 </xsl:template>
</xsl:stylesheet>
