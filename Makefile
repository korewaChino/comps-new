XMLINFILES=$(wildcard *.xml.in)
XMLFILES = $(patsubst %.xml.in,%.xml,$(XMLINFILES))

all: po $(XMLFILES)

po: $(XMLINFILES)
	make -C po -f Makefile || exit 1

clean:
	@rm -fv *~ *.xml

validate: $(XMLFILES) comps.rng
	# Run xmllint on each file and exit with non-zero if any validation fails
	RES=0; for f in $(XMLFILES); do \
		xmllint --noout --relaxng comps.rng $$f; \
		RES=$$(($$RES + $$?)); \
	done; exit $$RES

%.xml: %.xml.in
	@xmllint --noout $<
	@if test ".$(CLEANUP)" == .yes; then xsltproc --novalid -o $< comps-cleanup.xsl $<; fi
	./update-comps $@
	@if [ "$@" == "$(RAWHIDECOMPS)" ] ; then \
		cat $(RAWHIDECOMPS) | sed 's/redhat-release/rawhide-release/g' > comps-rawhide.xml ; \
	fi

# Add an easy alias to generate a rawhide comps file
comps-rawhide.xml comps-rawhide: comps-f26.xml
	@mv comps-f26.xml comps-rawhide.xml
