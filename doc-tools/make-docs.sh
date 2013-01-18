#!/bin/bash
# -v

export BASE_DIR="`pwd`/"

source ${BASE_DIR}sub/make-docs-util-defs.sh
export BASE_DIR="/tmp/$(basename $0).$$.tmp/"
initialise $*

### Ruby-specific parameters
parameters "ruby"

### installation of Ruby-specific tools
message 'installing tools'
sudo apt-get install git
sudo apt-get install ruby
sudo apt-get install rubygems
sudo gem install rdoc

pre_build

### Ruby-specific build steps

#message "preparing to build documents"

(
	message "building documents"
	cd ${CODE_DIR} ; stop_on_error
	rdoc --title 'DataSift Ruby Client Library' ; stop_on_error
) || error "stopped parent"
(
	message "copying documents"
	cd ${GH_PAGES_DIR} ; stop_on_error
	cp -a ../code/doc/* . ; stop_on_error
) || error "stopped parent"

(
	cd ${GH_PAGES_DIR} ; stop_on_error
	python doc-tools/modifyfrontpage.py -i index.html -p doc-tools/frontpagepatch.txt > _new_index.html ; stop_on_error
	mv _new_index.html index.html ; stop_on_error
	git add *
) || error "stopped parent"

post_build

finalise
