artifacts = notes.pdf lab.pdf

all: $(artifacts)

$(artifacts): %.pdf: %.md
	md_to_pdf.sh $< $@

clean:
	rm $(artifacts)
