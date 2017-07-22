# -*- encoding: utf-8 -*-
# stub: minima 2.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "minima".freeze
  s.version = "2.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "plugin_type" => "theme" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Joel Glovier".freeze]
  s.bindir = "exe".freeze
  s.date = "2016-10-06"
  s.email = ["jglovier@github.com".freeze]
  s.homepage = "https://github.com/jekyll/minima".freeze
  s.licenses = ["MIT".freeze]
  s.post_install_message = "\n----------------------------------------------\nThank you for installing minima 2.0!\n\nMinima 2.0 comes with a breaking change that\nrenders '<your-site>/css/main.scss' redundant.\nThat file is now bundled with this gem as\n'<minima>/assets/main.scss'.\n\nMore Information:\nhttps://github.com/jekyll/minima#customization\n----------------------------------------------\n\n".freeze
  s.rubygems_version = "2.6.11".freeze
  s.summary = "A beautiful, minimal theme for Jekyll. NOT DONE YET.".freeze

  s.installed_by_version = "2.6.11" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<jekyll>.freeze, ["~> 3.2"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.12"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
    else
      s.add_dependency(%q<jekyll>.freeze, ["~> 3.2"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.12"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    end
  else
    s.add_dependency(%q<jekyll>.freeze, ["~> 3.2"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.12"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
  end
end
