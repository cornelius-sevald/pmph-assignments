FIGURES=./task1_depgraph.png

report.pdf: report.md $(FIGURES)
	pandoc --from markdown \
	       --to pdf -o $@ $<

report.html: report.md $(FIGURES)
	pandoc --shift-heading-level-by=-1 \
	       --mathml \
	       --from markdown \
	       --to html -o $@ $<

.PHONY: all clean

all: report.pdf report.html

clean:
	rm -f report.pdf
	rm -f report.html
