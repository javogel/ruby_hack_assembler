# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "ruby_hack_assembler"
  spec.version       = '1.0'
  spec.authors       = ["Johannus Vogel"]
  spec.email         = ["johannus.vogel@gmail.com"]
  spec.summary       = %q{Basic Hack Assembler written in Ruby}
  spec.description   = %q{Assembler for the Hack Assembly Language based on the Hack computer architecture.}
  spec.license       = "MIT"

  spec.files         = ['lib/ruby_hack_assembler.rb']
  spec.executables   = ['bin/ruby_hack_assembler']
  spec.test_files    = ['tests/test_assembler.rb']
  spec.require_paths = ["lib"]
end
