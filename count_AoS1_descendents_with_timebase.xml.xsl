<?xml version="1.0" encoding="ISO-8859-1" standalone="yes"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./$GET[stylesheet]" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>
<!-- This stylesheet counts, from the derived dd_data_dictionary.xml file, for each top level static AoS (type 1), the number of dynamic nodes carrying a time base below it (i.e. outside of AoS type 3, which count only as one dynamic node because it's represented as a single MDS+ node (one time base).-->
<!-- This is used to generate the MDS+ model file with an optimal size, pre-setting all needed dynamic signals -->
<!-- The result is stored in an XML file, indicating for each top level static AoS the number of required dynamic descendents for the MDS+ model file -->
<xsl:stylesheet xmlns:yaslt="http://www.mod-xslt2.com/ns/2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" extension-element-prefixes="yaslt" xmlns:fn="http://www.w3.org/2005/02/xpath-functions" xmlns:local="http://www.example.com/functions/local" exclude-result-prefixes="local xs">
  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
  <!-- Function for multiplying the number of descendents with timebasepath attribute by the occurrence of the child AoS -->
  <xsl:function name="local:count-nodes" as="xs:integer">
    <xsl:param name="current" as="node()"/>
    <xsl:param name="level" as="xs:integer"/>
    <xsl:value-of select="$current/@maxoccur*count($current//field[@type='dynamic' and count(ancestor::field[@data_type='struct_array'])=$level])+$current/@maxoccur*sum($current//field[@data_type='struct_array' and not(@maxoccur='unbounded') and count(ancestor::field[@data_type='struct_array'])=$level]/local:count-nodes(.,$level+1))"/>
  </xsl:function>
  <xsl:template match="/*">
    <IDSs>
      <xsl:for-each select="IDS">
	<xsl:element name="IDS">
	  <xsl:attribute name="name" select="@name"/>
	  <xsl:apply-templates select=".//field[@data_type='struct_array' and not(@maxoccur='unbounded') and count(ancestor::field[@data_type='struct_array'])=0]"/>
	</xsl:element>
      </xsl:for-each>
    </IDSs>
  </xsl:template>
  <xsl:template name="count_dynamic_signals" match="field">
    <xsl:element name="AoS">
      <xsl:attribute name="path" select="@path"/>
      <xsl:attribute name="max_dynamic_nodes" select="local:count-nodes(.,xs:integer(number(1)))"/>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
