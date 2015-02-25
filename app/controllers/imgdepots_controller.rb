class ImgdepotsController < ApplicationController
	before_filter :authenticate_user!
  before_action :set_imgdepot, only: [:show, :edit, :update, :destroy]

  before_action :load_imgdepot, only: [:create]
  load_and_authorize_resource

  # GET /imgdepots
  # GET /imgdepots.json
  def index
    @imgdepots = Imgdepot.order(created_at: :desc).page(params[:page])
  end

  # GET /imgdepots/1
  # GET /imgdepots/1.json
  def show
  end

  # GET /imgdepots/new
  def new
    @imgdepot = Imgdepot.new
  end

  # GET /imgdepots/1/edit
  def edit
  end

  # POST /imgdepots
  # POST /imgdepots.json
  def create
    @imgdepot = Imgdepot.new(imgdepot_params)

    respond_to do |format|
      if @imgdepot.save
        format.html { redirect_to @imgdepot, notice: 'Imgdepot was successfully created.' }
        format.json { render :show, status: :created, location: @imgdepot }
      else
        format.html { render :new }
        format.json { render json: @imgdepot.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /imgdepots/1
  # PATCH/PUT /imgdepots/1.json
  def update
    respond_to do |format|
      if @imgdepot.update(imgdepot_params)
        format.html { redirect_to @imgdepot, notice: 'Imgdepot was successfully updated.' }
        format.json { render :show, status: :ok, location: @imgdepot }
      else
        format.html { render :edit }
        format.json { render json: @imgdepot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /imgdepots/1
  # DELETE /imgdepots/1.json
  def destroy
    @imgdepot.destroy
    respond_to do |format|
      format.html { redirect_to imgdepots_url, notice: 'Imgdepot was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_imgdepot
      @imgdepot = Imgdepot.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def imgdepot_params
      params.require(:imgdepot).permit(:titile, :summary, :imgfile)
    end

    def load_imgdepot
      @imgdepot = Imgdepot.new(imgdepot_params)
    end
end
