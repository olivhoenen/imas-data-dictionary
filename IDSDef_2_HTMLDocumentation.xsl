<?xml version="1.0" encoding="ISO-8859-1" standalone="yes"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./$GET[stylesheet]" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  xmlns:xs="http://www.w3.org/2001/XMLSchema">
<xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes"/>
  <xsl:template match="/*">
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
	
	<td><a href="#{@name}"><xsl:value-of select="@name"/></a></td>
	<td><xsl:value-of select="@documentation"/></td>
	<td><xsl:value-of select="@maxoccur"/></td>
</tr>
</xsl:for-each>
        </table>

<!--Second: write the detailed documentation of each IDS-->
<xsl:for-each select="IDS">
<a name="{@name}">
        <p class="welcome">ITER Physics Data Model Documentation for <xsl:value-of select="@name"/></p>
        <p><xsl:value-of select="@documentation"/></p> <!-- Write the IDS description -->
        <!--<b></b>
        <br />-->
        <table border="1">
        <thead style="color:#ff0000"><td>Full path name</td><td>Description</td><td>Data Type</td><td>Coordinates</td></thead>
        <xsl:apply-templates select="field"/>
        </table>
        </a>
        </xsl:for-each>
     </body>
    </html>
  </xsl:template>
  

  <xsl:template match="field">
    <tr>
<td><xsl:value-of select="@path"/>

<xsl:if test="@maxOccurs>1 or @maxOccurs='unbounded'">{1:<xsl:value-of select="@maxOccurs"/>}</xsl:if></td>

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
