class EverydaytipsController < ApplicationController
	before_filter :authenticate_user!, except: [:pubindex]
  before_action :set_everydaytip, only: [:show, :edit, :update, :destroy]

  before_action :load_everydaytip, only: [:create]
  load_and_authorize_resource

  # GET /everydaytips
  # GET /everydaytips.json
  def index
    @ebook = Ebook.find(params[:ebook_id])
    @everydaytips = @ebook.everydaytips.order(created_at: :desc).page(params[:page])
    #@everydaytips = Everydaytip.all.order(created_at: :desc).page(params[:page])
  end

  # GET /all_everydaytips
  # GET /all_everydaytips.json
  def all 
    @everydaytips = Everydaytip.all.order(created_at: :desc).page(params[:page])
  end


  # GET /everydaytips/1
  # GET /everydaytips/1.json
  def show
  end

   # GET /everydaytips/new
  def new
    @ebook = Ebook.find(params[:ebook_id])
    @everydaytip = @ebook.everydaytips.build()
    #@everydaytip = Everydaytip.new
  end

  # GET /everydaytips/1/edit
  def edit
    @everydaytip = Everydaytip.find(params[:id])
  end

  # POST /everydaytips
  # POST /everydaytips.json
  def create
    #@everydaytip = Everydaytip.new(everydaytip_params)
    @ebook = Ebook.find(params[:ebook_id])
    @everydaytip = @ebook.everydaytips.build(everydaytip_params)

    respond_to do |format|
      if @everydaytip.save
        format.html { redirect_to everydaytip_path(@everydaytip), notice: 'Everydaytip was successfully created.' }
        format.json { render :show, status: :created, location: @everydaytip }
      else
        format.html { render :new }
        format.json { render json: @everydaytip.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /everydaytips/1
  # PATCH/PUT /everydaytips/1.json
  def update
    respond_to do |format|
      if @everydaytip.update(everydaytip_params)
        format.html { redirect_to everydaytip_path(@everydaytip), notice: 'Everydaytip was successfully updated.' }
        format.json { render :show, status: :ok, location: @everydaytip }
      else
        format.html { render :edit }
        format.json { render json: @everydaytip.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /everydaytips/1
  # DELETE /everydaytips/1.json
  def destroy
    @everydaytip.destroy
    respond_to do |format|
      format.html { redirect_to ebook_everydaytips_url(@everydaytip.ebook), notice: 'Everydaytip was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_everydaytip
      @everydaytip = Everydaytip.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def everydaytip_params
      params.require(:everydaytip).permit(:tip)
    end

    def load_everydaytip
      @everydaytip = Everydaytip.new(everydaytip_params)
    end
end
