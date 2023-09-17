all: notes.pdf

notes.pdf: $(wildcard img/notes/*.png)
	img_to_pdf.sh ./img/notes ./img/notes/bookmarks.ps notes.pdf

# es.pdf: $(wildcard es/*.png)
# 	img_to_pdf.sh ./es ./es/bookmarks.ps es.pdf

clean:
	rm notes.pdf
