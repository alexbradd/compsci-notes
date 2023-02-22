all: notes.pdf es.pdf

notes.pdf: notes.md
	md_to_pdf.sh notes.md notes.pdf

es.pdf: $(wildcard es/*.png)
	img_to_pdf.sh ./es ./es/bookmarks.ps es.pdf

clean:
	rm notes.pdf
	rm es.pdf
