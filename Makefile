#/usr/bin/sh
# Build Arabic stop word list files
DATA_DIR :=data/classified
RELEASES :=releases
BUILD :=$(RELEASES)/build
OUTPUT :=tests/output
SCRIPT :=scripts
VERSION=0.6
DOC="."
FORMAT:=csv
default: all
# Clean build files
clean:
	rm -f -r $(RELEASES)/*
backup: 
	mkdir -p $(RELEASES)/backup$(VERSION)
	#~ mv $(RELEASES)/*.bz2 $(RELEASES)/backup$(VERSION)
#create all files 
all: ods release


# Publish to github
publish:
	git push origin master 

ods: 
	#Generate csv files from ODS
	libreoffice --headless --convert-to "csv:Text - txt - csv (StarCalc):9,34,UTF8" --outdir $(OUTPUT)/ $(DATA_DIR)/stopwords.ods

#Package files
release: backup format pack


format:py sql csv
#~ 	#Generate Specific format SQL and python
#~ 	# all forms
#~ 	python $(SCRIPT)/generate_stopwords_format.py -v $(VERSION) -f $(OUTPUT)/stopwords.csv           > $(OUTPUT)/stopwordsallforms.csv 
#~ 	python $(SCRIPT)/generate_stopwords_format.py -f $(OUTPUT)/stopwords.csv -o py >$(OUTPUT)/stopwordsallforms.py
#~ 	python $(SCRIPT)/generate_stopwords_format.py -f $(OUTPUT)/stopwords.csv -o sql    >$(OUTPUT)/stopwordsallforms.sql
#~ 	# classified
#~ 	python $(SCRIPT)/generate_stopwords_format.py -A -f $(OUTPUT)/stopwords.csv           > $(OUTPUT)/stopwords_classified.csv 
#~ 	python $(SCRIPT)/generate_stopwords_format.py -A -f $(OUTPUT)/stopwords.csv -o py > $(OUTPUT)/stopwords_classified.py
#~ 	python $(SCRIPT)/generate_stopwords_format.py -A -f $(OUTPUT)/stopwords.csv -o sql    > $(OUTPUT)/stopwords_classified.sql

py: FORMAT:=py
sql: FORMAT:=sql
csv: FORMAT:=csv

py sql csv:
	#Generate Specific format CSV SQL and python
	echo " Generate ${FORMAT} version"
	# all forms
#~ 	python $(SCRIPT)/generate_stopwords_format.py --version $(VERSION) -f $(OUTPUT)/stopwords.csv -o ${FORMAT}    >$(OUTPUT)/stopwordsallforms.${FORMAT}
#~ 	# classified
#~ 	python $(SCRIPT)/generate_stopwords_format.py --version $(VERSION) -A -f $(OUTPUT)/stopwords.csv -o ${FORMAT}    > $(OUTPUT)/stopwords_classified.${FORMAT}
	python $(SCRIPT)/generate_stopwords_forms.py --version $(VERSION) -f $(OUTPUT)/stopwords.csv -o ${FORMAT}    >$(OUTPUT)/stopwordsallforms.${FORMAT}
	# classified
	python $(SCRIPT)/generate_stopwords_forms.py --version $(VERSION) -A -f $(OUTPUT)/stopwords.csv -o ${FORMAT}    > $(OUTPUT)/stopwords_classified.${FORMAT}

#~ csv:
#~ 	python $(SCRIPT)/generate_stopwords_format.py --version $(VERSION) -f $(OUTPUT)/stopwords.csv           > $(OUTPUT)/stopwordsallforms.csv 
#~ 	# classified
#~ 	python $(SCRIPT)/generate_stopwords_format.py -A -f $(OUTPUT)/stopwords.csv           > $(OUTPUT)/stopwords_classified.csv 


#packaging 

pack:
	#doc
	mkdir -p $(BUILD)	
	cp -f $(DOC)/README.md $(BUILD)
	cp -f $(DOC)/LICENSE $(BUILD)
	cp -f $(DOC)/AUTHORS $(BUILD)
	#~ #classified
	#~ mkdir -p $(BUILD)/classified
	#~ cp -f $(OUTPUT)/stopwords.csv $(BUILD)/classified/
	#python
	mkdir -p $(BUILD)/python/stopwords
	cp $(OUTPUT)/stopwordsallforms.py $(BUILD)/python/stopwords
	cp $(OUTPUT)/stopwords_classified.py $(BUILD)/python/stopwords
	# sql
	mkdir -p $(BUILD)/sql
	cp -f $(OUTPUT)/stopwordsallforms.sql $(BUILD)/sql/
	cp -f $(OUTPUT)/stopwords_classified.sql $(BUILD)/sql/
	# csv
	mkdir -p $(BUILD)/csv
	cp -f $(OUTPUT)/stopwordsallforms.csv $(BUILD)/csv/
	cp -f $(OUTPUT)/stopwords_classified.csv $(BUILD)/csv/
	#zip
	cd $(BUILD) && tar cfj arabicstopwords.$(VERSION).tar.bz2 * 
	mv $(BUILD)/arabicstopwords.$(VERSION).tar.bz2 $(RELEASES)/

