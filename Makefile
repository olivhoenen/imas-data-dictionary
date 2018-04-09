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

dd_data_dictionary.xml: %: %.xsd %.xsl
	$(xslt2proc)

html_documentation/html_documentation.html: dd_data_dictionary.xml dd_data_dictionary_html_documentation.xsl
	$(xslt2proc)

IDSNames.txt dd_data_dictionary_validation.txt: %: dd_data_dictionary.xml %.xsl
	$(xsltproc)

# Generic Dependencies
# Note: be sure to set CLASSPATH='/path/to/saxon9he.jar;...' in your environment
SAXONICAJAR=$(wildcard $(filter %saxon9he.jar,$(subst :, ,$(CLASSPATH))))
# Canned recipes
define xsltproc
@# Expect prerequisites: <xmlfile> <xslfile>
xsltproc $(word 2,$^) $< > $@ || { rm -f $@ ; exit 1 ;}
endef
define xslt2proc
@# Expect prerequisites: <xmlfile> <xslfile>
$(if $(SAXONICAJAR),,$(error Invalid /path/to/saxon9he.jar in CLASSPATH. Forgot to load module?))
java net.sf.saxon.Transform -t -warnings:fatal -s:$< -xsl:$(word 2,$^) -o:$@ || { rm -f $@ ; exit 1 ; }
endef

