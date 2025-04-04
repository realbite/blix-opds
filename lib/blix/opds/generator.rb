require 'nokogiri'
require 'time'
require 'securerandom'
require 'uri'

module Blix
  module OPDS
    class Generator
      def initialize(root_path, url_prefix, options={})
        @options    = options
        @root_path  = root_path
        @url_prefix = url_prefix.chomp('/') # Remove trailing slash if present
        @types = (@options[:types] || []).map(&:to_s)
      end

      def process(relative_path = '')
        # Remove any leading slashes from relative_path
        relative_path = relative_path.gsub(/^\/+/, '')
        normalized_path = File.expand_path(relative_path, @root_path)
        
        # Ensure the normalized_path is still within the root_path
        unless normalized_path.start_with?(@root_path)
          raise SecurityError, "Access to paths outside the root directory is not allowed"
        end
        
        if File.directory?(normalized_path)
          generate_listing(normalized_path, relative_path)
        elsif File.file?(normalized_path)
          serve_file(normalized_path)
        else
          nil
        end
      end

      private

      def generate_listing(dir_path, relative_path)
        feed = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.feed(xmlns: 'http://www.w3.org/2005/Atom',
                   'xmlns:dcterms' => 'http://purl.org/dc/terms/',
                   'xmlns:opds' => 'http://opds-spec.org/2010/catalog') {
            xml.id "urn:uuid:#{SecureRandom.uuid}"
            xml.title "Directory: #{relative_path}"
            xml.updated Time.now.iso8601
            xml.author { xml.name "Blix OPDS" }

            # Add navigation link to parent directory if not at root
            unless relative_path.empty?
              parent_path = relative_path.split('/')[0..-2].join('/')
              parent_url  = parent_path.empty? ? @url_prefix : url_for(parent_path)
              xml.link(rel: 'up', href: parent_url, type: 'application/atom+xml;profile=opds-catalog;kind=navigation')
            end

            # List entries
            Dir.entries(dir_path).sort_by(&:downcase).each do |entry|
              next if entry.start_with?('.') # Skip hidden files
            
              full_entry_path = File.join(dir_path, entry)
              entry_type = File.directory?(full_entry_path) ? 'directory' : 'file'
              entry_url  = url_for(File.join(relative_path,entry))
              file_type  = File.extname(entry)[1..-1].to_s.downcase
              next unless (entry_type == 'directory') || @types.empty? || @types.include?(file_type)
            
              xml.entry {
                xml.id "urn:uuid:#{SecureRandom.uuid}"
                xml.title entry
                xml.updated File.mtime(full_entry_path).iso8601
                
                if entry_type == 'directory'
                  xml.link(rel: 'subsection', 
                           href: entry_url, 
                           type: 'application/atom+xml;profile=opds-catalog;kind=navigation')
                else
                  xml.link(rel: 'http://opds-spec.org/acquisition', 
                           href: entry_url, 
                           type: guess_mime_type(entry))
                end
            
                xml['dcterms'].format entry_type
              }
            end
          }
        end

        feed.to_xml
      end
      
      def serve_file(file_path)
        # This method would be responsible for serving the actual file content
        # In a real application, you'd set appropriate headers and return the file content
        # For now, we'll just return a hash with file info
        {
          path: file_path,
          mime_type: guess_mime_type(file_path),
          size: File.size(file_path)
        }
      end

      def guess_mime_type(filename)
        case File.extname(filename).downcase
        when '.pdf'  then 'application/pdf'
        when '.epub' then 'application/epub+zip'
        when '.mobi' then 'application/x-mobipocket-ebook'
        else 'application/octet-stream'
        end
      end

      # ensure all parts of a path are properly encoded
      def encode_path(path)
        path.split('/').map { |part| URI.encode_www_form_component(part) }.join('/')
      end

      def url_for(path)
        File.join(@url_prefix, encode_path(path))
      end

     
    end
  end
end