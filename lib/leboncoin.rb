module LBC

module_function

require 'htmlentities'
Entities = HTMLEntities.new

def convert(str)
   str = Entities.encode(str.force_encoding("ISO-8859-15").encode("UTF-8"), :hexadecimal)
       .gsub(/&#xc3;&#xa9;/, "&eacute;")
       .gsub(/&#xc2;&#x99;/, "&#153;")
       .gsub(/&#xc2;&#xae;/, "&copy;")

   str = Entities.decode(str)
       .gsub(/\u0092/, "'")
       .gsub(/\u0096/, "-")
       .gsub(/\u0095/, "&#149;")
       .gsub(/\u0099/, "&#153;")
       .gsub(/\u0080/, "&euro;")

   return str
end

def retrieveData(url)
   require 'open-uri'
   return open(url)
end

def createDocument(url)
   require 'nokogiri'
   return Nokogiri::HTML(retrieveData(url))
end

def createItem(node)
       require 'date'

   item = Hash.new

   # DATE
   item["dateFR"] = node.xpath('td[1]')[0].inner_html.strip
   item["dateEN"] = item["dateFR"]
       .gsub(/ ao.t<br>/, " aug<br>").gsub(/<br>/, " ")
       .gsub(/Aujourd'hui/, (Date.today - 0).strftime('%d %b').downcase)
       .gsub(/Hier/, (Date.today - 1).strftime('%d %b').downcase)

   item["date"] = DateTime.parse(item["dateEN"])

   # IMAGE
   item["image"] = begin node.xpath('td[2]/table/tbody/tr[2]/td[2]/a/img')[0]["src"].strip rescue nil end

   # NAME & LINK
   item["title"] = convert(node.xpath('td[3]/a')[0].content.strip)
   item["link"] = node.xpath('td[3]/a')[0]["href"].strip

   # PRICE
   item["price"] =  begin node.xpath('td[3]/text()[3]')[0].content.strip.gsub(/..$/, "").to_i rescue nil end
   item["currency"] = "EUR"

   # DESCRIPTION
   doc = createDocument(item["link"])
   item["description"] = convert(doc.xpath('//span[@class="lbcAd_text"]').inner_html)
   item["city"] = doc.xpath('//span[@class="ad_details_400"]/strong').inner_html.strip
   item["postcode"] = item["city"][/[0-9]+/]
   item["city"] = item["city"].gsub(/[0-9]+ /, "")

       return item
end

def parseItems(items, url, size)
       doc = createDocument url

   continue = true
       doc.xpath('//table[@id="hl"]/tr').each do |node|
       if items.size < size
                   items.push createItem(node)
       end
       end

   if items.size < size
           doc.xpath('//a[starts-with(text(), "Page suivante")]').each do |node|
                   parseItems(items, node['href'], size)
           end
   end
end

def createItems(url, size)
       items = Array.new
       parseItems(items, url, size)
       return items
end

def createJSON(url, size)
   require 'json'
   return JSON.pretty_generate(createItems(url, size))
end

def createRSS(url, size)
   require 'rss/maker'

   content = RSS::Maker.make("2.0") do |m|
   m.channel.title = "leboncoin.fr"
   m.channel.link = url
   m.channel.description = "leboncoin.fr"
   m.items.do_sort = true # sort items by date
       createItems(url, size).each do |item|
           title = ""
           price = ""
           if item["price"] != nil
               price = item["price"].to_s + " " + item["currency"]
               title = "[" + price + "] "
           end

           postcode = ""
           if item["postcode"] != nil
               postcode = item["postcode"]
           end
           
           i = m.items.new_item
           i.title = title + item["title"]
           i.link = item["link"]
           begin
           i.description = convert("<img src='" + item["image"] + "'/><br/>"                + "<b>Ville</b> : " + item["city"] + "<br/>"                + "<b>Code postal</b> : " + postcode + "<br/>"                + "<p>" + item["description"] + "</p><hr/>"                + "<b>Prix</b> : " + price + "<hr/>")
           rescue    
#                require 'json'
#                puts ">>>> " + JSON.pretty_generate(item)
           end
           i.date = Time.now #item["date"]
       end
   end

end

end

puts "LBC.createJSON( url, size ) has been redefined"
puts "LBC.createRSS( url, size ) has been redefined"
