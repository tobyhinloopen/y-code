require "will_scan_string"

module Ycode
	class Base
		URL_PATTERN = /((?:www\.|https?:\/\/)[^\/\s]+\.[a-z0-9]+(?:\/[^\s\[\]"'<>]+)?)/i

		def initialize
			global_string_scanner = WillScanString::StringScanner.new
			nested_string_scanner = WillScanString::StringScanner.new

			global_string_scanner.register_replacement (/(?:\^(\d)|\A)([\s\S]+?)(?=\Z|\^\d)/), ->(_, color_id, content) {
				%(<span class="color color#{color_id.to_i}">#{nested_string_scanner.replace(content)}</span>)
			}

			{
				/\!\@\#\$\%([\S\s]+?)\^\&\*\(\)/ => ->(_, content) { %(<code style="white-space: pre;">#{CGI.escapeHTML(content)}</code>) },
				/_(.+?)_/ => ->(_, content) { %(<strong>#{CGI.escapeHTML(content)}</strong>) },
				/([\s\S]*?)~~~~(?:(?:\r\n|\r|\n)\s*(.+?))?\s*(?:\r\n|\r|\n)([\s\S]+?)(?:\r\n|\r|\n)~~~~([\s\S]*?)/ => ->(_, prefix, quotee, content, postfix) {
					%(#{global_string_scanner.replace(prefix)}<blockquote>#{quotee.present? ? %(<span class="quoted">#{CGI.escapeHTML(quotee)}</span>) : ""}#{global_string_scanner.replace(content)}</blockquote>#{global_string_scanner.replace(postfix)})
				},
				"<" => "&lt;",
				">" => "&gt;",
				"&" => "&amp;",
				/([\s\S]*?)\[rauw\]\s*([\s\S]*?)\s*\[\/rauw\]([\s\S]*?)/ => ->(_, prefix, content, postfix) {
					%(%s<div class="hide">%s</div>%s) % [global_string_scanner.replace(prefix), global_string_scanner.replace(content), global_string_scanner.replace(postfix)]
				},
				/(?:\r\n|\r|\n)/ => "<br>",
				Regexp.new("!#{URL_PATTERN.source}", Regexp::IGNORECASE) => ->(_, url) {
					url = "http://#{url}" if url.starts_with? "www"
					escaped_url = CGI.escapeHTML url
					%(<a href="%s" target="_blank" rel="nofollow">%s</a>) % [escaped_url, escaped_url]
				},
				Regexp.new("M#{URL_PATTERN.source}", Regexp::IGNORECASE) => ->(_, url) {
					url = "http://#{url}" if url.starts_with? "www"
					uri_data = URI.parse(url) rescue nil
					if uri_data.nil?
						escaped_url = CGI.escapeHTML url
						%(<a href="%s" target="_blank" rel="nofollow">%s</a>) % [escaped_url, escaped_url]
					else
						uri_query_params = uri_data.query.present? ? HashWithIndifferentAccess[CGI.parse(uri_data.query).map{|k,v|[k,v.first]}] : HashWithIndifferentAccess.new
						%(<embed src="http://www.youtube.com/v/%s&amp;fs=1" type="application/x-shockwave-flash" allowfullscreen="true" width="400" height="25"></embed>) % CGI.escape_html(uri_query_params[:v])
					end
				},
				URL_PATTERN => ->(_, url) {
					url = "http://#{url}" if url.starts_with? "www"
					uri_data = URI.parse(url) rescue nil
					uri_query_params = uri_data.present? && uri_data.query.present? ? HashWithIndifferentAccess[CGI.parse(uri_data.query).map{|k,v|[k,v.first]}] : HashWithIndifferentAccess.new
					if uri_data.present? && uri_data.host =~ /youtube\.[a-z]{1,3}$/i && uri_query_params[:v] =~ /[a-z0-9_-]{11}/i
						%(<embed src="http://www.youtube.com/v/%s&amp;fs=1" type="application/x-shockwave-flash" allowfullscreen="true" width="583" height="354"></embed>) % CGI.escape_html($~.to_s)
					elsif uri_data.present? && uri_data.host =~ /liveleak\.com/i && uri_query_params[:i].present?
						%(<embed src="http://www.liveleak.com/e/%s" type="application/x-shockwave-flash" allowfullscreen="true" wmode="transparent" width="450" height="370"></embed>) % CGI.escape_html(CGI.escape($~.to_s))
					elsif uri_data.present? && uri_data.host =~ /dailymotion\.com/i && uri_data.path =~ /^\/video\/([^\/]+)/
						%(<embed src="http://www.dailymotion.com/swf/%s" type="application/x-shockwave-flash"  width="448" height="357" allowfullscreen="true" allowscriptaccess="always"></embed>) % CGI.escape_html($1)
					elsif uri_data.present? && uri_data.path =~ /\.(?:jpe?g|png|gif)$/i
						%(<img src="%s">) % CGI.escapeHTML(url)
					else
						escaped_url = CGI.escapeHTML url
						%(<a href="%s" target="_blank" rel="nofollow">%s</a>) % [escaped_url, escaped_url]
					end
				}
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