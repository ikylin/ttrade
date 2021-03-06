class QuotationsController < ApplicationController
	include ReservesHelper
  include QuotationdatafilesHelper
	before_filter :authenticate_user!
  before_action :set_quotation, only: [:show, :edit, :update, :destroy]

  load_and_authorize_resource

  # GET /quotations
  # GET /quotations.json
  def index
    case params[:qtype]
    when 'yestoday'
      @quotations = Quotation.where(tag: params[:tag]).daydata(pretradedate(params[:tag])).page(params[:page])
    when 'today'
      @quotations = Quotation.where(tag: params[:tag]).daydata(tradedate(params[:tag])).page(params[:page])
    when 'all'
      @quotations = Quotation.where(tag: params[:tag]).page(params[:page])
    when 'status'
      #@quotations = Quotation.daydata(tradedate).where(cqstatus: "#{params[:cqstatus]}")
      #@quotations = Quotation.daydata(tradedate).where(cqstatus: %w{chuquan quanxi} ).page(params[:page])
      codes = Quotation.daydata(tradedate(params[:tag])).where(cqstatus: %w{chuquan quanxi}, tag: params[:tag]).pluck(:code)
      @reserves = Reserf.joins(:quotation).where("reserves.marketdate" => pretradedate(params[:tag]), "quotations.tag" => params[:tag]).where("reserves.stockstatus" => 1).where("quotations.code" => codes).page(params[:page])
      render "reserves/index" 
    else

    end
  end

  # GET /quotations/1
  # GET /quotations/1.json
  def show
  end

  # GET /quotations/new
  def new
    @quotation = Quotation.new
  end

  # GET /quotations/1/edit
  def edit
  end

  # POST /quotations
  # POST /quotations.json
  def create
    @quotation = Quotation.new(quotation_params)

    respond_to do |format|
      if @quotation.save
        format.html { redirect_to @quotation, notice: 'Quotation was successfully created.' }
        format.json { render :show, status: :created, location: @quotation }
      else
        format.html { render :new }
        format.json { render json: @quotation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /quotations/1
  # PATCH/PUT /quotations/1.json
  def update
    respond_to do |format|
      if @quotation.update(quotation_params)
				@quotation.reserve.where(marketdate: @quotation.marketdate).each do |reserve|
					reserve_update_hhv_llv(reserve)
				end
        format.html { redirect_to @quotation, notice: 'Quotation was successfully updated.' }
        format.json { render :show, status: :ok, location: @quotation }
      else
        format.html { render :edit }
        format.json { render json: @quotation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /quotations/1
  # DELETE /quotations/1.json
  def destroy
    @quotation.destroy
    respond_to do |format|
      format.html { redirect_to quotations_url, notice: 'Quotation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quotation
      @quotation = Quotation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def quotation_params
      params.require(:quotation).permit(:marketdate, :code, :name, :plate, :open, :high, :low, :close, :dprofit)
    end
end
