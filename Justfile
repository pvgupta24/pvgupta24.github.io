# Justfile for pvgupta24.github.io
# Run `just` to see available recipes

# Default recipe: list available commands
default:
    @just --list

# Install dependencies
install:
    bundle install

# Serve with fast dev config (livereload + incremental + skip inline CSS)
# --force_polling needed on Windows for reliable file watching
serve:
    bundle exec jekyll serve --livereload --force_polling --incremental --config _config.yml,_config_dev.yml

# Serve with production config
serve-prod:
    bundle exec jekyll serve --livereload --force_polling

# Serve including draft posts
drafts:
    bundle exec jekyll serve --drafts --livereload --force_polling --incremental --config _config.yml,_config_dev.yml

# Build for production
build:
    JEKYLL_ENV=production bundle exec jekyll build

# Clean generated files
clean:
    bundle exec jekyll clean

# Create a new blog post (usage: just new-post "my post title")
new-post title:
    #!/usr/bin/env bash
    slug=$(echo "{{title}}" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
    date=$(date +%Y-%m-%d)
    file="_posts/${date}-${slug}.md"
    cat > "${file}" << EOF
    ---
    title: "{{title}}"
    categories: []
    tags: []
    ---

    EOF
    echo "Created ${file}"
