module LeBonCoin
  module HTMLUtils
    class << self
      def convert str
        require 'htmlentities'
        str = HTMLEntities.new.encode(str.force_encoding("ISO-8859-15").encode("UTF-8"), :hexadecimal)
          .gsub(/&#xc3;&#xa9;/, "&eacute;")
          .gsub(/&#xc2;&#x99;/, "&#153;")
          .gsub(/&#xc2;&#xae;/, "&copy;")

        str = HTMLEntities.new.decode(str)
          .gsub(/\u0092/, "'")
          .gsub(/\u0096/, "-")
          .gsub(/\u0095/, "&#149;")
          .gsub(/\u0099/, "&#153;")
          .gsub(/\u0080/, "&euro;")

        return str
      end
    end
  end
end
