# !/usr/bin/env ruby
# frozen_string_literal: true

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
MEDIUM_FONT = TTY::Font.new(:straight)
LARGE_FONT = TTY::Font.new(:standard)

def dialect(str)
  /(?<lang>\w+)(?:@(?<version>[\w.]+))?(?:\((?<dialect>\w+)\))?/ =~ str
  [lang, dialect, version]
end

def replace_with_heading(element, font)
  element.options[:raw_text] = font.write(element.options[:raw_text])
  element.children.each do |c|
    c.value = font.write(c.value)
  end
  [element]
end

def replace_codeblock(element)
  lang, dialect, version = dialect(element.options[:lang])
  element.options[:lang] = lang

  lang_msg = "Running #{lang} code"
  version_msg = version ? "version #{version}" : nil
  dialect_msg = dialect ? "using #{dialect}..." : nil

  [
    Kramdown::Element.new(:text, [lang_msg, version_msg, dialect_msg].compact.join(' ')),
    Kramdown::Element.new(:blank),
    element
  ]
end

def replace(element)
  case [element.type, element.options[:level]]
  in [:codeblock, _]
    replace_codeblock(element)
  in [:header, 1]
    replace_with_heading(element, LARGE_FONT)
  in [:header, 2]
    replace_with_heading(element, MEDIUM_FONT)
  else
    [element]
  end
end

class Runner
  def run(element, opts = { indent: 0 })
    send("run_#{element.type}", element, opts)
  end
end

doc = Kramdown::Document.new(File.read('buildme.md'), converter_options)
doc.root.children = doc.root.children.flat_map { |element| replace(element) }
binding.irb
puts TTY::Markdown::Converter.convert(doc.root, doc.options).join

# parsed = TTY::Markdown.parse_file('buildme.md')
# puts parsed
