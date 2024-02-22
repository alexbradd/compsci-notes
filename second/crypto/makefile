artifacts = notes.pdf

all: $(artifacts)

$(artifacts): %.pdf: %.md
	md_to_pdf.sh $< $@

clean:
	rm $(artifacts)
