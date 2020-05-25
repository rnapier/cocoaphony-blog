module Jekyll
  module LinkFilter
    def link(input, url)
      if url
        "[#{input}](#{url})"
      else
        input
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::LinkFilter)