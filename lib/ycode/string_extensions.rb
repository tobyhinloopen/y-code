module Ycode::StringExtensions
	def as_ycode_to_html
		Ycode::Base.new.parse_to_html self
	end
end

String.send :include, Ycode::StringExtensions