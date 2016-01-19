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
        <!-- First a general test here on all conditions to generate the "IDS is VALID" statement. This test consists in having success on all tests, i.e. all individual tests expressions are assembled here with AND NOT() statements. We therefore have to copy here with "and not()" all individual tests listed in the second xsl:when statement  -->
<xsl:choose>
<xsl:when test="not(.//field[not(@type) and not(@data_type='structure') and not(@data_type='struct_array')]) 
and not(.//field[not(@coordinate1) and (@data_type='FLT_1D' or @data_type='FLT_2D' or @data_type='FLT_3D' or @data_type='FLT_4D' or @data_type='FLT_5D' or @data_type='FLT_6D' or @data_type='INT_1D' or @data_type='INT_2D' or @data_type='INT_3D' or @data_type='CPX_1D' or @data_type='CPX_2D' or @data_type='CPX_3D' or @data_type='CPX_4D' or @data_type='CPX_5D' or @data_type='CPX_6D' or @data_type='STR_1D' or @data_type='struct_array' )])
and not (.//field[not(@coordinate2) and (@data_type='FLT_2D' or @data_type='FLT_3D' or @data_type='FLT_4D' or @data_type='FLT_5D' or @data_type='FLT_6D' or @data_type='INT_2D' or @data_type='INT_3D' or @data_type='CPX_2D' or @data_type='CPX_3D' or @data_type='CPX_4D' or @data_type='CPX_5D' or @data_type='CPX_6D' )])
and not (.//field[not(@coordinate3) and (@data_type='FLT_3D' or @data_type='FLT_4D' or @data_type='FLT_5D' or @data_type='FLT_6D' or @data_type='INT_3D' or @data_type='CPX_3D' or @data_type='CPX_4D' or @data_type='CPX_5D' or @data_type='CPX_6D' )])
and not (.//field[not(@coordinate4) and (@data_type='FLT_4D' or @data_type='FLT_5D' or @data_type='FLT_6D' or @data_type='CPX_4D' or @data_type='CPX_5D' or @data_type='CPX_6D' )])
and not (.//field[not(@coordinate5) and (@data_type='FLT_5D' or @data_type='FLT_6D' or @data_type='CPX_5D' or @data_type='CPX_6D' )])
and not (.//field[not(@coordinate6) and (@data_type='FLT_6D' or @data_type='CPX_6D' )])
and not (.//field[not(@units) and (@data_type='FLT_0D' or @data_type='FLT_1D' or @data_type='FLT_2D' or @data_type='FLT_3D' or @data_type='FLT_4D' or @data_type='FLT_5D' or @data_type='FLT_6D' or @data_type='CPX_0D' or @data_type='CPX_1D' or @data_type='CPX_2D' or @data_type='CPX_3D' or @data_type='CPX_4D' or @data_type='CPX_5D' or @data_type='CPX_6D')])
and not (.//field[@maxoccur='unbounded' and @type='dynamic' and ancestor::field[@maxoccur='unbounded' and @type='dynamic']])
">
<p class="welcome">IDS <xsl:value-of select="@name"/> is valid</p>
</xsl:when>
<xsl:otherwise> 
<!-- Create error table and populate it with results of the various tests, which are applied sequentially, each test corresponding to a particular type of error  -->
        <p class="welcome">IDS <xsl:value-of select="@name"/> has errors</p>
       <table border="1">
        <thead style="color:#ff0000"><td>Full path name</td><td>Description of the problem</td></thead>
        <!-- Test the presence of the "type" metadata (R5.2) -->
        <xsl:apply-templates select=".//field[not(@type) and not(@data_type='structure') and not(@data_type='struct_array')]">
        <xsl:with-param name="error_description" select="'This field must have a type attribute (constant/static/dynamic)'"/>
       </xsl:apply-templates>
       <!-- Test the presence of the "coordinate1" metadata for 1D+ data (R5.4) -->
        <xsl:apply-templates select=".//field[not(@coordinate1) and (@data_type='FLT_1D' or @data_type='FLT_2D' or @data_type='FLT_3D' or @data_type='FLT_4D' or @data_type='FLT_5D' or @data_type='FLT_6D' or @data_type='INT_1D' or @data_type='INT_2D' or @data_type='INT_3D' or @data_type='CPX_1D' or @data_type='CPX_2D' or @data_type='CPX_3D' or @data_type='CPX_4D' or @data_type='CPX_5D' or @data_type='CPX_6D' or @data_type='STR_1D' or @data_type='struct_array' )]">
        <xsl:with-param name="error_description" select="'This field must have a coordinate1 attribute'"/>
       </xsl:apply-templates>
       <!-- Test the presence of the "coordinate2" metadata for 2D+ data (R5.4) -->
        <xsl:apply-templates select=".//field[not(@coordinate2) and (@data_type='FLT_2D' or @data_type='FLT_3D' or @data_type='FLT_4D' or @data_type='FLT_5D' or @data_type='FLT_6D' or @data_type='INT_2D' or @data_type='INT_3D' or @data_type='CPX_2D' or @data_type='CPX_3D' or @data_type='CPX_4D' or @data_type='CPX_5D' or @data_type='CPX_6D' )]">
        <xsl:with-param name="error_description" select="'This field must have a coordinate2 attribute'"/>
       </xsl:apply-templates>
              <!-- Test the presence of the "coordinate3" metadata for 3D+ data (R5.4) -->
        <xsl:apply-templates select=".//field[not(@coordinate3) and (@data_type='FLT_3D' or @data_type='FLT_4D' or @data_type='FLT_5D' or @data_type='FLT_6D' or @data_type='INT_3D' or @data_type='CPX_3D' or @data_type='CPX_4D' or @data_type='CPX_5D' or @data_type='CPX_6D' )]">
        <xsl:with-param name="error_description" select="'This field must have a coordinate3 attribute'"/>
       </xsl:apply-templates>
              <!-- Test the presence of the "coordinate4" metadata for 4D+ data (R5.4) -->
        <xsl:apply-templates select=".//field[not(@coordinate4) and (@data_type='FLT_4D' or @data_type='FLT_5D' or @data_type='FLT_6D' or @data_type='CPX_4D' or @data_type='CPX_5D' or @data_type='CPX_6D' )]">
        <xsl:with-param name="error_description" select="'This field must have a coordinate4 attribute'"/>
       </xsl:apply-templates>
              <!-- Test the presence of the "coordinate5" metadata for 5D+ data (R5.4) -->
        <xsl:apply-templates select=".//field[not(@coordinate5) and (@data_type='FLT_5D' or @data_type='FLT_6D' or @data_type='CPX_5D' or @data_type='CPX_6D' )]">
        <xsl:with-param name="error_description" select="'This field must have a coordinate5 attribute'"/>
       </xsl:apply-templates>
              <!-- Test the presence of the "coordinate6" metadata for 6D+ data (R5.4) -->
        <xsl:apply-templates select=".//field[not(@coordinate6) and (@data_type='FLT_6D' or @data_type='CPX_6D' )]">
        <xsl:with-param name="error_description" select="'This field must have a coordinate6 attribute'"/>
       </xsl:apply-templates>
       <!-- Test the presence of the "units" metadata for FLT and CPX data (R5.3) -->
        <xsl:apply-templates select=".//field[not(@units) and (@data_type='FLT_0D' or @data_type='FLT_1D' or @data_type='FLT_2D' or @data_type='FLT_3D' or @data_type='FLT_4D' or @data_type='FLT_5D' or @data_type='FLT_6D' or @data_type='CPX_0D' or @data_type='CPX_1D' or @data_type='CPX_2D' or @data_type='CPX_3D' or @data_type='CPX_4D' or @data_type='CPX_5D' or @data_type='CPX_6D')]">
        <xsl:with-param name="error_description" select="'This field must have a units attribute'"/>
       </xsl:apply-templates>
       <!-- Test the presence of nested AoS 3 (illegal) -->
        <xsl:apply-templates select=".//field[@maxoccur='unbounded' and @type='dynamic' and ancestor::field[@maxoccur='unbounded' and @type='dynamic']]">
        <xsl:with-param name="error_description" select="'Illegal construct: this field is an AoS type 3 nested under another AoS type 3'"/>
       </xsl:apply-templates>

       </table>
</xsl:otherwise>
</xsl:choose>
</a>
</xsl:for-each>
</body>
</html>
  </xsl:template>
  

<!-- A generic template for printing the out_come of an error detection (adds a line to the HTML output table with the description of the error) -->
<xsl:template name ="print_error" match="field">
<xsl:param name ="error_description"/>
<tr><td><xsl:value-of select="@path_doc"/></td><td><xsl:value-of select="$error_description"/></td></tr>
</xsl:template>

</xsl:stylesheet>
