#encoding:utf-8
require 'gruff'

module QuotationdatafilesHelper


#	1. input today quotation
	#	1.1 update profit
# 2. input today reserver
# 3. modify today reserver
# 4. select portfolio by pretradedate data
# 5. date change
# 6. select portfolio by tradedate data
	def sysmarketdate
		return Sysconfig.find_by(cfgname: 'marketdate').cfgdate
	end
	
	def config_get tag, cfgname
		case cfgname
		when 'batchname'
			return Sysconfig.find_by(cfgname: 'batchname', tag: tag).cfgstring	
		when 'batchstatus'
			return Sysconfig.find_by(cfgname: 'batchstatus', tag: tag).cfginteger	
		else

		end
	end
	
	def config_set tag, cfgname, cfgvalue
		case cfgname
		when 'batchname'
			return Sysconfig.find_by(cfgname: 'batchname', tag: tag).update(cfgstring: cfgvalue)
		when 'batchstatus'
			return Sysconfig.find_by(cfgname: 'batchstatus', tag: tag).update(cfginteger: cfgvalue)
		else

		end
	end

	def tradedate tag
		m = Marketdate.where(daystate: '', tag: tag).order(tradedate: :asc).first
		return m.tradedate unless m.nil?
	end

	def tradestage tag
		c = Sysconfig.find_by(cfgname: 'batchname', tag: tag)
		return c.cfgstring unless c.nil?
	end

	def pretradedate tag
		m = Marketdate.where(daystate: 'past', tag: tag).order(tradedate: :asc).last
		return m.tradedate unless m.nil?
	end

	def posttradedate tag
		m = Marketdate.where(daystate: '', tag: tag).order(tradedate: :asc).limit(2).last
		return m.tradedate unless m.nil?
	end

	def marketdatechange tag
		m = Marketdate.where(daystate: '', tag: tag).order(tradedate: :asc).first
		m.update!(daystate: 'past')
		Sysconfig.find_by(cfgname: 'marketdate', tag: tag).update!(cfgdate: tradedate(tag))
	end
	
	def sysaccount_num_max tag
		return Sysconfig.find_by(cfgname: 'account_num_max', tag: tag).cfginteger
	end

	def sysportfolio_num_max tag
		return Sysconfig.find_by(cfgname: 'portfolio_num_max', tag: tag).cfginteger
	end

  def true_trade_date tag
    if Sysconfig.find_by(cfgname: 'batchname', tag: tag).cfgstring != 'datechange'
      return tradedate(tag)
    else
      return pretradedate(tag)
    end
  end
  
  def get_reserves_count tag
    Reserf.where(marketdate:true_trade_date(tag), stockstatus:'1', tag: tag).count
  end
	
  def get_stocks_count tag
    Quotation.where(marketdate:true_trade_date(tag), tag: tag).count
  end
	
  def get_days tag
    Quotationdatafile.where(tag: tag).select(:marketdate).distinct.count
  end
	
  def get_weixinusers_count
    User.where(weixinstatus:'1').count
  end

  def get_users_count
    User.count
  end
  
  def get_winpercent indexfilter, tag
    waitcount = Reserf.joins(:quotation).joins(:indexfilter).where("reserves.tag" => tag).where("indexfilters.name" => indexfilter).where("reserves.catchplratio > 2").where("reserves.marketdate" => pretradedate(tag)).where("reserves.stockstatus" => '1').count
    wincount = Reserf.joins(:quotation).joins(:indexfilter).where("reserves.tag" => tag).where("indexfilters.name" => indexfilter).where("reserves.catchplratio > 2").where("reserves.stockstatus" => '2').count
    return "#{wincount}/#{waitcount}/#{100*wincount/(waitcount+wincount)}%" unless (waitcount + wincount) == 0       
  end

	def marketdatefileprocess filename, path 
    
    fcols = filename.split("_") 
    tag = fcols[0].strip
  
		File.open(path, 'r') do |file|
		#File.open(@quotationdatafile.avatar.path, 'r') do |file|
      file.each_line do |line|
        cols = line.force_encoding('gb2312').split("\r\n")
        #logger.info cols
        m = Marketdate.new
        m.tradedate = cols[0].strip
        m.daystate = ''
        m.tag = tag 

        m.save
      end
      file.close
    end

	end

	# before date 
	# 20140723 all data
	# 20140724 tradedate 
	# after date
	# 20140724 all data
	# 20140725 tradedate
	def quotationfileprocess filename, path 
    
    fcols = filename.split("_") 
    tag = fcols[0].strip

    case tag
    when 'A'
      File.open(path, 'r') do |file|
        file.each_line do |line|
          cols = line.force_encoding('gb2312').split("\t")
          if /\d{6}/ =~ cols[0][2..7].strip
            #added new quotation
            q = Quotation.new
            q.marketdate = tradedate(tag)
   
            q.code = cols[0][2..7].strip
            q.name = cols[1].strip
            q.cqstatus = 'chuxi' unless q.name[0..1] != 'XD'
            q.cqstatus = 'chuquan' unless q.name[0..1] != 'XR'
            q.cqstatus = 'quanxi' unless q.name[0..1] != 'DR'
            q.plate = cols[18].strip

            if cols[11].strip == '--'
              preq = Quotation.find_by(marketdate: pretradedate(tag), code: q.code, tag: q.tag) 
              q.open = 0 
              q.high = 0 
              q.low = 0 
              q.close = cols[14].strip
              q.dprofit = 0 
              q.volume = 0
              q.amount = 0 

              q.tpstatus = 'tingpai' 
            else
              q.open = cols[11].strip
              q.high = cols[12].strip
              q.low = cols[13].strip
              q.close = cols[3].strip

              q.dprofit = cols[2].strip
              q.volume = cols[7].strip
              q.amount = cols[16].strip
              if cols[5].strip == '--'
                q.tpstatus = 'dieting' 
              end
              if cols[6].strip == '--'
                q.tpstatus = 'zhangting' 
              end
            end

            q.tag = tag 
            q.save
          end
        end
        file.close
      end
    when 'M'
      File.open(path, 'r') do |file|
        file.each_line do |line|
          cols = line.force_encoding('gb2312').split("\t")
          m = /="(.*)"/.match(cols[0])
          unless m[1].nil? 
            #added new quotation
            q = Quotation.new
            q.marketdate = tradedate(tag)
   
            q.code = m[1].strip
            q.name = cols[1].strip
            #q.cqstatus = 'chuxi' unless q.name[0..1] != 'XD'
            #q.cqstatus = 'chuquan' unless q.name[0..1] != 'XR'
            #q.cqstatus = 'quanxi' unless q.name[0..1] != 'DR'
            q.plate = cols[14].strip

            if cols[9].strip == '--'
              preq = Quotation.find_by(marketdate: pretradedate(tag), code: q.code, tag: q.tag) 
              q.open = 0 
              q.high = 0 
              q.low = 0 
              q.close = cols[12].strip
              q.dprofit = 0 
              q.volume = 0

              q.tpstatus = 'tingpai' 
            else
              q.open = cols[9].strip
              q.high = cols[10].strip
              q.low = cols[11].strip
              q.close = cols[12].strip

              q.dprofit = cols[2].strip
              q.volume = cols[7].strip
              #if cols[5].strip == '--'
              #  q.tpstatus = 'dieting' 
              #end
              #if cols[6].strip == '--'
              #  q.tpstatus = 'zhangting' 
              #end
            end

            q.tag = tag 
            q.save
          end
        end
        file.close
      end

    when 'G'
      File.open(path, 'r') do |file|
        file.each_line do |line|
          cols = line.force_encoding('gb2312').split("\t")
          if /\d{5}/ =~ cols[0][2..6].strip
            #added new quotation
            q = Quotation.new
            q.marketdate = tradedate(tag)
   
            q.code = cols[0][2..6].strip
            q.name = cols[1].strip
            q.cqstatus = 'chuxi' unless q.name[0..1] != 'XD'
            q.cqstatus = 'chuquan' unless q.name[0..1] != 'XR'
            q.cqstatus = 'quanxi' unless q.name[0..1] != 'DR'
            q.plate = cols[14].strip

            if cols[10].strip == '--'
              preq = Quotation.find_by(marketdate: pretradedate(tag), code: q.code, tag: q.tag) 
              q.open = 0 
              q.high = 0 
              q.low = 0 
              q.close = cols[20].strip
              q.dprofit = 0 
              q.volume = 0 
              q.amount = 0 

              q.tpstatus = 'tingpai' 
            else
              q.open = cols[10].strip
              q.high = cols[11].strip
              q.low = cols[12].strip
              q.close = cols[20].strip

              q.dprofit = cols[2].strip
              q.volume = cols[6].strip
              q.amount = cols[13].strip
              #if cols[5].strip == '--'
              #  q.tpstatus = 'dieting' 
              #end
              #if cols[6].strip == '--'
              #  q.tpstatus = 'zhangting' 
              #end
            end

            q.tag = tag 
            q.save
          end
        end
        file.close
      end
    
    else

    end

	end	
		
	def updateReserves tag
		Reserf.where(marketdate: pretradedate(tag), stockstatus: 1, tag: tag).each do |reserve|
		#Reserf.joins(:quotation).where('reserves.marketdate' => pretradedate, 'reserves.stockstatus' => 1, 'quotations.tpstatus' => nil).each do |reserve|
			r = reserve.dup
			r.marketdate = tradedate(tag)
			
			r.quotation = Quotation.where(marketdate: tradedate(tag), code:reserve.quotation.code, tag:reserve.quotation.tag).first

     # if r.riskrate == 'A'
     #   unless r.hhv.nil? || r.quotation.nil? || r.hhv > r.quotation.close
     #     #r.hhv = r.quotation.close 
     #     #r.hdate = tradedate
     #     r.optadvise = 'sell'
     #     r.stockstatus = '2'
     #     r.releasedate = tradedate
     #   end
     # elsif r.riskrate == 'A-' || r.riskrate == 'B' || r.riskrate == 'B-'
     #   unless r.hhvadjust.nil? || r.quotation.nil? || r.hhvadjust > r.quotation.close
     #     #r.hhv = r.quotation.close 
     #     #r.hdate = tradedate
     #     r.optadvise = 'sell'
     #     r.stockstatus = '2'
     #     r.releasedate = tradedate
     #   end
     # else
     #   unless r.hhv.nil? || r.quotation.nil? || r.hhv > r.quotation.close
     #     #r.hhv = r.quotation.close 
     #     #r.hdate = tradedate
     #     r.optadvise = 'sell'
     #     r.stockstatus = '2'
     #     r.releasedate = tradedate
     #   end
     # end

      unless r.hhv.nil? || r.quotation.nil? || r.hhv > r.quotation.close
        #r.hhv = r.quotation.close 
        #r.hdate = tradedate
        r.optadvise = 'sell'
        r.stockstatus = '2'
        r.releasedate = tradedate(tag)
      end

			unless r.llv.nil? || r.quotation.nil? || r.llv < r.quotation.close
				#r.llv = r.quotation.close 
				#r.ldate = tradedate
				r.optadvise = 'sell'
				r.stockstatus = '0'
        r.releasedate = tradedate(tag)
			end

			r.profit = (r.hhv - r.quotation.close)/r.quotation.close unless r.hhv.nil? || r.quotation.nil? || r.quotation.close.nil? || r.quotation.close == 0
			r.loss = (r.quotation.close - r.llv)/r.quotation.close unless r.llv.nil? || r.quotation.nil? || r.quotation.close.nil? || r.quotation.close == 0
			r.positionadvise = 0.05/r.loss unless r.loss == 0
      r.positionadvise = 0.2 unless r.positionadvise < 0.2
			unless r.profit.nil? || r.loss.nil?
				if r.profit > 0 and r.loss > 0
					r.plratio = r.profit/r.loss
          if r.maxplratio.nil? || r.maxplratio<r.plratio
            r.maxplratio = r.plratio
          end
          r.winpercentage = 1/(1+r.plratio)
          if r.plratio > 2 && r.optadvise.nil?
            r.optadvise = 'buy'
            r.catchplratio = r.plratio
          end
          if r.optadvise == 'buy'
            r.optadvise = 'hold'
          end
				else
					r.plratio = 0
				end
			end
			
			r.save!	unless r.quotation.nil?
		end
	end
		
	def updatePortfolios tag
		Portfolio.where(marketdate: pretradedate(tag)).where(sellprice: nil, tag: tag).each do |portfolio|
			next unless portfolio.sellprice.nil?

			p = portfolio.dup 

			p.marketdate = tradedate(tag)
			
			p.quotation = Quotation.where(marketdate: tradedate(tag), code:portfolio.quotation.code, tag:portfolio.quotation.tag).first
			
			case p.option 
			when 'buy' #execute buy option			
				p.buyprice = p.quotation.open
				p.buydate = tradedate(tag)
				p.profit = (p.quotation.close - p.quotation.open)/p.quotation.open unless p.quotation.open == 0
				p.volum = (1.0/sysportfolio_num_max(tag))
				p.option = 'hold'
			when 'hold'	
				#p.profit = (p.quotation.close - p.buyprice)/p.buyprice
				p.profit += p.quotation.dprofit
			when 'sell' #execute sell optio, tag: tagn
				#p.profit = (p.quotation.open - p.buyprice)/p.buyprice
				p.profit += p.quotation.dprofit
				p.sellprice = p.quotation.open
				p.selldate = tradedate(tag)
				if p.account.preprofit.nil? 
					p.account.preprofit = 0
				end
				p.account.preprofit += p.profit / sysportfolio_num_max(tag)
				if p.account.pretradenum.nil? 
					p.account.pretradenum = 0
				end
				p.account.pretradenum += 1
				if p.account.prewincount.nil? 
					p.account.prewincount = 0
				end
				if p.account.prelosscount.nil? 
					p.account.prelosscount = 0
				end
				if p.profit > 0
					p.account.prewincount += 1	
				else
					p.account.prelosscount += 1	
				end
        p.account.pcount -= 1
				
			else
					
			end
			p.duration += 1 # duration init with 0
			
			p.account.save!			
			p.save!
		end
	end
	
	def updateAccounts tag
		Account.where(marketdate: pretradedate(tag)).each do |preaccount|	
      account = preaccount.dup 

      if account.pretradenum.nil?
        account.pretradenum = 0 
      end
      if account.preprofit.nil? 
        account.preprofit = 0 
      end
      if account.prewincount.nil? 
        account.prewincount = 0 
      end
      if account.prelosscount.nil? 
        account.prelosscount = 0 
      end
		
			account.tradenum = account.pretradenum
			account.profit = account.preprofit
			account.wincount = account.prewincount
			account.losscount = account.prelosscount	

			preaccount.portfolios.where(marketdate: tradedate(tag), tag: tag).each do |p|
        p.account = account
        p.save!
			end

			#Portfolio.where(account_id: account.id, marketdate: tradedate, option: 'hold').each do |p|
			preaccount.portfolios.where(marketdate: tradedate(tag), option: 'hold', tag: tag).each do |p|
				account.profit += p.profit/sysportfolio_num_max(tag)
				account.tradenum += 1
				if p.profit > 0
					account.wincount += 1	
				else
					account.losscount += 1
				end
			end
			account.winratio = account.wincount/account.tradenum unless account.tradenum == 0 or account.wincount.nil? or account.wincount < 1 or account.losscount.nil? or account.losscount < 1
			if account.profitmax.nil?
				account.profitmax = 0
			end	
			if account.lossmax.nil?
				account.lossmax = 0
			end	
			account.profitmax = account.profit unless account.profitmax.nil? or account.profit.nil? or account.profitmax > account.profit
			account.lossmax = account.profit unless account.lossmax.nil? or account.profit.nil? or account.lossmax < account.profit
			account.plratio = account.profit/account.lossmax unless account.profitmax.nil? || account.lossmax.nil? || account.lossmax == 0
			if account.duration.nil?
				account.duration = 0
			end	
			account.duration += 1 #duration init with 0
			
			account.marketdate = tradedate(tag)
			
			account.save!
		end
	end

  def reservefileprocess filename, path 
    
    fcols = filename.split("_") 
    tag = fcols[0].strip
    name = fcols[1].strip
    
    f = Indexfilter.find_by(name: name)
  
    return if f.nil?

    case tag
    when 'A'
      File.open(path, 'r') do |file|
        file.each_line do |line|
          cols = line.force_encoding('gb2312').split("\t")
          if /\d{6}/ =~ cols[0][2..7].strip
            q = Quotation.find_or_initialize_by(code: cols[0][2..7].strip, tag: tag, marketdate: tradedate(tag))
            next unless !q.nil?

            #q.marketdate = tradedate
   
            #q.code = cols[0][2..7].strip
            #q.name = cols[1].strip
            unless q.name[0,1] == '*' or q.name[0,1] == 'S' or cols[6].strip == '--' or cols[11].strip == '--'
              #q.plate = cols[18].strip

              #q.open = cols[11].strip
              #q.high = cols[12].strip
              #q.low = cols[13].strip
              #q.close = cols[3].strip
              #q.dprofit = cols[2].strip
              
              prer = Reserf.where(marketdate: tradedate(tag), quotation_id: q.id).first
              #preq = Quotation.find_by(marketdate: pretradedate, code: q.code)
              odsr = Odsreserf.find_by(code: q.code, tag: q.tag)
             
              if odsr.nil? 
                Odsreserf.create!(code: q.code, tag: q.tag, name: q.name, plate: q.plate, open: q.open, high: q.high, low: q.low, close: q.close, dprofit: q.dprofit, duration: 1)
                if prer.nil?
                  r = q.reserf.build(tag: tag, indexfilter_id: f.id, marketdate: tradedate(tag), catchdate: tradedate(tag), duration: 0, analyst_id: current_user.analyst.id )

                  r.save!
                #else
                #	r = prer.dup
                #	q.reserve << r
                end
              else
                odsr.duration = 1
                odsr.save!
              end

              q.tag = tag 
              q.save!
            end
          end
        end
        file.close
      end
    when 'M'
      File.open(path, 'r') do |file|
        file.each_line do |line|
          cols = line.force_encoding('gb2312').split("\t")
          m = /="(.*)"/.match(cols[0])
          unless m[1].nil? 
            q = Quotation.find_or_initialize_by(code: m[1].strip, tag: tag, marketdate: tradedate(tag))
            next unless !q.nil?

            #q.marketdate = tradedate
   
            #q.code = cols[0][2..7].strip
            #q.name = cols[1].strip
            unless cols[6].strip == '--' or cols[9].strip == '--'
              #q.plate = cols[18].strip

              #q.open = cols[11].strip
              #q.high = cols[12].strip
              #q.low = cols[13].strip
              #q.close = cols[3].strip
              #q.dprofit = cols[2].strip
              
              prer = Reserf.where(marketdate: tradedate(tag), quotation_id: q.id).first
              #preq = Quotation.find_by(marketdate: pretradedate, code: q.code)
              odsr = Odsreserf.find_by(code: q.code, tag: q.tag)
             
              if odsr.nil? 
                Odsreserf.create!(code: q.code, tag: q.tag, name: q.name, plate: q.plate, open: q.open, high: q.high, low: q.low, close: q.close, dprofit: q.dprofit, duration: 1)
                if prer.nil?
                  r = q.reserf.build(tag: tag, indexfilter_id: f.id, marketdate: tradedate(tag), tag: tag, catchdate: tradedate(tag), duration: 0, analyst_id: current_user.analyst.id )

                  r.save!
                #else
                #	r = prer.dup
                #	q.reserve << r
                end
              else
                odsr.duration = 1
                odsr.save!
              end

              q.tag = tag 
              q.save!
            end
          end
        end
        file.close
      end
    when 'G'
      File.open(path, 'r') do |file|
        file.each_line do |line|
          cols = line.force_encoding('gb2312').split("\t")
          if /\d{5}/ =~ cols[0][2..6].strip
            q = Quotation.find_or_initialize_by(code: cols[0][2..6].strip, tag: tag, marketdate: tradedate(tag))
            next unless !q.nil?

            #q.marketdate = tradedate
   
            #q.code = cols[0][2..7].strip
            #q.name = cols[1].strip
            unless cols[6].strip == '--' or cols[9].strip == '--'
              #q.plate = cols[18].strip

              #q.open = cols[11].strip
              #q.high = cols[12].strip
              #q.low = cols[13].strip
              #q.close = cols[3].strip
              #q.dprofit = cols[2].strip
              
              prer = Reserf.where(marketdate: tradedate(tag), quotation_id: q.id).first
              #preq = Quotation.find_by(marketdate: pretradedate, code: q.code)
              odsr = Odsreserf.find_by(code: q.code, tag: q.tag)
             
              if odsr.nil? 
                Odsreserf.create!(code: q.code, tag: q.tag, name: q.name, plate: q.plate, open: q.open, high: q.high, low: q.low, close: q.close, dprofit: q.dprofit, duration: 1)
                if prer.nil?
                  r = q.reserf.build(tag: tag, indexfilter_id: f.id, marketdate: tradedate(tag), tag: tag, catchdate: tradedate(tag), duration: 0, analyst_id: current_user.analyst.id )

                  r.save!
                #else
                #	r = prer.dup
                #	q.reserve << r
                end
              else
                odsr.duration = 1
                odsr.save!
              end

              q.tag = tag 
              q.save!
            end
          end
        end
        file.close
      end

    else

    end

	end	

  def odsreservefileprocess filename, path 
    
    fcols = filename.split("_") 
    tag = fcols[0].strip

    case tag
    when 'A'
      Odsreserf.where(tag: tag).delete_all

      File.open(path, 'r') do |file|
        file.each_line do |line|
          cols = line.force_encoding('gb2312').split("\t")
          if /\d{6}/ =~ cols[0][2..7].strip
            unless cols[1].strip.include? "ST"
             Odsreserf.create!(code: cols[0][2..7].strip, tag: tag, name: cols[1].strip, plate: cols[18].strip, open: cols[11].strip, high: cols[12].strip, low: cols[13].strip, close: cols[3].strip, dprofit: cols[2].strip, duration: 1, tag: tag)
            end
          end
        end
        file.close
      end
    when 'G'
      Odsreserf.where(tag: tag).delete_all

      File.open(path, 'r') do |file|
        file.each_line do |line|
          cols = line.force_encoding('gb2312').split("\t")
          if /\d{5}/ =~ cols[0][2..6].strip
            unless cols[1].strip.include? "ST"
             Odsreserf.create!(code: cols[0][2..7].strip, tag: tag, name: cols[1].strip, plate: cols[18].strip, open: cols[11].strip, high: cols[12].strip, low: cols[13].strip, close: cols[3].strip, dprofit: cols[2].strip, duration: 1, tag: tag)
            end
          end
        end
        file.close
      end
    when 'M'
      Odsreserf.where(tag: tag).delete_all

      File.open(path, 'r') do |file|
        file.each_line do |line|
          cols = line.force_encoding('gb2312').split("\t")
          m = /="(.*)"/.match(cols[0])
          unless m[1].nil? 
            unless cols[1].strip.include? "ST"
             Odsreserf.create!(code: cols[0][2..7].strip, tag: tag, name: cols[1].strip, plate: cols[18].strip, open: cols[11].strip, high: cols[12].strip, low: cols[13].strip, close: cols[3].strip, dprofit: cols[2].strip, duration: 1, tag: tag)
            end
          end
        end
        file.close
      end

    else

    end

	end	

  def do_duration_update tag
		#Reserve.daydata(sysmarketdate).where("optadvise == 'sell'").each do |r|
		Analyst.all.each do |analyst|
			analyst.reserves.daydata(sysmarketdate).where(tag: tag).each do |r|
			#analyst.reserve.daydata(sysmarketdate).where("optadvise == 'sell'").each do |r|
        r.duration += 1 unless r.stockstatus != '1'
        r.save!
			end
		end
	end
  
  def do_statistics_update tag
    Indexfilter.all.each do |f|
      wincount = f.wincount + Reserf.joins(:quotation).joins(:indexfilter).where("reserves.tag" => tag).where("reserves.marketdate" => tradedate(tag)).where("indexfilters.name" => f.name).where("reserves.optadvise" => "sell").where("reserves.hhv < quotations.close").where("reserves.catchplratio > 2").count
      losscount = f.losscount + Reserf.joins(:quotation).joins(:indexfilter).where("reserves.tag" => tag).where("reserves.marketdate" => tradedate(tag)).where("indexfilters.name" => f.name).where("reserves.optadvise" => "sell").where("reserves.llv > quotations.close").where("reserves.catchplratio > 2").count
      f.update!(wincount: wincount)
      f.update!(losscount: losscount)
    end
    
  end

  def do_riskrate tag
    
    Reserf.where(marketdate: tradedate(tag), tag: tag).update_all(riskrate:'')

    maxloss = 5 * 0.05

    Reserf.joins(:quotation).where('reserves.marketdate' => tradedate(tag), 'reserves.stockstatus' => '1', 'quotations.tpstatus' => nil, 'reserves.tag' => tag).where("reserves.loss <= ?", maxloss).order(plratio: :desc).update_all(riskrate:'A')

    reserves_A2 = Reserf.joins(:quotation).where('reserves.marketdate' => tradedate(tag), 'reserves.stockstatus' => '1', 'quotations.tpstatus' => nil, 'reserves.tag' => tag).where("reserves.loss > ?", maxloss).order(loss: :asc).limit(5)
    reserves_A2.each do |r|
      r.update(riskrate:'A-',hhvadjust:r.quotation.close*(1+(2*r.loss)))
    end

    reserves_B = Reserf.joins(:quotation).where('reserves.marketdate' => tradedate(tag), 'quotations.tpstatus' => nil, 'reserves.tag' => tag).where("reserves.plratio < 2").where("reserves.loss <= ?", maxloss).order(plratio: :desc).limit(5)
    reserves_B.each do |r|
      r.update(riskrate:'B',hhvadjust:r.quotation.close*(1+(2*r.loss)))
    end
    reserves_B2 = Reserf.joins(:quotation).where('reserves.marketdate' => tradedate(tag), 'quotations.tpstatus' => nil, 'reserves.tag' => tag).where("reserves.plratio < 2").where("reserves.loss > ?", maxloss).order(loss: :asc).limit(5) 
    reserves_B2.each do |r|
      r.update(riskrate:'B-',hhvadjust:r.quotation.close*(1+(2*r.loss)))
    end

  end

	# data 	
	def doadvise tag 
		#Reserve.daydata(sysmarketdate).where("optadvise == 'sell'").each do |r|
		Analyst.all.each do |analyst|
			analyst.reserves.daydata(sysmarketdate).where(tag: tag).each do |r|
			#analyst.reserve.daydata(sysmarketdate).where("optadvise == 'sell'").each do |r|
        #r.duration += 1 unless r.stockstatus != '1'
        #r.save!
        unless r.optadvise != 'sell'
          #Portfolio.daydata(tradedate).each do |p|
          analyst.accounts.each do |account|
            account.portfolios.daydata(tradedate(tag)).where(tag: tag).each do |p|
              if p.quotation.code == r.quotation.code && p.quotation.tag == r.quotation.tag
                p.option = r.optadvise 
                p.save!
              end
            end
          end
				end
			end
		end
	end

  def dataclean tag
    dm = Sysconfig.find_by(cfgname: 'durationmax', tag: tag).cfginteger

    Odsreserf.where("duration > ?", dm,).where(tag: tag).delete_all

    Odsreserf.where(tag: tag).update_all("duration = duration + 1")
  end

  def cleandatatotoday tag
    Quotation.where("marketdate >= ?", tradedate(tag)).where(tag: tag).delete_all
    Reserf.where("marketdate >= ?", tradedate(tag)).where(tag: tag).delete_all

    Sysconfig.find_by(cfgname: 'batchname', tag: tag).update!(cfgstring: 'datechange')
  end
	
	def guanzhu openid
    #logger.info "guanzhu >>>>>>>>>>>>>>" + openid
    resp = ""
    u = User.find_by(openid: openid)
    if u.nil?
      attributes = {openid: openid, weixinstatus: 1, guanzhudate: Time.new, email: "#{openid}@weixin.com", password: openid[1..8]}
      #attributes = {openid: openid, weixinstatus: 1, guanzhudate: tradedate(tag), email: "#{openid}@weixin.com", password: openid[1..8]}
      #attributes = {openid: '123'}
      User.create!(attributes)	
      resp = welcome_message
    else
      u.update(weixinstatus: 1, quxiaoguanzhudate: '')
      resp = welcome_again_message 
    end
    resp
	end

  def usercheck openid
    #logger.info "guanzhu >>>>>>>>>>>>>>" + openid
    u = User.find_by(openid: openid)
    if u.nil?
      attributes = {openid: openid, weixinstatus: 1, guanzhudate: tradedate(tag), email: "#{openid}@weixin.com", password: openid[1..8]}
      User.create!(attributes)	
    else
      if u.weixinstatus == 0
        u.update(weixinstatus: 1, quxiaoguanzhudate: '')
        welcome_again_message 
      end
    end
	end


  def welcome_again_message 
    "朋友，欢迎回到三元量化投资模型。\n输入“0”获取操作帮助信息。\n"
  end
  def welcome_message
    resumeinfo
  end

  def quxiaoguanzhu openid
    #logger.info "quxiao guanzhu >>>>>>>>>>>>>>" + openid
    User.find_by(openid: openid).update(weixinstatus: 0, quxiaoguanzhudate: Time.new)
    #User.find_by(openid: openid).update(weixinstatus: 0, quxiaoguanzhudate: tradedate(tag))
  end 
	
	def gensui u=nil,accountname=nil,analystname=nil
    return if u.nil? || accountname.nil? || analystname.nil?
		#u = User.find_by(openid: '1')
    a = u.accounts.where(name: accountname)
    #a = u.accounts.where(name: 'wenjian')
    unless a.nil?
      analyst = Analyst.find_by(name: analystname)	
      #analyst = Analyst.find_by(name: 'sys')	
      unless analyst.nil?
        analyst.accounts << a	
        analyst.save!
      end
    end
	end
	
	def createAccount useropenid, accountname, accountpsize, accountsinglerisk
		u = User.find_by(openid: useropenid)
		unless u.nil?
			#return if u.accounts.size == sysaccount_num_max
		  a = u.accounts.create(setdate: tradedate(tag), name: accountname, pcount:0,  psize: accountpsize, singlerisk: accountsinglerisk)
		end
    a 
	end

	
	def jiangu useropenid,accountname,code=nil
		u = User.find_by(openid: useropenid)
		a = u.accounts.find_by(name: accountname)
		unless u.nil? || a.nil? || a.portfolios.where(marketdate: tradedate(tag)).where.not(option: 'sell').count >= sysportfolio_num_max(tag)
  
      if code.nil? 		
        rarr = []
        #Reserve.daydata(tradedate).where(optadvise: 'buy').each do |r|
        a.analyst.reserves.daydata(tradedate(tag)).where(optadvise: 'buy').where("loss < ?", (a.psize * a.singlerisk) ).each do |r|
          rarr.push r.quotation.code	
        end
        parr = []
        Portfolio.daydata(tradedate(tag)).where.not(option: 'sell').where(account_id: a.id).each do |p|
          parr.push p.quotation.code
        end
        rarr -= parr
        code = rarr[Random.rand(rarr.length)] unless rarr.length == 0
      end
			q = Quotation.find_by("code = ? and marketdate = ?", code, tradedate(tag))	unless code.nil? 
			p = q.portfolio.build unless q.nil?
			unless p.nil?
				p.marketdate = tradedate(tag)
				p.volum = (1.0/sysportfolio_num_max(tag))
				p.duration = 0
				p.option = 'buy'
				p.save!
				a.portfolios << p
        a.pcount = a.pcount + 1
				a.save!
				u.save!
			end

		end
	end

  def allportfolios tag

      #Reserf.where(optadvise: 'sell').where(catchplratio: nil).each do |r|
      #  c = Reserf.joins(:quotation).where("quotations.code" => r.quotation.code).where("reserves.marketdate" => r.catchdate).first
      #  Reserf.joins(:quotation).where("quotations.code" => r.quotation.code).update_all(catchplratio: c.plratio) unless c.nil?
      #end

      #return 

      maxloss = 5 * 0.05

      #if Sysconfig.find_by(cfgname: 'batchname').cfgstring != 'datechange' 
      #  @reserves = Reserf.where(marketdate: tradedate, optadvise: 'buy').where("loss <= ?", maxloss).order(plratio: :desc)
      #else 
      #  @reserves = Reserf.where(marketdate: pretradedate, optadvise: 'buy').where("loss <= ?", maxloss).order(plratio: :desc)
      #end
      @reserves = Reserf.where(marketdate: pretradedate(tag), riskrate: 'A', tag: tag).where("loss <= ?", maxloss).order(plratio: :desc)

    	i = 1	
      @allportfolios = "【#{pretradedate(tag)}】 \n序号 编码 名称 风险率 当前价 板块\n" 
      @reserves.each do |r|
        @allportfolios = @allportfolios + "(#{i}). " 
        @allportfolios = @allportfolios + r.quotation.code + ' ' 
        @allportfolios = @allportfolios + r.quotation.name + ' ' 
        @allportfolios = @allportfolios + format('%0.1f', (100 * r.loss)).to_s + '% '
        @allportfolios = @allportfolios + format('%0.2f', r.quotation.close).to_s + ' ' 
        @allportfolios = @allportfolios + r.quotation.plate + "\n"


    	#i = 1	
      #@allportfolios = "【#{tradedate}】 \n序号 编码 名称 盈亏比 风险率 当前价 止盈 止损 板块\n" 
      #@reserves.each do |r|
      #  @allportfolios = @allportfolios + "(#{i}). " 
      #  @allportfolios = @allportfolios + r.quotation.code + ' ' 
      #  @allportfolios = @allportfolios + r.quotation.name + ' ' 
      #  @allportfolios = @allportfolios + format('%0.1f', r.plratio).to_s + '倍 ' 
      #  @allportfolios = @allportfolios + format('%0.1f', (100 * r.loss)).to_s + '% '
      #  @allportfolios = @allportfolios + format('%0.2f', r.quotation.close).to_s + ' ' 
      #  @allportfolios = @allportfolios + format('%0.2f', r.hhv).to_s + ' ' 
      #  @allportfolios = @allportfolios + format('%0.2f', r.llv).to_s + ' ' 
      #  @allportfolios = @allportfolios + r.quotation.plate + "\n"

				i = i + 1
      end
      logger.info @allportfolios
      @allportfolios

  end

  def accountopttips name, tag
		u = User.find_by(openid: '1')
    a = u.accounts.find_by(name: name)

    i = 1	
    @allportfolios = "【#{tradedate(tag)}】 \n序号 编码 名称 当前价 板块 成本价 建议 持有期\n" 
    if Sysconfig.find_by(cfgname: 'batchname').cfgstring != 'datechange' 
      ps = a.portfolios.where(marketdate: tradedate(tag))
    else
      ps = a.portfolios.where(marketdate: pretradedate(tag))
    end

    ps.each do |p|
      @allportfolios = @allportfolios + "(#{i}). " 
      @allportfolios = @allportfolios + p.quotation.code + ' ' 
      @allportfolios = @allportfolios + p.quotation.name + ' ' 
      @allportfolios = @allportfolios + format('%0.2f', p.quotation.close).to_s + ' ' 
      @allportfolios = @allportfolios + p.quotation.plate + ' ' 
      if p.buyprice.nil?
        @allportfolios = @allportfolios + format('%0.2f', 0).to_s + ' ' 
      else
        @allportfolios = @allportfolios + format('%0.2f', p.buyprice).to_s + ' ' 
      end
      @allportfolios = @allportfolios + p.option + ' ' 
      @allportfolios = @allportfolios + p.duration.to_s + "\n" 

      i = i + 1
    end
    logger.info @allportfolios
    @allportfolios
  
  end
	
	def shouyi
		u = User.find_by(openid: '1')
		a = u.accounts.find_by(name: 'wenjian')
		unless u.nil? || a.nil?
			g = Gruff::Line.new(800)
			g.title = 'shouyi'		
			#g.labels = { 0 => '5/6', 1 => '5/15', 2 => '5/24', 3 => '5/30', 4 => '6/4', 5 => '6/12', 6 => '6/21', 7 => '6/28' }
			keys = []
			values = []
			ms = Account.where("marketdate <= ?", tradedate(tag)).order(marketdate: :desc).limit(8).pluck(:marketdate)
			ms.reverse!.each_index do |i|
				keys << i
				values << ms[i].strftime("%m-%d")
			end
			g.labels = Hash[*keys.zip(values).flatten]
			logger.info g.labels.inspect

			g.data :test, Account.order(:marketdate).limit(8).pluck(:profit)
			#g.data :Arthur, [5, 10, 13, 11, 6, 16, 22, 32]
			#g.write("/downloads/png/" + tradedate.strftime("%Y-%m-%d") + "_" + a.id.to_s + ".png")
			#g.write(a.avatar.path)
			g.write("#{Rails.root}/public/downloads/1.png")
			file = File.open("#{Rails.root}/public/downloads/1.png")
			a.update(avatar: file)
      file.close
		end
	end		

  def batopt
    i = 1 
    Reserf.where(marketdate: '2015-02-06', stockstatus: '1').each do |r|
      opt = Reserf.joins(:quotation).where("quotations.code" => r.quotation.code).where("reserves.plratio > 2").first
      #logger.info "#{i} #{opt.quotation.code}" unless opt.nil?
      unless opt.nil?
        datestart = opt.marketdate
        #logger.info datestart
        opt.update(catchdate: datestart, catchplratio: opt.plratio, optadvise: 'buy')
        Reserf.joins(:quotation).where("quotations.code" => r.quotation.code).where("reserves.marketdate > '" + "#{datestart}" + "'").each do |item|
          Reserf.find(item.id).update(catchdate: datestart, catchplratio: opt.plratio, optadvise: 'hold')
        end
        i = i + 1
      end
    end
  end

	def valid_attributes(attributes={})
    { name: "usertest",
      email: generate_unique_email,
      password: '12345678',
      password_confirmation: '12345678' }.update(attributes)
  end	

	def generate_unique_email
    @@email_count ||= 0
    @@email_count += 1
    "test#{@@email_count}@example.com"
  end

  def resumeinfo
    resumeinfo = "本模型基于交易盈利的核心三元素设计而成，包括交易胜率、交易盈亏比及交易笔数；\n"
    resumeinfo = resumeinfo + "其中以选股模型保证交易胜率、以盈亏分析系统保证盈亏比率，依托量化分析在高胜率及优势盈亏比基础上，确保了每笔交易都能有明确的进出场操作点。\n"
    resumeinfo = resumeinfo + "而最终的盈利往往是由时间及市场行情共同作用产生的。\n"
    resumeinfo = resumeinfo + "跟随本模型来进行交易操作训练将会培养投资者科学且可持续盈利的操作习惯，以便于从万千散户中脱颖而出，取得良好的投资收益。\n"
    resumeinfo = resumeinfo + "输入“0”获得操作帮助信息。"
    resumeinfo
  end

  def everydaytip
    #n = Everydaytip.count
    #Everydaytip.find_by(id: rand(n) + 1).tip
    Everydaytip.order('rand()').limit(1).first.tip
  end
  
  def rand_ebook
    Ebook.order('rand()').limit(1).first
  end

  def helpinfo
    helpinfo = "输入数字 1 【简介】查看模型介绍。\n"
    helpinfo = helpinfo + "输入数字 2 【心得】获得每日一帖。\n"
    helpinfo = helpinfo + "输入数字 3 【展示】获得跟随模型账户收益展示。\n"
    helpinfo = helpinfo + "输入数字 4 【组合】可以获得当前的股票组合信息。\n"
    helpinfo = helpinfo + "输入数字 5 【推广】通过二维码把我们介绍给您的朋友。\n"
    helpinfo = helpinfo + "输入股票代码【操作】查询模型股票池内的股票操作点。\n"
    helpinfo
  end

  def tginfo
    tginfo = "如果您觉得我们的模型对您有帮助，希望您将他们推荐给你的朋友，让更多的人可以一起提高。"
  end

  def account_show 
    account_show = "趋势投资/量化交易 严格根据三元投资模型进行交易，不追求短线暴利（非常适合上班族们的节奏），正如和讯网本策略师账户展现的一样：稳健交易，稳定获利，中长线持有正是本模型的宗旨。都知道：在股市，从来交易都是勤劳致富，而是风险管理致富。降低交易频率，提高成功概率，市场上没有必然的东西，而每笔交易却可以站在胜率较大的一方。"
  end

  def qrcodegen
     'http://115.29.186.47' + Sysconfig.find_by(cfgname: 'qrcode').imgfile.url(:thumb)
    #url_for(action: 'index', only_path: false) + Sysconfig.find_by(cfgname: 'qrcode').imgfile.url(:thumb, only_path: false)
    #'http://115.29.186.47/system/sysconfigs/imgfiles/000/000/031/thumb/qrcode_for_gh_dcd284e0cb4a_1280.jpg?1409886793'
  end

  def qrcode_url size='thumb'
    Sysconfig.find_by(cfgname: 'qrcode').imgfile.url(size)
  end

  def cfg_image_url name, size='thumb'
    'http://115.29.186.47' + Sysconfig.find_by(cfgname: name).imgfile.url(size)
  end

  def get_pub_account_show_url
    'http://c.hexun.com/stratdetail_tag2014.aspx?sid=26803' 
  end

  def get_pub_index_url
    'http://115.29.186.47/pub/index'
  end

  def rand_image_url size='thumb'
    'http://115.29.186.47' + Imgdepot.order('rand()').limit(1).first.imgfile.url(size)
  end

  def frontcover_url ebook, size='weixin'
    'http://115.29.186.47' + ebook.frontcover.url(size)
  end

  def optquery tag, code
    	q = Quotation.where(tag: tag).where("code = :code", {code: "#{code}"}).order(marketdate: :desc).first
    	#q = Quotation.where(tag: tag, code: code).order(marketdate: :desc).first
      ret = ""
      unless q.nil? or q.reserf.first.nil?
        ret = "【#{q.marketdate}】：#{q.code} #{q.name} 止盈：#{q.reserf.first.hhv} / 止损：#{q.reserf.first.llv}"
      else 
        ret = "该股票不在股票池中。"
      end
      ret
  end

  def user_account_advise
    User.where.not(openid:'1').each do |u|
      u.accounts.each do |a|
        jiangu(u.openid,a.name) unless u.autostock == 0 
      end 
    end 
  end
  
  def sys_account_advise tag
		u = User.find_by(openid: '1')
    
    return if u.nil?
    
    gpcyestody = Quotation.joins(:reserf).where('reserves.marketdate' => pretradedate(tag), 'reserves.optadvise' => 'buy').pluck(:code)
    gpctoday = Quotation.joins(:reserf).where('reserves.marketdate' => tradedate(tag), 'reserves.optadvise' => 'buy').pluck(:code)

    gpc = gpctoday
    gpc = gpc - gpcyestoday unless u.accounts.count == 0

    #(gpctoday - gpcyestody).each do |code|
    gpc.each do |code|
      account = getfreeaccount
      jiangu(u.openid, account.name, code)
    end
  end
  
  def getfreeaccount
		u = User.find_by(openid: '1')
    a = u.accounts.where("pcount<psize").first 
    accountname = genSysAccountName
    a = createAccount('1', accountname, 5, 0.05) unless a.nil?
  end

  def genSysAccountName
		u = User.find_by(openid: '1')
    a = u.account.order(name: :desc).first 
    if a.nil? || a.name.nil?
      num = 1 
    else
      num = a.name[-3..-1].to_i
      num += 1
    end
    accountname = 'sys' + num.to_s.rjust(3)
  end

end
