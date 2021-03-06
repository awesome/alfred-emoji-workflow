require './emoji_symbols'
require './related_words'

def item_xml(options = {})
  <<-ITEM
  <item arg="#{options[:arg]}" uid="#{options[:uid]}">
    <title>#{options[:title]}</title>
    <subtitle>#{options[:subtitle]}</subtitle>
    <icon>#{options[:path]}</icon>
  </item>
  ITEM
end

def match?(word, query)
  word.match(/#{query}/i)
end

images_path = File.expand_path('../images/emoji', __FILE__)

query = Regexp.escape(ARGV.first).delete(':')

related_matches = RELATED_WORDS.select { |k, v| match?(k, query) || v.any? { |r| match?(r, query) } }.keys

image_matches = Dir["#{images_path}/*.png"].sort.map { |fn| File.basename(fn, '.png') }.select { |fn| match?(fn, query) }

matches = image_matches + related_matches

items = matches.uniq.map do |elem|
  path = File.join(images_path, "#{elem}.png")
  emoji_code = ":#{elem}:"

  emoji_arg = ARGV.size > 1 ? EMOJI_SYMBOLS.fetch(elem.to_sym, emoji_code) : emoji_code

  item_xml({ :arg => emoji_arg, :uid => elem, :path => path, :title => emoji_code,
             :subtitle => "Copy #{emoji_arg} to clipboard" })
end.join

output = "<?xml version='1.0'?>\n<items>\n#{items}</items>"

puts output
