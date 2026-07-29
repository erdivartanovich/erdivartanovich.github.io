PANDOC       = pandoc
TEMPLATE     = templates/main.html
SITEMETA     = site.yaml
ARTICLESMETA = articles.yaml
OUT          = dist

PAGES  = $(wildcard pages/*.md) $(wildcard pages/articles/*.md)
HTML   = $(patsubst pages/%.md,$(OUT)/%.html,$(PAGES))
ASSETS = $(patsubst assets/%,$(OUT)/%,$(shell find assets -type f))

# Old flat post URLs kept alive as meta-refresh stubs to /articles/.
MOVED          = heredocs-mental-model when-cat-is-not-cat git-diff-three-questions bash-without-if building-this-site
REDIRECT_HTML  = $(addprefix $(OUT)/,$(addsuffix .html,$(MOVED)))

all: $(HTML) $(ASSETS) $(REDIRECT_HTML) $(OUT)/sitemap.xml $(OUT)/feed.xml

$(ARTICLESMETA): $(PAGES) scripts/gen-articles.sh
	sh scripts/gen-articles.sh $@

# Pages with a date: in frontmatter (= articles) also get a table of contents.
$(OUT)/%.html: pages/%.md $(TEMPLATE) $(SITEMETA) $(ARTICLESMETA)
	@mkdir -p $(@D)
	$(PANDOC) $< --template $(TEMPLATE) --standalone --highlight-style=monochrome \
	  $$(awk '/^---$$/{n++; if(n==2) exit} /^date:/{printf "--toc --toc-depth=3"; exit}' $<) \
	  -M pageurl="$(if $(filter index,$*),,$*.html)" \
	  --metadata-file=$(SITEMETA) --metadata-file=$(ARTICLESMETA) -o $@

$(REDIRECT_HTML): | $(OUT)
	printf '<!DOCTYPE html>\n<meta charset="utf-8" />\n<meta http-equiv="refresh" content="0; url=/articles/%s" />\n<link rel="canonical" href="https://erdivartanovich.github.io/articles/%s" />\n<title>Redirecting\xe2\x80\xa6</title>\n<p>Moved to <a href="/articles/%s">/articles/%s</a>.</p>\n' $(@F) $(@F) $(@F) $(@F) > $@

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
	rm -rf $(OUT) $(ARTICLESMETA)

.PHONY: all clean
