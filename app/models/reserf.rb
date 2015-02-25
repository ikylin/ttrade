class Reserf < ActiveRecord::Base
	include QuotationdatafilesHelper
	resourcify

	belongs_to	:quotation
	belongs_to	:analyst
  belongs_to  :indexfilter

  WillPaginate.per_page = 10 

	scope	:daydata, ->(marketdate) { where("marketdate = ?", marketdate) }
	
	class << self
		def refresh(close)
			unless close <= 0
        profit = (hhv - close)/close
        loss = (close - llv)/close

        r.positionadvise = 0.05/r.loss unless r.loss == 0
        r.positionadvise = 0.2 unless r.positionadvise < 0.2 

        plratio = profit / loss unless loss == 0
        maxplratio = plratio
        optadvise = 'buy' unless plratio < 2
        stockstatus = 1
      end
		end

    def find_by_code(code,marketdate)
      Reserf.joins(:quotation).where("quotations.code" => code,"reserves.marketdate" => marketdate)
    end
	end
end
