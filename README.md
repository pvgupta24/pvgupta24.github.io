## Praveen Gupta

### Personal Website : pvgupta24.github.io
This repository contains the source code for my personal website and blog
hosted on github pages.

### Branches

#### [Master Branch](https://github.com/pvgupta24/pvgupta24.github.io/tree/master)
Compiled Code for Deployment

#### [Dev Branch](https://github.com/pvgupta24/pvgupta24.github.io/tree/dev)
Development Code

> This is built using jekyll and hydejack which works on poole - the jekyll butler.

### Setting up
- Setup using `https://hydejack.com/docs/`
- Launch dev server using `bundle exec jekyll serve`
- Generate a static build using `JEKYLL_ENV=production bundle exec jekyll build`

### Automated Deployment
This repository uses GitHub Actions for automated deployment:

1. Make changes to the site in the `dev` branch
2. Commit and push your changes to GitHub
3. GitHub Actions will automatically:
   - Build the Jekyll site with production settings
   - Deploy the built site to the `master` branch
   - The site will be live at pvgupta24.github.io

The workflow configuration is located in `.github/workflows/jekyll.yml`