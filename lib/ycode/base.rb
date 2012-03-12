require "will_scan_string"

module Ycode
	class Base
		def initialize
			global_string_scanner = WillScanString::StringScanner.new
			nested_string_scanner = WillScanString::StringScanner.new

			global_string_scanner.register_replacement(/(?:\^(\d)|\A)([\s\S]+?)(?=\Z|\^\d)/, ->(_, color_id, content) {
				%(<span class="color color#{color_id.to_i}">#{nested_string_scanner.replace(content)}</span>)
			})

			{
				(/_(.+?)_/) => ->(_, content) { %(<strong>#{CGI.escapeHTML(content)}</strong>) },
				/^\/\/\s*(.+)/ => ->(_, username) {
					%(<a href="user_by_username.php?username=#{CGI.escapeHTML(CGI.escape(username.chomp))}">#{CGI.escapeHTML(username.chomp)}</a>)
				},
				/~~~~\r\n(.+?)\r\n([\s\S]*?)\r\n~~~~/ => ->(_, quotee, content) {
					%(<blockquote data-fadeout=200><span class="quoted">#{CGI.escapeHTML(quotee)}</span>#{global_string_scanner.replace(content)}</blockquote>)
				},
				"<" => "&lt;",
				">" => "&gt;",
				"&" => "&amp;",
				/(?:\r\n|\r|\n)/ => "<br>"
			}.each do |k, v|
				global_string_scanner.register_replacement k, v
				nested_string_scanner.register_replacement k, v
			end

			@string_scanner = global_string_scanner
		end

		def parse_to_html( string )
			@string_scanner.replace string
		end
	end
end