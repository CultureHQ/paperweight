workflow "Main" {
  on = "push"
  resolves = "Publish"
}

action "Install" {
  uses = "docker://culturehq/actions-bundler:latest"
  args = "install"
  env = {
    BUNDLE_PATH = "vendor/bundle"
  }
}

action "Lint" {
  needs = "Install"
  uses = "docker://culturehq/actions-bundler:latest"
  args = "exec rubocop --parallel"
  env = {
    BUNDLE_PATH = "vendor/bundle"
  }
}

action "Test" {
  needs = "Install"
  uses = "docker://culturehq/actions-bundler:latest"
  args = "exec rake test"
  env = {
    BUNDLE_PATH = "vendor/bundle"
  }
}

action "Tag" {
  needs = ["Lint", "Test"]
  uses = "actions/bin/filter@master"
  args = "tag"
}

action "Publish" {
  needs = "Tag"
  uses = "docker://culturehq/actions-bundler:latest"
  args = "build release:rubygem_push"
  secrets = ["BUNDLE_GEM__PUSH_KEY"]
  env = {
    BUNDLE_PATH = "vendor/bundle"
  }
}
