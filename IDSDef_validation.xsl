<?xml version="1.0" encoding="ISO-8859-1" standalone="yes"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./$GET[stylesheet]" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>
<!-- This stylesheet implements some validation tests on IDSDef.xml -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  xmlns:xs="http://www.w3.org/2001/XMLSchema">
<xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes"/>
  <xsl:template match="/*">
    <html>
      <head>
       <title>Data Dictionary validation results</title>
        <style type="text/css">
			p {color:black;font-size:12pt;font-weight:normal;}
			p.name {color:red;font-size:18pt;font-weight:bold;}
			p.welcome {color:#3333aa; font-size:20pt; font-weight:bold; text-align:left;}
			span.head {color:#3333aa; font-size:12pt; font-weight:bold; }
       </style>
      </head>
      <body>

<!-- Later, a test on utilities could be implemented ?-->
<!-- Tests are done for each IDS -->
<xsl:for-each select="IDS">
<a name="{@name}">
        <!-- First a general test here on all conditions to generate the VALID statement -->
<xsl:choose>
<xsl:when test="not(.//field[not(@type) and not(@data_type='structure') and not(@data_type='struct_array')])">
<p class="welcome">IDS <xsl:value-of select="@name"/> is valid</p>
</xsl:when>
<xsl:otherwise>
<!-- Create error table and populate it with succesfull tests -->
        <p class="welcome">IDS <xsl:value-of select="@name"/> has errors</p>
       <table border="1">
        <thead style="color:#ff0000"><td>Full path name</td><td>Description of the problem</td></thead>
        <!-- Test the presence of the "type" metadata -->
        <xsl:apply-templates select=".//field[not(@type) and not(@data_type='structure') and not(@data_type='struct_array')]">
        <xsl:with-param name="error_description" select="'This field should habe a type constant/static/dynamic'"/>
       </xsl:apply-templates>
       </table>
</xsl:otherwise>
</xsl:choose>
</a>
</xsl:for-each>
</body>
</html>
  </xsl:template>
  

<!-- A generic template for printing (adds a line to the HTML output table -->
<xsl:template name ="print_error" match="field">
<xsl:param name ="error_description"/>
<tr><td><xsl:value-of select="@path_doc"/></td><td><xsl:value-of select="$error_description"/></td></tr>
</xsl:template>

</xsl:stylesheet>
