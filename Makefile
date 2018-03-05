# FIXME: Dependency on Saxon can possibly be replaced by xslt?
# Get Saxon here: http://sourceforge.net/projects/saxon/files/Saxon-HE/9.6/

# Note: be sure to set CLASSPATH='/path/to/saxon9he.jar;...' in your environment
SAXONICAJAR=$(wildcard $(filter %saxon9he.jar,$(subst :, ,$(CLASSPATH))))

TARGETS=IDSDef.xml IDSNames.txt IDSDef_validation.txt html_documentation/html_documentation.html test

.PHONY: all clean test
all: $(TARGETS)

clean:
	$(if $(wildcard .git/config),git clean -f -X,$(RM) -f $(TARGETS))

test: IDSDef_validation.txt
	grep -i Error $< >&2 && exit 1 || grep valid $<

IDSDef.xml: %: %.xsd %.xsl $(SAXONICAJAR)
	java net.sf.saxon.Transform -t -warnings:fatal -s:$< -xsl:$(word 2,$^) -o:$@ || { rm -f $@ ; exit 1 ; }

IDSNames.txt IDSDef_validation.txt: %: %.xsl IDSDef.xml
	xsltproc $^ > $@ || { rm -f $@ ; exit 1 ;}

html_documentation/html_documentation.html: IDSDef.xml IDSDef_2_HTMLDocumentation.xsl $(SAXONICAJAR)
	java net.sf.saxon.Transform -t -warnings:fatal -s:IDSDef.xml -xsl:IDSDef_2_HTMLDocumentation.xsl || { rm -f $@ ; exit 1 ; }
#	xsltproc IDSDef_2_HTMLDocumentation.xsl IDSDef.xml > html_documentation/html_documentation.html

# check if saxon9he.jar is in the CLASSPATH
ifeq (,$(SAXONICAJAR))
$(info CLASSPATH is: $(CLASSPATH))
$(error Invalid /path/to/saxon9he.jar in CLASSPATH)
endif

