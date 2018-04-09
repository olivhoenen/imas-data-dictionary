# FIXME: Dependency on Saxon can possibly be replaced by xslt?
# Get Saxon here: http://sourceforge.net/projects/saxon/files/Saxon-HE/9.6/

# Note: be sure to set CLASSPATH='/path/to/saxon9he.jar;...' in your environment
SAXONICAJAR=$(wildcard $(filter %saxon9he.jar,$(subst :, ,$(CLASSPATH))))

TARGETS=dd_data_dictionary.xml IDSDef.xml IDSNames.txt dd_data_dictionary_validation.txt html_documentation/html_documentation.html test

.PHONY: all clean test
all: $(TARGETS)

clean:
	$(if $(wildcard .git/config),git clean -f -X,$(RM) -f $(TARGETS))

test: dd_data_dictionary_validation.txt
	grep -i Error $< >&2 && exit 1 || grep valid $<

# Compatibility target
IDSDef.xml: dd_data_dictionary.xml
	ln -sf $< $@

IDSNames.txt dd_data_dictionary_validation.txt: %: %.xsl dd_data_dictionary.xml
	xsltproc $^ > $@ || { rm -f $@ ; exit 1 ;}

html_documentation/html_documentation.html: dd_data_dictionary.xml dd_data_dictionary_html_documentation.xsl $(SAXONICAJAR)
	java net.sf.saxon.Transform -t -warnings:fatal -s:dd_data_dictionary.xml -xsl:dd_data_dictionary_html_documentation.xsl || { rm -f $@ ; exit 1 ; }
#	xsltproc dd_data_dictionary_html_documentation.xsl dd_data_dictionary.xml > html_documentation/html_documentation.html

# check if saxon9he.jar is in the CLASSPATH
ifeq (,$(SAXONICAJAR))
$(info CLASSPATH is: $(CLASSPATH))
$(error Invalid /path/to/saxon9he.jar in CLASSPATH)
endif

