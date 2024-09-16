#!/bin/bash

[[ ! -d docs ]] && {
	echo ".docs/ not found"
	exit 0
}

rm -f docs/*.html
for source in *.md; do
	output="docs/${source%.md}.html"
	echo "${source}" "${output}"

	pandoc --no-highlight \
		--from gfm+gfm_auto_identifiers \
		--to html5 \
		--template build.html \
		--lua-filter build.lua \
		--variable "ispage:$([[ "$source" != "index.md" ]] && echo "true")" \
		--output "$output" "$source"
done
