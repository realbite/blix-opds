require 'spec_helper'

RSpec.describe Blix::OPDS::Generator do
  let(:root_path) { '/tmp/opds_test' }
  let(:url_prefix) { 'http://example.com/opds' }
  let(:generator) { described_class.new(root_path, url_prefix) }

  before do
    FileUtils.mkdir_p(root_path)
    FileUtils.touch(File.join(root_path, 'test.pdf'))
    FileUtils.touch(File.join(root_path, 'test.epub'))
    FileUtils.mkdir_p(File.join(root_path, 'subdir'))
    FileUtils.touch(File.join(root_path, 'subdir', 'test.mobi'))
  end

  after do
    FileUtils.rm_rf(root_path)
  end

  describe '#process' do
    context 'when path is a directory' do
      it 'generates a listing' do
        result = generator.process('')
        doc = Nokogiri::XML(result)

        expect(doc.root.name).to eq('feed')
        expect(doc.root.namespace.href).to eq('http://www.w3.org/2005/Atom')
        expect(doc.xpath('//xmlns:entry').count).to eq(3) # 2 files + 1 directory
      end

      it 'includes correct links for entries' do
        result = generator.process('')
        doc = Nokogiri::XML(result)

        pdf_entry = doc.at_xpath('//xmlns:entry[xmlns:title="test.pdf"]')
        expect(pdf_entry.at_xpath('.//xmlns:link/@href').value).to eq("#{url_prefix}/test.pdf")
        expect(pdf_entry.at_xpath('.//xmlns:link/@type').value).to eq('application/pdf')

        dir_entry = doc.at_xpath('//xmlns:entry[xmlns:title="subdir"]')
        expect(dir_entry.at_xpath('.//xmlns:link/@href').value).to eq("#{url_prefix}/subdir")
        expect(dir_entry.at_xpath('.//xmlns:link/@type').value).to eq('application/atom+xml;profile=opds-catalog;kind=navigation')
      end

      it 'includes a link to parent directory when not at root' do
        result = generator.process('subdir')
        doc = Nokogiri::XML(result)
      
        expect(doc.at_xpath('//xmlns:link[@rel="up"]/@href').value).to eq(url_prefix)
      end

      it 'does not include a link to parent directory when at root' do
        result = generator.process('')
        doc = Nokogiri::XML(result)
      
        expect(doc.at_xpath('//xmlns:link[@rel="up"]')).to be_nil
      end
    end

    context 'when path is a file' do
      it 'returns file information' do
        result = generator.process('test.pdf')

        expect(result).to be_a(Hash)
        expect(result[:path]).to eq(File.join(root_path, 'test.pdf'))
        expect(result[:mime_type]).to eq('application/pdf')
      end
    end

    context 'when path is outside root' do
      it 'raises a SecurityError' do
        expect { generator.process('../outside') }.to raise_error(SecurityError)
      end
    end
  end

  describe '#guess_mime_type' do
    it 'returns correct MIME type for known extensions' do
      expect(generator.send(:guess_mime_type, 'test.pdf')).to eq('application/pdf')
      expect(generator.send(:guess_mime_type, 'test.epub')).to eq('application/epub+zip')
      expect(generator.send(:guess_mime_type, 'test.mobi')).to eq('application/x-mobipocket-ebook')
    end

    it 'returns application/octet-stream for unknown extensions' do
      expect(generator.send(:guess_mime_type, 'test.unknown')).to eq('application/octet-stream')
    end
  end
end