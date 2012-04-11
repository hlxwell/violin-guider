require "rubygems"
require "nokogiri"

path = "fingerboard"
doc = Nokogiri::XML(File.open("./#{path}.tmx"))
words = doc.xpath('//map/objectgroup/object').map do |obj|
	puts obj.attributes["name"].to_s.strip.split(',').inspect
end

