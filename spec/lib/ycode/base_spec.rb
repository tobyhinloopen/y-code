require 'spec_helper.rb'

def get_stripped_parser_result( string, strip = true)
	base = Ycode::Base.new
	result = base.parse_to_html string
	strip ? result[(%(<span class="color color0">).length)...-("</span>".length)] : result
end

describe Ycode::Base do
	it "should wrap color0 spans around the string" do
		get_stripped_parser_result("banana", false).should \
			eql %(<span class="color color0">banana</span>)
		get_stripped_parser_result("banana").should eql "banana"
	end

	it "should replace new-lines to <br>'s" do
		get_stripped_parser_result("a\nb").should eql "a<br>b"
		get_stripped_parser_result("a\rb").should eql "a<br>b"
		get_stripped_parser_result("a\r\nb").should eql "a<br>b"
	end

	it "should replace HTML entities" do
		get_stripped_parser_result("&<>").should eql "&amp;&lt;&gt;"
	end

	it "should enable bold words" do
		get_stripped_parser_result("_bold!_").should eql "<strong>bold!</strong>"
	end

	it "should enable color switching" do
		get_stripped_parser_result("black ^1 red ^0 black", false).should \
			eql %(<span class="color color0">black </span><span class="color color1"> red </span><span class="color color0"> black</span>)
	end

	it "should be able to handle nested patterns" do
		get_stripped_parser_result("black ^1 _bold & red_").should \
			eql %(black </span><span class="color color1"> <strong>bold &amp; red</strong>)
	end
end