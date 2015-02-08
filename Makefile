# FIXME: Dependency on Saxon can possibly be replaced by xslt?
# Get Saxon here: http://sourceforge.net/projects/saxon/files/Saxon-HE/9.6/

# SAXONICA_DIR= $(IMAS_HOME)/saxonica
# SAXONICA_DIR is to be set in environment 

all: IDSDef.xml validation_report.html html_documentation/html_documentation.html
	
clean:
	rm -f IDSDef.xml validation_report.html html_documentation/html_documentation.html

IDSDef.xml: dd_physics_data_dictionary.xsd ./*/*.xsd xsd_2_IDSDef.xsl
	java -cp $(SAXONICA_DIR)/saxon9he.jar net.sf.saxon.Transform -t -s:dd_physics_data_dictionary.xsd -xsl:xsd_2_IDSDef.xsl -o:IDSDef.xml

validation_report.html: IDSDef.xml IDSDef_validation.xsl
	xsltproc IDSDef_validation.xsl IDSDef.xml > validation_report.html

html_documentation/html_documentation.html: IDSDef.xml IDSDef_2_HTMLDocumentation.xsl
	xsltproc IDSDef_2_HTMLDocumentation.xsl IDSDef.xml > html_documentation/html_documentation.html

