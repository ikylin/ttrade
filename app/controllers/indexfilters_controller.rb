class IndexfiltersController < ApplicationController
	before_filter :authenticate_user!
  before_action :set_indexfilter, only: [:show, :edit, :update, :destroy]

  before_action :load_indexfilter, only: [:create]
  load_and_authorize_resource

  # GET /indexfilters
  # GET /indexfilters.json
  def index
    @indexfilters = Indexfilter.all
  end

  # GET /indexfilters/1
  # GET /indexfilters/1.json
  def show
  end

  # GET /indexfilters/new
  def new
    @indexfilter = Indexfilter.new
  end

  # GET /indexfilters/1/edit
  def edit
  end

  # POST /indexfilters
  # POST /indexfilters.json
  def create
    @indexfilter = Indexfilter.new(indexfilter_params)

    respond_to do |format|
      if @indexfilter.save
        format.html { redirect_to @indexfilter, notice: 'Indexfilter was successfully created.' }
        format.json { render :show, status: :created, location: @indexfilter }
      else
        format.html { render :new }
        format.json { render json: @indexfilter.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /indexfilters/1
  # PATCH/PUT /indexfilters/1.json
  def update
    respond_to do |format|
      if @indexfilter.update(indexfilter_params)
        format.html { redirect_to @indexfilter, notice: 'Indexfilter was successfully updated.' }
        format.json { render :show, status: :ok, location: @indexfilter }
      else
        format.html { render :edit }
        format.json { render json: @indexfilter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /indexfilters/1
  # DELETE /indexfilters/1.json
  def destroy
    @indexfilter.destroy
    respond_to do |format|
      format.html { redirect_to indexfilters_url, notice: 'Indexfilter was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_indexfilter
      @indexfilter = Indexfilter.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def indexfilter_params
      params.require(:indexfilter).permit(:name, :script, :platform, :samplecount, :wincount, :losscount, :marketdatecount)
    end

    def load_indexfilter
      @indexfilter = Indexfilter.new(indexfilter_params)
    end
end
