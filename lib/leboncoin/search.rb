require 'leboncoin/items'

module LeBonCoin
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
      def parseItems url, size, items = LeBonCoin::Search::SearchItems.new(url)
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
          LeBonCoin::HTMLUtils.convert(node.xpath('td[3]/a')[0].content.strip)
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
          LeBonCoin::HTMLUtils.convert(doc.xpath('//span[@class="lbcAd_text"]').inner_html)
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
