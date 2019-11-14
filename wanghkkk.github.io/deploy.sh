#!/bin/sh
hexo clean && \
	hexo gen && \
	hexo deploy
