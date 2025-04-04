# Blix OPDS Generator

Blix OPDS Generator is a Ruby gem that allows you to easily create OPDS (Open Publication Distribution System) catalogs for your digital content. It's designed to work seamlessly with Blix applications but can be used in any Ruby project.

## Features

- Generate OPDS-compliant XML catalogs
- Support for nested directory structures
- Automatic MIME type detection for common file types
- Security measures to prevent unauthorized directory access

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'blix-opds'
```
## Blix Rest Web example
To use this in a blix web application, you might do something like this:

```ruby
require 'blix/rest'
require 'blix/opds'

class Controller < Blix::Rest::Controller

  include Blix::OPDS::Routes

  opds_routes :root=>'/Public/Books', :url=>'http://example.com', :prefix=>'opds'


end

run Blix::Rest::Server.new
```

### Configuration Options

The `opds_routes` method accepts several options:

- `:root`: The root directory of your digital content (required)
- `:url`: The base URL of your OPDS catalog (required)
- `:prefix`: The path prefix for your OPDS routes (optional)
- `:types`: An array of file extensions to include in the catalog (optional)

Example usage with all options:

```ruby
opds_routes :root => '/Public/Books', 
            :url => 'http://example.com', 
            :prefix => 'opds',
            :types => [:epub, :pdf, :mobi]
```
## Standalone Usage

You can also use the Blix OPDS Generator without integrating it into a Blix web application. Here's an example of how to generate an OPDS catalog programmatically:

```ruby
require 'blix/opds'

# Create a new OPDS catalog generator
generator = Blix::OPDS::Generator.new(
  '/path/to/your/books',
  'http://example.com/opds',
  :types => [:epub, :pdf, :mobi]
)

# Generate the catalog for a specific path
path = '/'  # Root path
result = generator.process(path)

if result.is_a?(String)
  # It's an XML catalog
  puts result
  # Or save it to a file
  File.write('catalog.xml', result)
elsif result.is_a?(Hash)
  # It's file information
  puts "File: #{result[:path]}"
  puts "MIME Type: #{result[:mime_type]}"
  puts "Size: #{result[:size]} bytes"
else
  puts "No content found for the given path"
end
```