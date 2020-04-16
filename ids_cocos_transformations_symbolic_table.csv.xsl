<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:yaslt="http://www.mod-xslt2.com/ns/2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" extension-element-prefixes="yaslt" xmlns:fn="http://www.w3.org/2005/02/xpath-functions" xmlns:local="http://www.example.com/functions/local" exclude-result-prefixes="local xs">
<xsl:output method="text" encoding="UTF-8"/>
<!-- Voir pourquoi cette syntaxe ne fonctionne pas pour désigner le fichier cible ... cas HTML seulement ? > <xsl:result-document href="ids_cocos_transformations_symbolic_table.csv"> -->
<xsl:template match="/*">%leaf_name;label_transformation;transformation_expression;leaf_name_aos_indices;length_i;length_j
%;;;;set length to '[1]' for i or j so if no {i} or {j} in leaf_name_aos_indices do the whole just once;
<xsl:apply-templates select="//field[@cocos_leaf_name_aos_indices and not(contains(@name,'_error_')) and ancestor::IDS]">
</xsl:apply-templates>
<!-- skipping error bar nodes, which are handled directly by the coco_transform routine, since this creates otherwise differences of treatment between simple leaves and e.g. signal type structures-->
</xsl:template>

<xsl:template name ="print_cocos_line" match="field">
<xsl:choose>
<xsl:when test="ancestor::field[@cocos_alias]">
<xsl:value-of select="replace(@cocos_leaf_name,string(ancestor::field[@cocos_alias]/@cocos_alias[1]),string(ancestor::field[@cocos_alias]/@cocos_replace[1]))"/>;<xsl:value-of select="@cocos_label_transformation"/>;<xsl:value-of select="@cocos_transformation_expression"/>;<xsl:choose><xsl:when test="ancestor::field[@cocos_replace_leaf_name_aos_indices]"><xsl:value-of select="replace(@cocos_leaf_name_aos_indices,string(ancestor::field[@cocos_alias]/@cocos_alias[1]),string(ancestor::field[@cocos_alias]/@cocos_replace_leaf_name_aos_indices[1]))"/>;<xsl:value-of select="substring-before(ancestor::field[@cocos_alias]/@cocos_replace_leaf_name_aos_indices[1],'{i}')"/>;<xsl:choose><xsl:when test="contains(ancestor::field[@cocos_alias]/@cocos_replace_leaf_name_aos_indices[1],'{j}')"><xsl:value-of select="substring-before(ancestor::field[@cocos_alias]/@cocos_replace_leaf_name_aos_indices[1],'{j}')"/></xsl:when><xsl:otherwise><xsl:value-of select="replace(@cocos_length_j,string(ancestor::field[@cocos_alias]/@cocos_alias[1]),string(ancestor::field[@cocos_alias]/@cocos_replace[1]))"/></xsl:otherwise></xsl:choose></xsl:when><xsl:otherwise><xsl:value-of select="replace(@cocos_leaf_name_aos_indices,string(ancestor::field[@cocos_alias]/@cocos_alias[1]),string(ancestor::field[@cocos_alias]/@cocos_replace[1]))"/>;<xsl:value-of select="replace(@cocos_length_i,string(ancestor::field[@cocos_alias]/@cocos_alias[1]),string(ancestor::field[@cocos_alias]/@cocos_replace[1]))"/>;<xsl:value-of select="replace(@cocos_length_j,string(ancestor::field[@cocos_alias]/@cocos_alias[1]),string(ancestor::field[@cocos_alias]/@cocos_replace[1]))"/></xsl:otherwise></xsl:choose>
<xsl:text>
</xsl:text>
</xsl:when>
<xsl:otherwise>
<xsl:choose>
<xsl:when test="contains(@cocos_leaf_name_aos_indices,'{i}')">
<xsl:choose>
<xsl:when test="contains(@cocos_leaf_name_aos_indices,'{j}')">  <!-- Case with two AoS indices in @cocos_leaf_name_indices-->
<xsl:value-of select="concat(substring-before(@cocos_leaf_name_aos_indices,'{i}'),substring-after(substring-before(@cocos_leaf_name_aos_indices,'{j}'),'{i}'),substring-after(@cocos_leaf_name_aos_indices,'{j}'))"/>;<xsl:value-of select="@cocos_label_transformation"/>;<xsl:value-of select="@cocos_transformation_expression"/>;<xsl:value-of select="@cocos_leaf_name_aos_indices"/>;<xsl:value-of select="substring-before(@cocos_leaf_name_aos_indices,'{i}')"/>;<xsl:value-of select="substring-before(@cocos_leaf_name_aos_indices,'{j}')"/>
<xsl:text>
</xsl:text>
</xsl:when>
<xsl:otherwise> <!-- Case with a signle AoS index in @cocos_leaf_name_indices-->
<xsl:value-of select="concat(substring-before(@cocos_leaf_name_aos_indices,'{i}'),substring-after(@cocos_leaf_name_aos_indices,'{i}'))"/>;<xsl:value-of select="@cocos_label_transformation"/>;<xsl:value-of select="@cocos_transformation_expression"/>;<xsl:value-of select="@cocos_leaf_name_aos_indices"/>;<xsl:value-of select="substring-before(@cocos_leaf_name_aos_indices,'{i}')"/>;[1]
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:otherwise> <!-- Case without AoS index in @cocos_leaf_name_indices-->
<xsl:value-of select="@cocos_leaf_name_aos_indices"/>;<xsl:value-of select="@cocos_label_transformation"/>;<xsl:value-of select="@cocos_transformation_expression"/>;<xsl:value-of select="@cocos_leaf_name_aos_indices"/>;[1];[1]
</xsl:otherwise>
</xsl:choose>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
</xsl:stylesheet>
