all: notes.pdf aca_cheatsheet.pdf

aca_cheatsheet.pdf: aca.tex
	pdflatex aca_cheatsheet.tex

notes.pdf: notes.md
	md_to_pdf.sh notes.md notes.pdf

clean:
	rm notes.pdf
	rm aca_cheatsheet.pdf
