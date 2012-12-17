#!/bin/sh -v
if [ -z "$1" ]; then
    echo 'You must run this script with branch name as its argument, e.g.'
    echo 'sh ./make-docs.sh master'
    exit
fi
echo 'working on branch '$1
echo 'installing tools'
sudo apt-get install git
sudo apt-get install ruby
sudo apt-get install rubygems
sudo gem install rdoc
echo 'making temporary directory'
mkdir tmp
cd tmp
echo 'cloning repos'
git clone https://github.com/datasift/datasift-ruby.git code
git clone https://github.com/datasift/datasift-ruby.git gh-pages
cd code
git checkout $1
cd ..
cd gh-pages
git checkout gh-pages

cd ../code
rdoc --title 'DataSift Ruby Client Library'
cd ../gh-pages
cp -a ../code/doc/* .

git add *
git commit -m 'Updated to reflect the latest changes to '$1
echo 'You are going to update the gh-pages branch to reflect the latest changes to '$1
git push origin gh-pages
echo 'finished'
