#!/bin/sh
hugo
git add public
git commit -m "Deployed to gh-pages"
git subtree push --prefix public origin gh-pages
git push