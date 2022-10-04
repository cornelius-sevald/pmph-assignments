report.pdf: report.md
	pandoc --from markdown \
	       --to pdf -o $@ $<

report.html: report.md
	pandoc --shift-heading-level-by=-1 \
	       --mathml \
	       --from markdown \
	       --to html -o $@ $<

.PHONY: all clean

all: report.pdf report.html

clean:
	rm -f report.pdf
	rm -f report.html
