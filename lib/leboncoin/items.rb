require 'leboncoin/htmlutils'

module LeBonCoin
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
                i.description = LeBonCoin::HTMLUtils.convert("<img src='" + item["image"] + "'/><br/>" \
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
