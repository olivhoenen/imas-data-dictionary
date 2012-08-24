<?xml version="1.0" encoding="ISO-8859-1" standalone="yes"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./$GET[stylesheet]" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  xmlns:xs="http://www.w3.org/2001/XMLSchema">
<xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes"/>
  <xsl:template match="/*">
    <html>
      <head>
       <title>Demonstration 11</title>
        <style type="text/css">
			p {color:black;font-size:12pt;font-weight:normal;}
			p.name {color:red;font-size:18pt;font-weight:bold;}
			p.welcome {color:#3333aa; font-size:20pt; font-weight:bold; text-align:center;}
			span.head {color:#3333aa; font-size:12pt; font-weight:bold; }
       </style>
      </head>
      <body>
        <p class="welcome">ITER Physics Data Model Documentation for <xsl:value-of select="/*/xs:element/@name"/></p>
        <p>The Data Dictionary (XSD file) is transformed into this documentation on the fly.</p>
        <xsl:apply-templates select="xs:include"/>
        <b></b>
        <br />
        <table border="1">
        <thead style="color:#ff0000"><td>Full path name</td><td>Description</td><td>Character</td><td>Axes</td></thead>
        <xsl:apply-templates select="xs:element"/>
        <xsl:apply-templates select="xs:complexType"/>
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
    <tr>
<td><xsl:for-each select="ancestor-or-self::xs:element"> <!-- we should remove the root name -->
                <xsl:text>/</xsl:text><xsl:value-of select="@name" /><xsl:value-of select="@ref" /> 
                </xsl:for-each> <xsl:if test="@maxOccurs>1 or @maxOccurs='unbounded'">{1:<xsl:value-of select="@maxOccurs"/>}</xsl:if></td>

<xsl:if test="@name !='' ">           
           <td><xsl:value-of select="xs:annotation/xs:documentation"/>
          <xsl:if test="xs:annotation/xs:appinfo/type = 'STATIC' "> {STATIC}</xsl:if><xsl:if test="xs:annotation/xs:appinfo/type = 'SIGNAL' "> {SIGNAL}</xsl:if><xsl:if test="xs:annotation/xs:appinfo/type = 'CONSTANT' "> {CONSTANT}</xsl:if><xsl:if test="xs:annotation/xs:appinfo/units">[<xsl:value-of select="xs:annotation/xs:appinfo/units"/>]</xsl:if></td>
           <td><xsl:value-of select="xs:complexType/xs:group/@ref"/>&#160;<xsl:if test="@type"><a><xsl:attribute name="href">Put the correct URL here</xsl:attribute><i><xsl:value-of select="@type" /></i></a></xsl:if>
</td>  
 </xsl:if>
 
 
 
<td>
<xsl:if test="xs:annotation/xs:appinfo/axis1"><table>
<tr><td>1-
<xsl:if test="node()"><xsl:value-of select="xs:annotation/xs:appinfo/axis1/."/></xsl:if>
<xsl:if test="not(node())">1..N</xsl:if>
</td></tr>
<xsl:if test="xs:annotation/xs:appinfo/axis2">
<tr><td>2-
<xsl:if test="node()"><xsl:value-of select="xs:annotation/xs:appinfo/axis2/."/></xsl:if>
<xsl:if test="not(node())">1..N</xsl:if>
</td></tr>
<xsl:if test="xs:annotation/xs:appinfo/axis3">
<tr><td>3-
<xsl:if test="node()"><xsl:value-of select="xs:annotation/xs:appinfo/axis3/."/></xsl:if>
<xsl:if test="not(node())">1..N</xsl:if>
</td></tr>
</xsl:if>
</xsl:if>
</table>
</xsl:if>

<!--<xsl:if test="xs:complexType/xs:group/@ref  and not(@ref) and not(xs:annotation/xs:appinfo/axis) and not(contains(xs:complexType/xs:group/@ref,'0D' ))">(1..N)</xsl:if> -->
</td>
<xsl:if test="@ref !=''"><td colspan="2"><a><xsl:attribute name="href">http://crppwww.epfl.ch/~lister/euitmschemas/schemas.php?schema=<xsl:value-of select="@ref" />&amp;view=xsd2htm11</xsl:attribute><i><xsl:value-of select="@ref" /></i></a></td></xsl:if>

  </tr>
  <xsl:apply-templates />
 </xsl:template>
</xsl:stylesheet>
