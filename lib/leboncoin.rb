require 'leboncoin/search'

module LeBonCoin
  VERSION = '0.0.4'

  class << self
    def Search keywords, size = 10
      LeBonCoin::Search.parseItems "http://www.Leboncoin.fr/occasions/?f=a&th=1&q=" + keywords, size
    end
  end
end
