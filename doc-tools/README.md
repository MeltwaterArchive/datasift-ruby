# Generating documentation from sources

This document exists for the benefit of anyone who wants to generate a new
sets of docs for the GitHub pages for this project.

1. Make sure that git is installed on your system:

    `git --version`

    If you are using Ubuntu, you can install it using this command:

    `sudo apt-get install git`

2. Make sure that the documentation generator environment is installed on your system.  You can install it using these commands:

    `sudo apt-get install ruby`

    `sudo apt-get install rubygems`

    `sudo gem install rdoc`

3. Create a temporary directory

    `mkdir tmp`

4. Change the current working directory

    `cd tmp`

5. Clone the DataSift Ruby Client Library into master directory

    `git clone https://github.com/datasift/datasift-ruby.git master`

6. Clone the DataSift Ruby Client Library into gh-pages directory

    `git clone https://github.com/datasift/datasift-ruby.git gh-pages`

7. Change the current working directory to gh-pages

    `cd gh-pages`

8. Switch to the gh-pages branch

    `git checkout gh-pages`

9. Change the working directory to doc-tools

    `cd doc-tools`

10. Run autodoc generator tools

    `sh ./make-docs.sh`

11. Change to the parent directory

    `cd ..`

12. Stage new documentation in git

    `git add *.html`

    `git add *.css`

13. Commit the new documentation

    `git commit -m "Include a meaningful description here."`

14. Push changes to github

    `git push origin gh-pages`

15. That's it! you can delete the temporary directory now.

    `cd ../..`

    `rm -rf tmp`

