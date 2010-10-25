# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{leboncoin}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Karim DRIDI"]
  s.date = %q{2010-10-25}
  s.description = %q{leboncoin toolkit.}
  s.email = %q{karim.dridi@gmail.com}
  s.extra_rdoc_files = ["README.rdoc", "lib/leboncoin.rb"]
  s.files = ["README.rdoc", "lib/leboncoin.rb", "leboncoin.gemspec"]
  s.homepage = %q{http://github.com/kdridi/leboncoin}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Leboncoin", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{leboncoin}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Let's search through leboncoin.fr items!}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<htmlentities>, [">= 0"])
      s.add_runtime_dependency(%q<nokogiri>, [">= 0"])
    else
      s.add_dependency(%q<htmlentities>, [">= 0"])
      s.add_dependency(%q<nokogiri>, [">= 0"])
    end
  else
    s.add_dependency(%q<htmlentities>, [">= 0"])
    s.add_dependency(%q<nokogiri>, [">= 0"])
  end
end
