all: notes.pdf cheatsheet.pdf

notes.pdf: notes.md
	md_to_pdf.sh notes.md notes.pdf

cheatsheet.pdf: cheatsheet.md
	md_to_pdf.sh --no-toc cheatsheet.md cheatsheet.pdf

clean:
	rm notes.pdf
	rm cheatsheet.pdf
