public/index.xml: pages/*.md.rkt pages/*.rkt posts/*.md.rkt posts/*.rkt *.md.rkt *.rkt
	racket -y main.rkt

.PHONY: clean
clean:
	rm -fr public

.PHONY: deploy
deploy: public/index.xml
	rsync -avz --delete public/* defn:~/www
