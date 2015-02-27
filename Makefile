# FIXME: Dependency on Saxon can possibly be replaced by xslt?
# Get Saxon here: http://sourceforge.net/projects/saxon/files/Saxon-HE/9.6/

# Note: be sure to set CLASSPATH='/path/to/saxon9he.jar;...' in your environment
SAXONICAJAR=$(wildcard $(filter %saxon9he.jar,$(subst :, ,$(CLASSPATH))))

all: IDSDef.xml validation_report.html html_documentation/html_documentation.html

clean:
	rm -f IDSDef.xml validation_report.html html_documentation/html_documentation.html

IDSDef.xml: dd_physics_data_dictionary.xsd ./*/*.xsd xsd_2_IDSDef.xsl $(SAXONICAJAR)
	java net.sf.saxon.Transform -t -s:dd_physics_data_dictionary.xsd -xsl:xsd_2_IDSDef.xsl -o:IDSDef.xml

validation_report.html: IDSDef.xml IDSDef_validation.xsl
	xsltproc IDSDef_validation.xsl IDSDef.xml > validation_report.html

html_documentation/html_documentation.html: IDSDef.xml IDSDef_2_HTMLDocumentation.xsl
	xsltproc IDSDef_2_HTMLDocumentation.xsl IDSDef.xml > html_documentation/html_documentation.html

# check if saxon9he.jar is in the CLASSPATH
ifeq (,$(SAXONICAJAR))
$(error Invalid /path/to/saxon9he.jar in CLASSPATH)
endif

