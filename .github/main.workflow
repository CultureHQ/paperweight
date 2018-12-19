workflow "Main" {
  on = "push"
  resolves = "Publish"
}

action "Set Path" {
  uses = "docker://culturehq/actions-bundler:latest"
  args = "config path vendor/bundle"
}

action "Install" {
  needs = "Set Path"
  uses = "docker://culturehq/actions-bundler:latest"
  args = "install"
}

action "Lint" {
  needs = "Install"
  uses = "docker://culturehq/actions-bundler:latest"
  args = "exec rubocop --parallel"
}

action "Test" {
  needs = "Install"
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
