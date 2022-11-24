<?xml version="1.0" encoding="ISO-8859-1" standalone="yes"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./$GET[stylesheet]" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>
<!-- This stylesheet implements some validation tests on IDSDef.xml -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  xmlns:xs="http://www.w3.org/2001/XMLSchema">
<xsl:output method="text" encoding="UTF-8"/>
<xsl:template match="/*">
<!-- Tests for the utilities section -->
<xsl:choose>
<xsl:when test="not(./utilities//field[@timebasepath=''])">
The utilities section is valid</xsl:when>
<xsl:otherwise>
The utilities section has errors:<xsl:apply-templates select="./utilities//field[@timebasepath='']">
<xsl:with-param name="error_description" select="'Problem in the timebasepath computation or in the specification of the time coordinate : this field has an empty timebasepath attribute'"/>
</xsl:apply-templates>
</xsl:otherwise>
</xsl:choose>

<!-- Tests are done for each IDS -->
<xsl:for-each select="IDS">
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
and not (.//field[@units and not(@units='UTC' or @units='Atomic Mass Unit' or @units='Elementary Charge Unit') and (contains(@data_type,'STR_') or contains(@data_type,'INT_') or contains(@data_type,'str_') or contains(@data_type,'int_'))])
and not (.//field[@maxoccur='unbounded' and @type='dynamic' and ancestor::field[@maxoccur='unbounded' and @type='dynamic']])
and not (.//field[@maxoccur='unbounded' and not(@type='dynamic') and not(ancestor::field[@maxoccur='unbounded' and @type='dynamic'])])
and not (.//field[(@data_type='FLT_0D' or @data_type='INT_0D' or @data_type='CPX_0D' or @data_type='STR_0D') and @type='dynamic' and not(ancestor::field[@maxoccur='unbounded' and @type='dynamic'])])
and not (.//field[@data_type='structure' and @type])
and not (.//field[(not(@data_type='structure') and not(@data_type='struct_array')) and not(@type='dynamic') and (ancestor::field[@maxoccur='unbounded' and @type='dynamic'])])
and not (.//field[@timebasepath=''])
">
IDS <xsl:value-of select="@name"/> is valid.</xsl:when>
<xsl:otherwise><!-- Create error table and populate it with results of the various tests, which are applied sequentially, each test corresponding to a particular type of error  -->
IDS <xsl:value-of select="@name"/> has errors: <!-- Test the presence of the "type" metadata (R5.2) -->
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
<!-- Test that INT and STR data have no "units" metadata (R5.3), although some exceptions are possible for specific cases (UTC, Elementary charge or atomic mass units) -->
<xsl:apply-templates select=".//field[@units and not(@units='UTC' or @units='Atomic Mass Unit' or @units='Elementary Charge Unit') and (contains(@data_type,'STR_') or contains(@data_type,'INT_') or contains(@data_type,'str_') or contains(@data_type,'int_'))]">
<xsl:with-param name="error_description" select="'This field should NOT have a units attribute'"/>
</xsl:apply-templates>
<!-- Test the presence of nested AoS 3 (illegal) -->
<xsl:apply-templates select=".//field[@maxoccur='unbounded' and @type='dynamic' and ancestor::field[@maxoccur='unbounded' and @type='dynamic']]">
<xsl:with-param name="error_description" select="'Illegal construct: this field is an AoS type 3 nested under another AoS type 3'"/>
</xsl:apply-templates>
<!-- Test the presence of AoS 2 that is not nested below an AoS 3 (not implemented yet in the AL) -->
<xsl:apply-templates select=".//field[@maxoccur='unbounded' and not(@type='dynamic') and not(ancestor::field[@maxoccur='unbounded' and @type='dynamic'])]">
<xsl:with-param name="error_description" select="'Illegal construct: this field is an AoS type 2 and should be nested under an AoS type 3 (AoS 2 without nesting benow an AoS 3 are not implemented in the AL yet). If this construct is needed, set the field as an AoS type 1 by setting a finite maxOccurs attribute'"/>
</xsl:apply-templates>
<!-- Test the presence of "dynamic" scalars that are not nested below an AoS 3 (scalars cannot be dynamic unless under an AoS3) -->
<xsl:apply-templates select=".//field[(@data_type='FLT_0D' or @data_type='INT_0D' or @data_type='CPX_0D' or @data_type='STR_0D') and @type='dynamic' and not(ancestor::field[@maxoccur='unbounded' and @type='dynamic'])]">
<xsl:with-param name="error_description" select="'Illegal metadata: this scalar field is marked as &quot;dynamic&quot;. Scalars cannot be dynamic unless placed under an AoS type 3'"/>
</xsl:apply-templates>
<!-- Test the presence of structures marked with a type attribute (no meaning and breaks the Java API) -->
<xsl:apply-templates select=".//field[@data_type='structure' and @type]">
<xsl:with-param name="error_description" select="'Illegal metadata: this structure field should NOT have a &quot;type&quot; attribute (constant/static/dynamic)'"/>
</xsl:apply-templates>
<!-- Test the presence of non-dynamic leaves under an AoS 3 (all leaves of an AoS3 must be dynamic) -->
<xsl:apply-templates select=".//field[(not(@data_type='structure') and not(@data_type='struct_array')) and not(@type='dynamic') and (ancestor::field[@maxoccur='unbounded' and @type='dynamic'])]">
<xsl:with-param name="error_description" select="'Illegal metadata: all leaves below an AoS3 must be dynamic'"/>
</xsl:apply-templates>
<!-- Test that all timebasepath attributes are non-empty -->
<xsl:apply-templates select=".//field[@timebasepath='']">
<xsl:with-param name="error_description" select="'Problem in the timebasepath computation or in the specification of the time coordinate : this field has an empty timebasepath attribute'"/>
</xsl:apply-templates>
</xsl:otherwise>
</xsl:choose>
</xsl:for-each>
</xsl:template>

<!-- A generic template for printing the out_come of an error detection (adds a line to the output text report with the description of the error) -->
<xsl:template name ="print_error" match="field">
<xsl:param name ="error_description"/>
    Error in <xsl:value-of select="@path_doc"/>: <xsl:value-of select="$error_description"/>
</xsl:template>

</xsl:stylesheet>
