# Mergen

A tool to create mermaid class diagrams from Ruby code.

## Installation

```bash
$ gem install mergen
```

## Usage

### From Command Line

```bash
$ mergen path/to/ruby/files -o diagram.md
```

### From Ruby Code

```ruby
require 'mergen'

generator = Mergen::Generator.new('path/to/ruby/files')
diagram = generator.generate

# Display the output
puts diagram

# Or save to a file
File.write('diagram.md', diagram)
```

## Output Example

The generated class diagram in Mermaid syntax will look like this:

```
classDiagram
  class Person {
    + name : property
    + age : property
    + initialize(name, age)
    + greet()
  }
  
  class Employee {
    + department : property
    + position : property
    + work()
  }
  
  Person <|-- Employee
```

## License

Distributed under the [MIT License](LICENSE.txt).
