env = dnf
cipherAlgo = AES256
hashAlgo = SHA256

setup:
	sudo ${env} install gpg
	sudo ${env} install tree
	[ -d documents ] || mkdir -p documents
	[ -d packaged ] || mkdir -p packaged
	sudo chown root:root ./packaged
	sudo chmod 600 ./packaged

initfile: 
	@read -p "Enter Username: " usrname; \
	echo "Name-Real: $$usrname" >> .config
	@read -p "Enter Email Address: " mail; \
	echo "Name-Email: $$mail" >> .config
	@read -p "Enter Password: " pwd; \
	echo "Passphrase: $$pwd" >> .config
	@read -p "Enter Comment: " comment; \
	echo "Name-Comment: $$comment" >> .config

encryptdocument:
	@read -p "Enter Document Name: " doc; \
	mkdir -p ./packaged/$$doc; \
	gpg --print-md ${hashAlgo} ./documents/$$doc > ./packaged/$$doc/.hash; \
	gpg --output ./packaged/$$doc/$$doc.enc --no-symkey-cache --symmetric --cipher-algo ${cipherAlgo} ./documents/$$doc; \
	zip -r ./packaged/$$doc.zip ./packaged/$$doc; \
	rm -rf ./packaged/$$doc/; \
	rm -f ./documents/$$doc
getdocument:
	@read -p "Enter Document Name: " doc; \
	mkdir -p ./documents/$$doc; \
	unzip -j ./packaged/$$doc.zip -d ./documents/$$doc; \
	gpg --output ./documents/$$doc/$$doc --no-symkey-cache --decrypt ./documents/$$doc/$$doc.enc; \
	mv ./documents/$$doc/$$doc ./; \
	rm -rf ./documents/$$doc/; \
	mv $$doc ./documents

savepassword:
	touch ./.config
	@read -p "Password For : " application; \
	mkdir -p ./packaged/$$application; \
	make initfile; \
	mv .config ./packaged/$$application; \
	gpg --print-md ${hashAlgo} ./packaged/$$application/.config > ./packaged/$$application/.hash; \
	gpg --output ./packaged/$$application/config.enc --no-symkey-cache --symmetric --cipher-algo ${cipherAlgo} ./packaged/$$application/.config; \
	rm -f ./packaged/$$application/.config; \
	zip -r ./packaged/$$application.zip ./packaged/$$application; \
	rm -rf ./packaged/$$application/
getpassword:
	@read -p "Looking for ? " application; \
	unzip -j ./packaged/$$application.zip -d ./; \
	gpg --output ./.config  --no-symkey-cache --decrypt ./config.enc; \
	cat ./.config; \
	rm -f ./.config
	rm -f ./.hash
	rm -f ./config.enc

uninstall:
	sudo ${env} remove tree