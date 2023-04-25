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
    <!-- Test the presence of the "type" metadata (R5.2) -->
    <xsl:variable name="test_type_attributes"
        select=".//field[not(@type) and not(@data_type='structure') and not(@data_type='struct_array')]"/>
    <!-- Test the presence of the "coordinate1" metadata for 1D+ data (R5.4) -->
    <xsl:variable name="test_has_coordinate1"
        select=".//field[not(@coordinate1) and (matches(@data_type, '^FLT_[1-6]D$') or matches(@data_type, '^INT_[1-4]D$') or matches(@data_type, '^CPX_[1-6]D$') or @data_type='STR_1D' or @data_type='struct_array' )]"/>
    <!-- Test the presence of the "coordinate2" metadata for 2D+ data (R5.4) -->
    <xsl:variable name="test_has_coordinate2"
        select=".//field[not(@coordinate2) and (matches(@data_type, '^FLT_[2-6]D$') or matches(@data_type, '^INT_[2-4]D$') or matches(@data_type, '^CPX_[2-6]D$'))]"/>
    <!-- Test the presence of the "coordinate3" metadata for 3D+ data (R5.4) -->
    <xsl:variable name="test_has_coordinate3"
        select=".//field[not(@coordinate3) and (matches(@data_type, '^FLT_[3-6]D$') or matches(@data_type, '^INT_[3-4]D$') or matches(@data_type, '^CPX_[3-6]D$'))]"/>
    <!-- Test the presence of the "coordinate4" metadata for 4D+ data (R5.4) -->
    <xsl:variable name="test_has_coordinate4"
        select=".//field[not(@coordinate4) and (matches(@data_type, '^FLT_[4-6]D$') or @data_type='INT_4D' or matches(@data_type, '^CPX_[4-6]D$'))]"/>
    <!-- Test the presence of the "coordinate5" metadata for 5D+ data (R5.4) -->
    <xsl:variable name="test_has_coordinate5"
        select=".//field[not(@coordinate5) and (matches(@data_type, '^FLT_[5-6]D$') or matches(@data_type, '^CPX_[5-6]D$'))]"/>
    <!-- Test the presence of the "coordinate6" metadata for 6D+ data (R5.4) -->
    <xsl:variable name="test_has_coordinate6"
        select=".//field[not(@coordinate6) and (@data_type='FLT_6D' or @data_type='CPX_6D')]"/>
    <!-- Test the presence of the "units" metadata for FLT and CPX data (R5.3) -->
    <xsl:variable name="test_has_units"
        select=".//field[not(@units) and (matches(@data_type, '^FLT_[0-6]D$') or matches(@data_type, '^CPX_[0-6]D$'))]"/>
    <!-- Test that INT and STR data have no "units" metadata (R5.3), although some exceptions are possible for specific cases (UTC, Elementary charge or atomic mass units) -->
    <xsl:variable name="test_has_no_units"
        select=".//field[@units and not(@units='UTC' or @units='Atomic Mass Unit' or @units='Elementary Charge Unit') and (contains(@data_type,'STR_') or contains(@data_type,'INT_') or contains(@data_type,'str_') or contains(@data_type,'int_'))]"/>
    <!-- Test the presence of nested AoS 3 (illegal) -->
    <xsl:variable name="test_no_nested_aos3"
        select=".//field[@maxoccur='unbounded' and @type='dynamic' and ancestor::field[@maxoccur='unbounded' and @type='dynamic']]"/>
    <!-- Test the presence of AoS 2 that is not nested below an AoS 3 (not implemented yet in the AL) -->
    <xsl:variable name="test_aos2_nested_below_aos3"
        select=".//field[@maxoccur='unbounded' and not(@type='dynamic') and not(ancestor::field[@maxoccur='unbounded' and @type='dynamic'])]"/>
    <!-- Test the presence of "dynamic" scalars that are not nested below an AoS 3 (scalars cannot be dynamic unless under an AoS3) -->
    <xsl:variable name="test_dynamic_scalars_nested_below_aos3"
        select=".//field[(@data_type='FLT_0D' or @data_type='INT_0D' or @data_type='CPX_0D' or @data_type='STR_0D') and @type='dynamic' and not(ancestor::field[@maxoccur='unbounded' and @type='dynamic'])]"/>
    <!-- Test the presence of structures marked with a type attribute (no meaning and breaks the Java API) -->
    <xsl:variable name="test_no_structures_with_type"
        select=".//field[@data_type='structure' and @type]"/>
    <!-- Test the presence of non-dynamic leaves under an AoS 3 (all leaves of an AoS3 must be dynamic) -->
    <xsl:variable name="test_aos3_leaves_dynamic"
        select=".//field[(not(@data_type='structure') and not(@data_type='struct_array')) and not(@type='dynamic') and (ancestor::field[@maxoccur='unbounded' and @type='dynamic'])]"/>
    <!-- Test that all timebasepath attributes are non-empty -->
    <xsl:variable name="test_non_empty_timebasepath"
        select=".//field[@timebasepath='']"/>
    <!-- First a general test here on all conditions to generate the "IDS is VALID" statement. This test consists in having success on all tests, i.e. all individual tests expressions are assembled here with AND NOT() statements. -->
    <xsl:choose>
        <xsl:when test="
            not ($test_type_attributes)
        and not ($test_has_coordinate1)
        and not ($test_has_coordinate2)
        and not ($test_has_coordinate3)
        and not ($test_has_coordinate4)
        and not ($test_has_coordinate5)
        and not ($test_has_coordinate6)
        and not ($test_has_units)
        and not ($test_has_no_units)
        and not ($test_no_nested_aos3)
        and not ($test_aos2_nested_below_aos3)
        and not ($test_dynamic_scalars_nested_below_aos3)
        and not ($test_no_structures_with_type)
        and not ($test_aos3_leaves_dynamic)
        and not ($test_non_empty_timebasepath)
        ">
IDS <xsl:value-of select="@name"/> is valid.</xsl:when>
        <xsl:otherwise><!-- Create error table and populate it with results of the various tests, which are applied sequentially, each test corresponding to a particular type of error  -->
IDS <xsl:value-of select="@name"/> has errors:
            <xsl:apply-templates select="$test_type_attributes">
                <xsl:with-param name="error_description" select="'This field must have a type attribute (constant/static/dynamic)'"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="$test_has_coordinate1">
                <xsl:with-param name="error_description" select="'This field must have a coordinate1 attribute'"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="$test_has_coordinate2">
                <xsl:with-param name="error_description" select="'This field must have a coordinate2 attribute'"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="$test_has_coordinate3">
                <xsl:with-param name="error_description" select="'This field must have a coordinate3 attribute'"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="$test_has_coordinate4">
                <xsl:with-param name="error_description" select="'This field must have a coordinate4 attribute'"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="$test_has_coordinate5">
                <xsl:with-param name="error_description" select="'This field must have a coordinate5 attribute'"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="$test_has_coordinate6">
                <xsl:with-param name="error_description" select="'This field must have a coordinate6 attribute'"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="$test_has_units">
                <xsl:with-param name="error_description" select="'This field must have a units attribute'"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="$test_has_no_units">
                <xsl:with-param name="error_description" select="'This field should NOT have a units attribute'"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="$test_no_nested_aos3">
                <xsl:with-param name="error_description" select="'Illegal construct: this field is an AoS type 3 nested under another AoS type 3'"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="$test_aos2_nested_below_aos3">
                <xsl:with-param name="error_description" select="'Illegal construct: this field is an AoS type 2 and should be nested under an AoS type 3 (AoS 2 without nesting benow an AoS 3 are not implemented in the AL yet). If this construct is needed, set the field as an AoS type 1 by setting a finite maxOccurs attribute'"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="$test_dynamic_scalars_nested_below_aos3">
                <xsl:with-param name="error_description" select="'Illegal metadata: this scalar field is marked as &quot;dynamic&quot;. Scalars cannot be dynamic unless placed under an AoS type 3'"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="$test_no_structures_with_type">
                <xsl:with-param name="error_description" select="'Illegal metadata: this structure field should NOT have a &quot;type&quot; attribute (constant/static/dynamic)'"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="$test_aos3_leaves_dynamic">
                <xsl:with-param name="error_description" select="'Illegal metadata: all leaves below an AoS3 must be dynamic'"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="$test_non_empty_timebasepath">
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
