class ReservesController < ApplicationController
	include ReservesHelper
	include QuotationdatafilesHelper
	before_filter :authenticate_user!, except: [:pubindex]
  before_action :set_reserf, only: [:show, :edit, :update, :destroy]

  load_and_authorize_resource :except => [:pubindex]

  # GET /reserf
  # GET /reserf.json
  def index
		case params["qtype"]
		when 'status'
      if params['status'] == '1'
    	  @reserves = Reserf.where(tag: params[:tag], marketdate: true_trade_date(params[:tag]), stockstatus: "#{params['status']}").order(plratio: :desc).page(params[:page])
      else
    	  @reserves = Reserf.where(tag: params[:tag], stockstatus: "#{params['status']}").order(marketdate: :desc).page(params[:page])
      end
		when 'advise'
      unless params['indexfilter'].nil?
        if params['optadvise'] == 'wait'        
          if Sysconfig.find_by(tag: params[:tag], cfgname: 'batchname').cfgstring != 'datechange' 
            @reserves = Reserf.joins(:quotation).joins(:indexfilter).where("reserves.tag" => params[:tag]).where("indexfilters.name" => params[:indexfilter]).where("reserves.catchplratio > 2").where("reserves.marketdate" => tradedate(params[:tag])).where("reserves.stockstatus" => '1').order(plratio: :desc).page(params[:page])
          else 
            @reserves = Reserf.joins(:quotation).joins(:indexfilter).where("reserves.tag" => params[:tag]).where("indexfilters.name" => params[:indexfilter]).where("reserves.catchplratio > 2").where("reserves.marketdate" => pretradedate(params[:tag])).where("reserves.stockstatus" => '1').order(plratio: :desc).page(params[:page])
          end
        elsif params['optadvise'] == 'win'        
          @reserves = Reserf.joins(:quotation).joins(:indexfilter).where("reserves.tag" => params[:tag]).where("indexfilters.name" => params[:indexfilter]).where("reserves.catchplratio > 2").where("reserves.stockstatus" => '2').order(plratio: :desc).page(params[:page])
        elsif params['optadvise'] == 'loss'        
          @reserves = Reserf.joins(:quotation).joins(:indexfilter).where("reserves.tag" => params[:tag]).where("indexfilters.name" => params[:indexfilter]).where("reserves.catchplratio > 2").where("reserves.stockstatus" => '0').order(plratio: :desc).page(params[:page])
        end
      else
        if Sysconfig.find_by(tag: params[:tag], cfgname: 'batchname').cfgstring != 'datechange' 
          @reserves = Reserf.where(tag: params[:tag], marketdate: tradedate(params[:tag]), optadvise: "#{params['optadvise']}").order(plratio: :desc).page(params[:page])
        else 
          @reserves = Reserf.where(tag: params[:tag], marketdate: pretradedate(params[:tag]), optadvise: "#{params['optadvise']}").order(plratio: :desc).page(params[:page])
        end
      end
		when 'catch'
    	@reserves = Reserf.where(tag: params[:tag], marketdate: tradedate(params[:tag]), catchdate: tradedate(params[:tag])).order(plratio: :desc).page(params[:page])
		when 'yestoday'
    	@reserves = Reserf.daydata(pretradedate(params[:tag])).where(tag: params[:tag]).order(plratio: :desc).page(params[:page])
		when 'today'
    	@reserves = Reserf.daydata(tradedate(params[:tag])).where(tag: params[:tag]).order(plratio: :desc).page(params[:page])
		else
    	#@reserves = Reserf.order(plratio: :desc)
    	@reserves = Reserf.where(tag: params[:tag], marketdate: tradedate(params[:tag])).order(plratio: :desc).page(params[:page])
		end
  end

  def pubindex
    maxloss = 5 * 0.05
    tag = params[:tag]
    tag = 'A' if tag.nil?

    if params[:md].nil? 
      if Sysconfig.where(tag: tag, cfgname: 'batchname').first.cfgstring != 'datechange' 
        #@reserves_A = Reserf.where(marketdate: tradedate, optadvise: 'buy').where("loss <= ?", maxloss).order(plratio: :desc)
        #@reserves_A2 = Reserf.where(marketdate: tradedate, optadvise: 'buy').where("loss > ?", maxloss).order(loss: :asc).limit(5)
        #@reserves_B = Reserf.where(marketdate: tradedate).where("plratio < 2").where("loss <= ?", maxloss).order(plratio: :desc).limit(5)
        #@reserves_B2 = Reserf.where(marketdate: tradedate).where("plratio < 2").where("loss > ?", maxloss).order(loss: :asc).limit(5)

        @reserves_A = Reserf.where(tag: tag, marketdate: pretradedate(tag), riskrate: 'A').order(plratio: :desc)
        @reserves_A2 = Reserf.where(tag: tag, marketdate: pretradedate(tag), riskrate: 'A-').order(loss: :asc).limit(5)
        @reserves_B = Reserf.where(tag: tag, marketdate: pretradedate(tag), riskrate: 'B').order(plratio: :desc).limit(5)
        @reserves_B2 = Reserf.where(tag: tag, marketdate: pretradedate(tag), riskrate: 'B-').order(loss: :asc).limit(5)

        @cutloss = Reserf.where(tag: tag, marketdate: pretradedate(tag), optadvise: 'sell', stockstatus: '0').order(plratio: :desc)
        @cutprofit = Reserf.where(tag: tag, marketdate: pretradedate(tag), optadvise: 'sell', stockstatus: '2').order(plratio: :desc)

        #@reserves_A = Reserf.where(marketdate: tradedate, riskrate: 'A').order(plratio: :desc)
        #@reserves_A2 = Reserf.where(marketdate: tradedate, riskrate: 'A-').order(loss: :asc).limit(5)
        #@reserves_B = Reserf.where(marketdate: tradedate, riskrate: 'B').order(plratio: :desc).limit(5)
        #@reserves_B2 = Reserf.where(marketdate: tradedate, riskrate: 'B-').order(loss: :asc).limit(5)

        #@cutloss = Reserf.where(marketdate: tradedate, optadvise: 'sell', stockstatus: '0').order(plratio: :desc)
        #@cutprofit = Reserf.where(marketdate: tradedate, optadvise: 'sell', stockstatus: '2').order(plratio: :desc)
      else 
        #@reserves_A = Reserf.where(marketdate: pretradedate, optadvise: 'buy').where("loss <= ?", maxloss).order(plratio: :desc)
        #@reserves_A2 = Reserf.where(marketdate: pretradedate, optadvise: 'buy').where("loss > ?", maxloss).order(loss: :asc).limit(5)
        #@reserves_B = Reserf.where(marketdate: pretradedate).where("plratio < 2").where("loss <= ?", maxloss).order(plratio: :desc).limit(5)
        #@reserves_B2 = Reserf.where(marketdate: pretradedate).where("plratio < 2").where("loss > ?", maxloss).order(loss: :asc).limit(5)

        @reserves_A = Reserf.where(tag: tag, marketdate: pretradedate(tag), riskrate: 'A').order(plratio: :desc)
        @reserves_A2 = Reserf.where(tag: tag, marketdate: pretradedate(tag), riskrate: 'A-').order(loss: :asc).limit(5)
        @reserves_B = Reserf.where(tag: tag, marketdate: pretradedate(tag), riskrate: 'B').order(plratio: :desc).limit(5)
        @reserves_B2 = Reserf.where(tag: tag, marketdate: pretradedate(tag), riskrate: 'B-').order(loss: :asc).limit(5)

        @cutloss = Reserf.where(tag: tag, marketdate: pretradedate(tag), optadvise: 'sell', stockstatus: '0').order(plratio: :desc)
        @cutprofit = Reserf.where(tag: tag, marketdate: pretradedate(tag), optadvise: 'sell', stockstatus: '2').order(plratio: :desc)
      end
    else
      #@reserves_A = Reserf.where(marketdate: params[:md], optadvise: 'buy').where("loss <= ?", maxloss).order(plratio: :desc)
      #@reserves_A2 = Reserf.where(marketdate: params[:md], optadvise: 'buy').where("loss > ?", maxloss).order(loss: :asc).limit(5)
      #@reserves_B = Reserf.where(marketdate: params[:md]).where("plratio < 2").where("loss <= ?", maxloss).order(plratio: :desc).limit(5)
      #@reserves_B2 = Reserf.where(marketdate: params[:md]).where("plratio < 2").where("loss > ?", maxloss).order(loss: :asc).limit(5)

      @reserves_A = Reserf.where(tag: tag, marketdate: params[:md], riskrate: 'A').order(plratio: :desc)
      @reserves_A2 = Reserf.where(tag: tag, marketdate: params[:md], riskrate: 'A-').order(loss: :asc).limit(5)
      @reserves_B = Reserf.where(tag: tag, marketdate: params[:md], riskrate: 'B').order(plratio: :desc).limit(5)
      @reserves_B2 = Reserf.where(tag: tag, marketdate: params[:md], riskrate: 'B-').order(loss: :asc).limit(5)

      @cutloss = Reserf.where(tag: tag, marketdate: params[:md], optadvise: 'sell', stockstatus: '0').order(plratio: :desc)
      @cutprofit = Reserf.where(tag: tag, marketdate: params[:md], optadvise: 'sell', stockstatus: '2').order(plratio: :desc)
    end
    

    respond_to do |format|
      format.html {render :pubindex, layout: 'public'} 
    end
    

  end
  
  def qcode
      @reserves = []
    	Quotation.where(tag: params[:tag]).where("code = :code or name like :name", {code: params[:qcode], name: "%#{params[:qcode]}%"}).order(marketdate: :desc).each do |q|
    	#Quotation.where(code: params[:qcode]).order(marketdate: :desc).each do |q|
        @reserves = @reserves + q.reserf
      end
  end

  # GET /reserf/1
  # GET /reserf/1.json
  def show
  end

  # GET /reserf/new
  def new
    @reserve = Reserf.new
  end

  # GET /reserf/1/edit
  def edit
    respond_to do |format|
      format.html { render :new }
      format.json { render json: @reserve }
    end
  end

  # POST /reserf
  # POST /reserf.json
  def create
    @reserve = Reserf.new(reserf_params)

    respond_to do |format|
      if @reserve.save
        format.html { redirect_to @reserve, notice: 'Reserf was successfully created.' }
        format.json { render :show, status: :created, location: @reserve }
      else
        format.html { render :new }
        format.json { render json: @reserve.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reserf/1
  # PATCH/PUT /reserf/1.json
  def update
    respond_to do |format|
      if @reserve.update(reserf_params)
				reserve_update_hhv_llv(@reserve)
        format.html { redirect_to @reserve, notice: 'Reserf was successfully updated.' }
        format.json { render :show, status: :ok, location: @reserve }
      else
        format.html { render :edit }
        format.json { render json: @reserve.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reserf/1
  # DELETE /reserf/1.json
  def destroy
    @reserve.destroy
    respond_to do |format|
      format.html { redirect_to reserf_url, notice: 'Reserf was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reserf
      @reserve = Reserf.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def reserf_params
      params.require(:reserf).permit(:marketdate, :stockstatus, :riskrate, :hhv, :hhvadjust, :llv, :hdate, :ldate, :profit, :loss, :plratio, :catchplratio, :optadvise, :note)
    end
		
end
