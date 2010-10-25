module Leboncoin
  VERSION = '0.0.3'

  class << self
    def Search keywords, size = 10
      Leboncoin::Search.parseItems "http://www.leboncoin.fr/occasions/?f=a&th=1&q=" + keywords, size
    end
  end
end

module Leboncoin
  module Search
    class << self
      ###
      # Load the given URL as a well-formed HTML document
      def loadHTML url
        require 'open-uri'
        require 'nokogiri'

        doc = begin
          Nokogiri::HTML(open(url))
        rescue
          nil
        end

        return doc
      end

      ###
      # Parse items from a given URL
      def parseItems url, size, items = Leboncoin::Search::SearchItems.new(url)
        doc = loadHTML url

        doc.xpath('//table[@id="hl"]/tr').each do |node|
          if items.size < size
            parseItemNode node, items.createItem
          end
        end

        if items.size < size
          doc.xpath('//a[starts-with(text(), "Page suivante")]').each do |node|
            parse node['href'], size, items
          end
        end

        return items
      end

      ###
      # Parse item from a given XML node.
      def parseItemNode(node, item = Hash.new)
        # DATE
        item["date"] = begin
          require 'date'
          DateTime.parse(
            node.xpath('td[1]')[0].inner_html.strip
              .gsub(/ ao.t<br>/, " aug<br>").gsub(/<br>/, " ")
              .gsub(/Aujourd'hui/, (Date.today - 0).strftime('%d %b').downcase)
              .gsub(/Hier/, (Date.today - 1).strftime('%d %b').downcase)
          )
        rescue
          nil
        end

        # IMAGE
        item["image"] = begin
          node.xpath('td[2]/table/tbody/tr[2]/td[2]/a/img')[0]["src"].strip
        rescue
          nil
        end

        # TITLE
        item["title"] = begin
          convert(node.xpath('td[3]/a')[0].content.strip)
        rescue
          "UNKNOW TITLE"
        end

        # LINK
        item["link"] = begin
          node.xpath('td[3]/a')[0]["href"].strip
        rescue
          nil
        end

        # PRICE
        item["currency"] = "EUR"
        item["price"] = begin
          node.xpath('td[3]/text()[3]')[0].content.strip.gsub(/..$/, "").to_i
        rescue
          nil
        end

        return parseItem item["link"], item
      end

      ###
      # Parse item from a given HTML link.
      def parseItem url, item = Hash.new
        doc = loadHTML url

        # DESCRIPTION
        item["description"] = begin
          convert(doc.xpath('//span[@class="lbcAd_text"]').inner_html)
        rescue
          nil
        end

        value = begin
          doc.xpath('//span[@class="ad_details_400"]/strong').inner_html.strip
        rescue
          nil
        end

        # POSTCODE
        item["postcode"] = begin
          value[/[0-9]+/]
        rescue
          nil
        end

        # CITY
        item["city"] = begin
          value.gsub(/[0-9]+ /, "")
        rescue
          nil
        end

        return item
      end
    end
  end
end

module Leboncoin
  module Search
    module SearchItems
      class << self
        ###
        # Default constructor
        def new link
          @link = link
          @items = Array.new
          return self
        end

        ###
        # Create a new item
        def createItem item = Hash.new
          @items.push item
          return item
        end

        def each
          @items.each do |item|
            yield item if block_given?
          end
        end

        def size
          return @items.size
        end

        def to_json
          require 'json'
          return JSON.pretty_generate(@items)
        end

        def to_rss
          require 'rss/maker'

          content = RSS::Maker.make("2.0") do |m|
            m.channel.title = "leboncoin.fr"
            m.channel.link = @link
            m.channel.description = "leboncoin.fr"
            m.items.do_sort = true
            @items.each do |item|
              price = ""
              if item["price"] != nil
                price = item["price"].to_s + " " + item["currency"]
              end

              postcode = ""
              if item["postcode"] != nil
                postcode = item["postcode"]
              end

              i = m.items.new_item
              i.title = item["title"]
              i.link = item["link"]
              begin
                i.description = convert("<img src='" + item["image"] + "'/><br/>" \
                  + "<b>Ville</b> : " + item["city"] + "<br/>" \
                  + "<b>Code postal</b> : " + postcode + "<br/>" \
                  + "<p>" + item["description"] + "</p><hr/>" \
                  + "<b>Prix</b> : " + price + "<hr/>")
              rescue    
                require 'json'
                puts ">>>> ERROR >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n"
                puts JSON.pretty_generate(item)
                puts "\n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
              end
              i.date = Time.now #item["date"]
            end
          end
        end
      end
    end
  end
end

#Leboncoin::Search('dreamcast', 2).each do |i|
#  puts ">>> #{i['postcode']} : " + JSON.pretty_generate(i) + "\n\n"
#end
#puts Leboncoin::Search('dreamcast', 1).to_json
#puts Leboncoin::Search('dreamcast', 1).to_rss
