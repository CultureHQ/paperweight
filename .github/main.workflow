workflow "Main" {
  on = "push"
  resolves = "Publish"
}

action "Bundler" {
  uses = "docker://culturehq/actions-bundler:latest"
  runs = "gem install bundler"
}

action "Install" {
  needs = "Bundler"
  uses = "docker://culturehq/actions-bundler:latest"
  args = "install"
}

action "Audit" {
  needs = "Install"
  uses = "docker://culturehq/actions-bundler:latest"
  args = "exec bundle audit"
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
  needs = ["Audit", "Lint", "Test"]
  uses = "actions/bin/filter@master"
  args = "tag"
}

action "Publish" {
  needs = "Tag"
  uses = "docker://culturehq/actions-bundler:latest"
  args = "build release:rubygem_push"
  secrets = ["BUNDLE_GEM__PUSH_KEY"]
}
