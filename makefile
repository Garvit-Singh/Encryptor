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

packdocument:
	touch ./.config
	@read -p "Information For : " application; \
	mkdir -p ./packaged/$$application; \
	make initfile; \
	mv .config ./packaged/$$application; \
	gpg --print-md ${hashAlgo} ./packaged/$$application/.config > ./packaged/$$application/hash; \
	gpg --output ./packaged/$$application/config.enc --no-symkey-cache --symmetric --cipher-algo ${cipherAlgo} ./packaged/$$application/.config; \
	rm -f ./packaged/$$application/.config; \
	zip -r ./packaged/$$application.zip ./packaged/$$application; \
	rm -rf ./packaged/$$application/
unpackdocument:
	@read -p "Looking for ? " application; \
	unzip -j ./packaged/$$application.zip -d ./documents; \
	gpg --output ./documents/.config  --no-symkey-cache --decrypt ./documents/config.enc; \
	cat ./documents/.config; \
	rm -rf ./documents/

uninstall:
	sudo ${env} remove tree