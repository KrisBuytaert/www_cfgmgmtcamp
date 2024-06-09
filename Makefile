#!Makefile

HUGO=hugo-extended

.PHONY: build netlify serve draft clean debug

all: build compress

build:
	$(HUGO) --environment=production --minify --enableGitInfo --forceSyncStatic --templateMetrics

compress:
	@rm -rf public/feed.xml
	@find public/*/posts/ -name 'feed.xml' -exec sh -c "cat {} >> public/feed.xml" \;
	@find public/ -name '*.html' ! -name '*.gz' -type f -exec sh -c "gzip -c -9 < {} > {}.gz" \;
	@find public/ -name '*.xml' ! -name '*.gz' -type f -exec sh -c "gzip -c -9 < {} > {}.gz" \;
	@find public/ -name '*.css' ! -name '*.gz' -type f -exec sh -c "gzip -c -9 < {} > {}.gz" \;
	@find public/ -name '*.js' ! -name '*.gz' -type f -exec sh -c "gzip -c -9 < {} > {}.gz" \;

giggity:
	@gzip -9 -c static/schedule/giggity.json > static/schedule/giggity.json.gz
	@echo "" > public/schedule/schedule.ics
	@test -s public/schedule/monday/index.ics && head -n -1 public/schedule/monday/index.ics >> public/schedule/schedule.ics
	@test -s public/schedule/tuesday/index.ics && tail -n +9 public/schedule/tuesday/index.ics >> public/schedule/schedule.ics
	@sed -e '/^$$/d' -i public/schedule/schedule.ics
	@unix2dos public/schedule/schedule.ics public/schedule/schedule.ics

qrcode:
	@qrencode -t SVG -o static/schedule/giggity.svg -l H -Sv 3 < static/schedule/giggity.json
	@qrencode -t SVG -o static/schedule/ical.svg -l H 'https://cfgmgmtcamp.eu/schedule/schedule.ics'

netlify:
	$(MAKE) HUGO=hugo build

debug:
	$(HUGO) --environment=development --minify --enableGitInfo --forceSyncStatic --debug --logLevel debug --templateMetrics --templateMetricsHints

travis:
	$(MAKE) HUGO=./hugo build

test:
	$(HUGO) --environment=development --minify --enableGitInfo --forceSyncStatic --templateMetrics --templateMetricsHints --verbose

draft:
	$(HUGO) --minify --buildDrafts --buildFuture --buildExpired

serve:
	$(HUGO) server --environment=development --watch --noHTTPCache --disableFastRender --forceSyncStatic --enableGitInfo --renderToMemory --templateMetrics --templateMetricsHints

servedraft:
	$(HUGO) server --environment=development --buildFuture --buildExpired --noHTTPCache --disableFastRender

clean:
	@rm -rf public/
