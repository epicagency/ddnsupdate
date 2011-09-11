Gem::Specification.new do |s|
  s.name = %q{ddnsupdate}
  s.version = "0.2.0"
  s.description = <<-EOF
DDNSUpdate is a wrapper around nsupdate to facilitate dynamic dns updates
EOF
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Hugues Lismonde}]
  s.date = %q{2011-09-09}
  s.email = %q{hugues@epic.net}
  s.executables = [%q{ddnsupdate}]
  s.files = [%q{HISTORY}, %q{LICENSE}, %q{README.md}, %q{bin/ddnsupdate}, %q{lib/ddnsupdate.rb}]
  s.homepage = %q{https://github.com/epicagency/ddnsupdate/}
  s.require_paths = [%q{lib}]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.6")
  s.requirements << 'nsupdate, dig'
  s.add_dependency('trollop', "~> 1.13")
  s.rubygems_version = %q{1.8.5}
  s.summary = %q{Performs dynamic dns updates}
end

