require "cgi"
require "ycode/version"
require "ycode/base"

module Ycode
	def self.to_html(str)
		@ycode ||= Ycode::Base.new
		@ycode.parse_to_html str
	end
end
