PANDOC       = pandoc
TEMPLATE     = templates/main.html
SITEMETA     = site.yaml
WRITINGS_META = writings.yaml
OUT          = dist

PAGES  = $(wildcard pages/*.md) $(wildcard pages/writings/*.md)
HTML   = $(patsubst pages/%.md,$(OUT)/%.html,$(PAGES))
ASSETS = $(patsubst assets/%,$(OUT)/%,$(shell find assets -type f))

# Old flat post URLs kept alive as meta-refresh stubs to /writings/.
MOVED          = heredocs-mental-model when-cat-is-not-cat git-diff-three-questions bash-without-if building-this-site
REDIRECT_HTML  = $(addprefix $(OUT)/,$(addsuffix .html,$(MOVED)))
# Old /articles/ URLs kept alive as meta-refresh stubs to /writings/.
LEGACY_HTML    = $(addprefix $(OUT)/articles/,$(addsuffix .html,$(MOVED)))

all: $(HTML) $(ASSETS) $(REDIRECT_HTML) $(LEGACY_HTML) $(OUT)/articles.html $(OUT)/sitemap.xml $(OUT)/feed.xml

$(WRITINGS_META): $(PAGES) scripts/gen-writings.sh
	sh scripts/gen-writings.sh $@

# Pages with a date: in frontmatter (= writings) also get a table of contents.
$(OUT)/%.html: pages/%.md $(TEMPLATE) $(SITEMETA) $(WRITINGS_META)
	@mkdir -p $(@D)
	$(PANDOC) $< --template $(TEMPLATE) --standalone --highlight-style=monochrome \
	  $$(awk '/^---$$/{n++; if(n==2) exit} /^date:/{printf "--toc --toc-depth=3"; exit}' $<) \
	  -M pageurl="$(if $(filter index,$*),,$*.html)" \
	  --metadata-file=$(SITEMETA) --metadata-file=$(WRITINGS_META) -o $@
	@active="$(if $(filter index,$*),/,/$(firstword $(subst /, ,$*)).html)"; \
	sed -i "s|<a href=\"$$active\">|<a class=\"active\" href=\"$$active\">|" $@

$(REDIRECT_HTML) $(LEGACY_HTML): | $(OUT)
	@mkdir -p $(@D)
	printf '<!DOCTYPE html>\n<meta charset="utf-8" />\n<meta http-equiv="refresh" content="0; url=/writings/%s" />\n<link rel="canonical" href="https://erdivartanovich.github.io/writings/%s" />\n<title>Redirecting\xe2\x80\xa6</title>\n<p>Moved to <a href="/writings/%s">/writings/%s</a>.</p>\n' $(@F) $(@F) $(@F) $(@F) > $@

$(OUT)/articles.html: | $(OUT)
	printf '<!DOCTYPE html>\n<meta charset="utf-8" />\n<meta http-equiv="refresh" content="0; url=/writings.html" />\n<link rel="canonical" href="https://erdivartanovich.github.io/writings.html" />\n<title>Redirecting\xe2\x80\xa6</title>\n<p>Moved to <a href="/writings.html">/writings.html</a>.</p>\n' > $@

$(OUT)/%: assets/% | $(OUT)
	@mkdir -p $(@D)
	cp $< $@

$(OUT)/sitemap.xml: $(PAGES) scripts/gen-sitemap.sh $(SITEMETA) | $(OUT)
	sh scripts/gen-sitemap.sh $@

$(OUT)/feed.xml: $(PAGES) scripts/gen-feed.sh $(SITEMETA) | $(OUT)
	sh scripts/gen-feed.sh $@

$(OUT):
	mkdir -p $(OUT)

clean:
	rm -rf $(OUT) $(WRITINGS_META)

.PHONY: all clean
