# frozen_string_literal: true

require_relative 'lib/mergen/version'

Gem::Specification.new do |spec|
  spec.name = 'mergen'
  spec.version = Mergen::VERSION
  spec.authors = ['Yudai Takada']
  spec.email = ['t.yudai92@gmail.com']

  spec.summary = 'A tool to create mermaid class diagrams from Ruby code.'
  spec.description = 'A tool to create mermaid class diagrams from Ruby code.'
  spec.homepage = 'https://github.com/ydah/mergen'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
