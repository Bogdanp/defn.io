public/index.xml: pages/*.rkt posts/*.rkt *.rkt
	racket -y main.rkt

.PHONY: clean
clean:
	rm -fr public

.PHONY: deploy
deploy: public/index.xml
	rsync -avz --delete public/* defn:~/www
