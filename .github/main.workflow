workflow "Main" {
  on = "push"
  resolves = "Publish"
}

action "Install" {
  uses = "docker://culturehq/actions-bundler:latest"
  args = "install --path vendor/bundle"
}

action "Set Path" {
  needs = "Install"
  uses = "actions/bin/sh@master"
  args = "export PATH=\"$PWD/vendor/bundle:$PATH\""
}

action "Lint" {
  needs = "Set Path"
  uses = "docker://culturehq/actions-bundler:latest"
  args = "exec rubocop --parallel"
}

action "Test" {
  needs = "Set Path"
  uses = "docker://culturehq/actions-bundler:latest"
  args = "exec rake test"
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
}
