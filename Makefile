
include Makefile.common

DD_FILES=dd_data_dictionary.xml IDSDef.xml IDSNames.txt dd_data_dictionary_validation.txt
HTMLDOC_FILES=$(wildcard $(addprefix html_documentation/,*.html css/*.css img/*.png js/*js))
HTMLDOC_FILES_IDS=$(wildcard $(addprefix html_documentation/,$(addsuffix /*.*,$(shell cat IDSNames.txt))))

.PHONY: all clean test install
all: dd htmldoc test

clean: # dd_clean htmldoc_clean
	$(if $(wildcard .gitignore),git clean -f -X -d,$(RM) -f $(DD_FILES))

test: dd_data_dictionary_validation.txt
	grep -i Error $< >&2 && exit 1 || grep valid $<

install: dd_install htmldoc_install

.PHONY: htmldoc htmldoc_clean htmldoc_install
htmldoc: IDSNames.txt html_documentation/html_documentation.html
htmldoc_clean:
	$(if $(wildcard .gitignore),git clean -f -X -d -- html_documentation,$(warning This target depends on .gitignore))
htmldoc_install: htmldoc
	$(mkdir_p) $(addprefix $(htmldir)/imas/,$(sort $(dir $(HTMLDOC_FILES:html_documentation/%=%))))
	$(INSTALL_DATA) $(filter %.html,$(HTMLDOC_FILES)) $(htmldir)/imas/
	$(INSTALL_DATA) $(filter %.css,$(HTMLDOC_FILES)) $(htmldir)/imas/css
	$(INSTALL_DATA) $(filter %.js,$(HTMLDOC_FILES)) $(htmldir)/imas/js
	$(INSTALL_DATA) $(filter %.png,$(HTMLDOC_FILES)) $(htmldir)/imas/img
	$(mkdir_p) $(addprefix $(htmldir)/imas/,$(sort $(dir $(HTMLDOC_FILES_IDS:html_documentation/%=%))))
	$(foreach idsdir,$(sort $(dir $(HTMLDOC_FILES_IDS))),\
		$(INSTALL_DATA) $(idsdir)/* $(htmldir)/imas/$(idsdir:html_documentation/%=%) ;\
	)

.PHONY: dd dd_clean dd_install
dd: $(DD_FILES)
dd_clean:
	$(if $(wildcard .gitignore),git clean -f -X -- *.*,$(warning This target depends on .gitignore))
dd_install: $(DD_FILES)
	$(mkdir_p) $(includedir)
	$(INSTALL_DATA) $(filter-out IDSDef.xml,$^) $(includedir)
	ln -sf dd_data_dictionary.xml $(includedir)/IDSDef.xml

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
java net.sf.saxon.Transform -threads:4 -t -warnings:fatal -s:$< -xsl:$(word 2,$^) > $@ || { rm -f $@ ; exit 1 ; }
endef

