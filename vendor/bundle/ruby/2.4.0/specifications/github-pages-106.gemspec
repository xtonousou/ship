# -*- encoding: utf-8 -*-
# stub: github-pages 106 ruby lib

Gem::Specification.new do |s|
  s.name = "github-pages".freeze
  s.version = "106"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["GitHub, Inc.".freeze]
  s.date = "2016-12-05"
  s.description = "Bootstrap the GitHub Pages Jekyll environment locally.".freeze
  s.email = "support@github.com".freeze
  s.executables = ["github-pages".freeze]
  s.files = ["bin/github-pages".freeze]
  s.homepage = "https://github.com/github/pages-gem".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0".freeze)
  s.rubygems_version = "2.6.11".freeze
  s.summary = "Track GitHub Pages dependencies.".freeze

  s.installed_by_version = "2.6.11" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<jekyll>.freeze, ["= 3.3.1"])
      s.add_runtime_dependency(%q<jekyll-sass-converter>.freeze, ["= 1.3.0"])
      s.add_runtime_dependency(%q<kramdown>.freeze, ["= 1.11.1"])
      s.add_runtime_dependency(%q<liquid>.freeze, ["= 3.0.6"])
      s.add_runtime_dependency(%q<rouge>.freeze, ["= 1.11.1"])
      s.add_runtime_dependency(%q<github-pages-health-check>.freeze, ["= 1.2.0"])
      s.add_runtime_dependency(%q<jemoji>.freeze, ["= 0.7.0"])
      s.add_runtime_dependency(%q<jekyll-mentions>.freeze, ["= 1.2.0"])
      s.add_runtime_dependency(%q<jekyll-redirect-from>.freeze, ["= 0.11.0"])
      s.add_runtime_dependency(%q<jekyll-sitemap>.freeze, ["= 0.12.0"])
      s.add_runtime_dependency(%q<jekyll-feed>.freeze, ["= 0.8.0"])
      s.add_runtime_dependency(%q<jekyll-gist>.freeze, ["= 1.4.0"])
      s.add_runtime_dependency(%q<jekyll-paginate>.freeze, ["= 1.1.0"])
      s.add_runtime_dependency(%q<jekyll-coffeescript>.freeze, ["= 1.0.1"])
      s.add_runtime_dependency(%q<jekyll-seo-tag>.freeze, ["= 2.1.0"])
      s.add_runtime_dependency(%q<jekyll-github-metadata>.freeze, ["= 2.2.0"])
      s.add_runtime_dependency(%q<jekyll-avatar>.freeze, ["= 0.4.2"])
      s.add_runtime_dependency(%q<jekyll-relative-links>.freeze, ["= 0.2.1"])
      s.add_runtime_dependency(%q<listen>.freeze, ["= 3.0.6"])
      s.add_runtime_dependency(%q<activesupport>.freeze, ["= 4.2.7"])
      s.add_runtime_dependency(%q<minima>.freeze, ["= 2.0.0"])
      s.add_runtime_dependency(%q<jekyll-swiss>.freeze, ["= 0.4.0"])
      s.add_runtime_dependency(%q<mercenary>.freeze, ["~> 0.3"])
      s.add_runtime_dependency(%q<terminal-table>.freeze, ["~> 1.4"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.3"])
      s.add_development_dependency(%q<rubocop>.freeze, ["~> 0.35"])
      s.add_development_dependency(%q<pry>.freeze, ["~> 0.10"])
      s.add_development_dependency(%q<jekyll_test_plugin_malicious>.freeze, ["~> 0.2"])
    else
      s.add_dependency(%q<jekyll>.freeze, ["= 3.3.1"])
      s.add_dependency(%q<jekyll-sass-converter>.freeze, ["= 1.3.0"])
      s.add_dependency(%q<kramdown>.freeze, ["= 1.11.1"])
      s.add_dependency(%q<liquid>.freeze, ["= 3.0.6"])
      s.add_dependency(%q<rouge>.freeze, ["= 1.11.1"])
      s.add_dependency(%q<github-pages-health-check>.freeze, ["= 1.2.0"])
      s.add_dependency(%q<jemoji>.freeze, ["= 0.7.0"])
      s.add_dependency(%q<jekyll-mentions>.freeze, ["= 1.2.0"])
      s.add_dependency(%q<jekyll-redirect-from>.freeze, ["= 0.11.0"])
      s.add_dependency(%q<jekyll-sitemap>.freeze, ["= 0.12.0"])
      s.add_dependency(%q<jekyll-feed>.freeze, ["= 0.8.0"])
      s.add_dependency(%q<jekyll-gist>.freeze, ["= 1.4.0"])
      s.add_dependency(%q<jekyll-paginate>.freeze, ["= 1.1.0"])
      s.add_dependency(%q<jekyll-coffeescript>.freeze, ["= 1.0.1"])
      s.add_dependency(%q<jekyll-seo-tag>.freeze, ["= 2.1.0"])
      s.add_dependency(%q<jekyll-github-metadata>.freeze, ["= 2.2.0"])
      s.add_dependency(%q<jekyll-avatar>.freeze, ["= 0.4.2"])
      s.add_dependency(%q<jekyll-relative-links>.freeze, ["= 0.2.1"])
      s.add_dependency(%q<listen>.freeze, ["= 3.0.6"])
      s.add_dependency(%q<activesupport>.freeze, ["= 4.2.7"])
      s.add_dependency(%q<minima>.freeze, ["= 2.0.0"])
      s.add_dependency(%q<jekyll-swiss>.freeze, ["= 0.4.0"])
      s.add_dependency(%q<mercenary>.freeze, ["~> 0.3"])
      s.add_dependency(%q<terminal-table>.freeze, ["~> 1.4"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.3"])
      s.add_dependency(%q<rubocop>.freeze, ["~> 0.35"])
      s.add_dependency(%q<pry>.freeze, ["~> 0.10"])
      s.add_dependency(%q<jekyll_test_plugin_malicious>.freeze, ["~> 0.2"])
    end
  else
    s.add_dependency(%q<jekyll>.freeze, ["= 3.3.1"])
    s.add_dependency(%q<jekyll-sass-converter>.freeze, ["= 1.3.0"])
    s.add_dependency(%q<kramdown>.freeze, ["= 1.11.1"])
    s.add_dependency(%q<liquid>.freeze, ["= 3.0.6"])
    s.add_dependency(%q<rouge>.freeze, ["= 1.11.1"])
    s.add_dependency(%q<github-pages-health-check>.freeze, ["= 1.2.0"])
    s.add_dependency(%q<jemoji>.freeze, ["= 0.7.0"])
    s.add_dependency(%q<jekyll-mentions>.freeze, ["= 1.2.0"])
    s.add_dependency(%q<jekyll-redirect-from>.freeze, ["= 0.11.0"])
    s.add_dependency(%q<jekyll-sitemap>.freeze, ["= 0.12.0"])
    s.add_dependency(%q<jekyll-feed>.freeze, ["= 0.8.0"])
    s.add_dependency(%q<jekyll-gist>.freeze, ["= 1.4.0"])
    s.add_dependency(%q<jekyll-paginate>.freeze, ["= 1.1.0"])
    s.add_dependency(%q<jekyll-coffeescript>.freeze, ["= 1.0.1"])
    s.add_dependency(%q<jekyll-seo-tag>.freeze, ["= 2.1.0"])
    s.add_dependency(%q<jekyll-github-metadata>.freeze, ["= 2.2.0"])
    s.add_dependency(%q<jekyll-avatar>.freeze, ["= 0.4.2"])
    s.add_dependency(%q<jekyll-relative-links>.freeze, ["= 0.2.1"])
    s.add_dependency(%q<listen>.freeze, ["= 3.0.6"])
    s.add_dependency(%q<activesupport>.freeze, ["= 4.2.7"])
    s.add_dependency(%q<minima>.freeze, ["= 2.0.0"])
    s.add_dependency(%q<jekyll-swiss>.freeze, ["= 0.4.0"])
    s.add_dependency(%q<mercenary>.freeze, ["~> 0.3"])
    s.add_dependency(%q<terminal-table>.freeze, ["~> 1.4"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.3"])
    s.add_dependency(%q<rubocop>.freeze, ["~> 0.35"])
    s.add_dependency(%q<pry>.freeze, ["~> 0.10"])
    s.add_dependency(%q<jekyll_test_plugin_malicious>.freeze, ["~> 0.2"])
  end
end
