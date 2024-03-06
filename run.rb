#!/usr/bin/env ruby
require 'tty-markdown'
require 'irb'
require 'tty-font'

converter_options = {
  enabled: true,
  indent: 2,
  input: 'KramdownExt',
  mode: TTY::Color.mode,
  symbols: TTY::Markdown::SYMBOLS,
  theme: TTY::Markdown::THEME,
  width: TTY::Screen.width
}

def dialect(str)
  /(?<lang>\w+)(?:@(?<version>[\w.]+))?(?:\((?<dialect>\w+)\))?/ =~ str
  [lang, dialect, version]
end

def replace(element)
  case element.type
  when :codeblock
    lang, dialect, version = dialect(element.options[:lang])
    element.options[:lang] = lang
    [
      Kramdown::Element.new(:text, "Running #{lang} code version #{version} using #{dialect}..."),
      element
    ]
  when :header && element.options[:level] == 1
    font = TTY::Font.new(:standard)
    element.options[:raw_text] = font.write(element.options[:raw_text])
    element.children.each do |c|
      c.value = font.write(c.value)
    end
    [element]
  when :header && element.options[:level] == 2
    font = TTY::Font.new(:straight)
    element.options[:raw_text] = font.write(element.options[:raw_text])
    element.children.each do |c|
      c.value = font.write(c.value)
    end
    [element]
  else
    [element]
  end
end

doc = Kramdown::Document.new(File.read('buildme.md'), converter_options)
# binding.irb
doc.root.children = doc.root.children.flat_map { |element| replace(element) }
binding.irb
puts TTY::Markdown::Converter.convert(doc.root, doc.options).join

# parsed = TTY::Markdown.parse_file('buildme.md')
# puts parsed
