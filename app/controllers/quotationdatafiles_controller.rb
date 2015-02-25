class QuotationdatafilesController < ApplicationController
	include QuotationdatafilesHelper
	before_filter :authenticate_user!
  before_action :set_quotationdatafile, only: [:show, :edit, :update, :destroy, :download]

  #load_and_authorize_resource

  # GET /quotationdatafiles
  # GET /quotationdatafiles.json
  def index
    @quotationdatafiles = Quotationdatafile.order(created_at: :desc).page(params[:page])
  end

  # GET /quotationdatafiles/1
  # GET /quotationdatafiles/1.json
  def show
  end
  
  def download
    send_file @quotationdatafile.avatar.path,
            :filename => @quotationdatafile.avatar_file_name,
            :type => @quotationdatafile.avatar_content_type,
            :disposition => 'attachment'
  end

  def hqupdate
    #if Time.now.strftime("%y-%m-%d") == sysmarketdate.strftime("%y-%m-%d")
        if config_get(params[:tag], 'batchname') == 'quotation1' and config_get(params[:tag], 'batchstatus') == 0
          ActiveRecord::Base.transaction do
            config_set params[:tag], 'batchstatus', 1

            updateReserves params[:tag]
            updatePortfolios params[:tag]
            doadvise params[:tag]
            updateAccounts params[:tag]

            config_set params[:tag], 'batchname', 'quotation2'
            config_set params[:tag], 'batchstatus', 0 
          end
        end
#				end
    flash[:notice] = "quotation data file inputed and day changed successfully."
    respond_to do |format|
      format.html { redirect_to quotations_path(qtype: 'today') }
    end
  end

  # GET /quotationdatafiles/1/doupdate
  def doupdate 
		@quotationdatafile = Quotationdatafile.find(params[:id])	
    tag = params[:tag]
    tag = session[:tag] if tag.nil?
    tag = @quotationdatafile.tag if tag.nil?

    unless tag.nil?    
      case @quotationdatafile.filetype
      when 'md'
        ActiveRecord::Base.transaction do
          marketdatefileprocess(@quotationdatafile.avatar_file_name, @quotationdatafile.avatar.path)
        end
        flash[:notice] = "market data file input successfully."
        respond_to do |format|
          format.html { redirect_to :marketdates }
        end
      when 'hq'
  #			if Time.now.strftime("%y-%m-%d") == sysmarketdate.strftime("%y-%m-%d")
            if config_get(tag, 'batchname') == 'datechange' and config_get(tag, 'batchstatus') == 0
              ActiveRecord::Base.transaction do
                config_set tag, 'batchstatus', 1

                quotationfileprocess(@quotationdatafile.avatar_file_name, @quotationdatafile.avatar.path)

                config_set tag, 'batchname', 'quotation1'
                config_set tag, 'batchstatus', 0 
              end
            end
  #				end
        flash[:notice] = "quotation data file inputed and day changed successfully."
        respond_to do |format|
          format.html { redirect_to quotations_path(qtype: 'today') }
          #format.html { redirect_to :quotations }
        end
        when 'ods'
  #			if Time.now.strftime("%y-%m-%d") == sysmarketdate.strftime("%y-%m-%d")
              ActiveRecord::Base.transaction do
                odsreservefileprocess(@quotationdatafile.avatar_file_name, @quotationdatafile.avatar.path)
                cleandatatotoday tag
              end
  #				end
        flash[:notice] = "ods reserves data file inputed and day changed successfully."
        respond_to do |format|
          format.html { redirect_to odsreserves_path() }
          #format.html { redirect_to :quotations }
        end
      when 'bxc'
          if current_user.analyst.nil?
            flash[:notice] = "You are not analyst."
          else
  #				if Time.now.strftime("%y-%m-%d") == sysmarketdate.strftime("%y-%m-%d")
            if config_get(tag, 'batchname') == 'quotation2' and config_get(tag, 'batchstatus') == 0
              ActiveRecord::Base.transaction do
                config_set tag, 'batchstatus', 1

                reservefileprocess(@quotationdatafile.avatar_file_name, @quotationdatafile.avatar.path)

                config_set tag, 'batchname', 'reserve'
                config_set tag, 'batchstatus', 0 
              end
            end
  #				end
          flash[:notice] = "reserv data file input successfully."
        end
        respond_to do |format|
          format.html { redirect_to reserves_path(qtype: 'catch') }
        end
      else

      end

    end

	end

  def bxctoodsupdate
		@quotationdatafile = Quotationdatafile.find(params[:id])	
#	    if Time.now.strftime("%y-%m-%d") == sysmarketdate.strftime("%y-%m-%d")
						ActiveRecord::Base.transaction do
							odsreservefileprocess(@quotationdatafile.avatar_file_name, @quotationdatafile.avatar.path)
              cleandatatotoday tag
						end
#				end
		  flash[:notice] = "ods reserves data file inputed and day changed successfully."
			respond_to do |format|
  	 		format.html { redirect_to odsreserves_path() }
  	 		#format.html { redirect_to :quotations }
			end
		
  end

	def dobatch
		
		case params[:battype]
		when 'riqie'
#			job_id =
#      Rufus::Scheduler.singleton.in '5s' do
        Rails.logger.info ">>>>>>>>>>>>>>>time flies, it's now #{Time.now}"

#				if Time.now.strftime("%y-%m-%d") == sysmarketdate.strftime("%y-%m-%d")
					if config_get(params[:tag], 'batchname') == 'reserve' and config_get(params[:tag], 'batchstatus') == 0
						ActiveRecord::Base.transaction do
							config_set params[:tag], 'batchstatus', 1

							doadvise params[:tag] 
              do_duration_update params[:tag]
              do_statistics_update params[:tag]
              #sys_account_advise
              #user_account_advise
              do_riskrate params[:tag]
							marketdatechange params[:tag]
              dataclean params[:tag]

							config_set params[:tag], 'batchname', 'datechange'
							config_set params[:tag], 'batchstatus', 0 
						end
					end
#				end

#      end
		  #flash[:notice] = "doadvise successfully. #{job_id}"
			respond_to do |format|
  	 		format.html { redirect_to :sysconfigs }
			end
		when 'guanzhu'
			ActiveRecord::Base.transaction do
				guanzhu
			end
		  flash[:notice] = "guanzhu successfully."
			respond_to do |format|
  	 		format.html { redirect_to :quotationdatafiles }
			end
		when 'sysadvise'
			ActiveRecord::Base.transaction do
			  sys_account_advise	
			end
		  flash[:notice] = "gensui successfully."
			respond_to do |format|
  	 		format.html { redirect_to :quotationdatafiles }
			end
		when 'gensui'
			ActiveRecord::Base.transaction do
        u = User.find_by(openid: '1')
			 	gensui u, 'wenjian', 'sys'
			end
		  flash[:notice] = "gensui successfully."
			respond_to do |format|
  	 		format.html { redirect_to :quotationdatafiles }
			end
		when 'zhanghu'
			ActiveRecord::Base.transaction do
				createAccount('1','wenjian',5,0.05)	
			end
		  flash[:notice] = "zhanghu successfully."
			respond_to do |format|
  	 		format.html { redirect_to :quotationdatafiles }
			end
		when 'jiangu'
			ActiveRecord::Base.transaction do
        #u = User.find_by(openid: '1')
        #a = u.accounts.find_by(name: 'wenjian')
				jiangu '1','wenjian'	
			end
		  flash[:notice] = "jiangu successfully."
			respond_to do |format|
  	 		format.html { redirect_to :portfolios }
			end
   	when 'opttip'
			ActiveRecord::Base.transaction do
			  accountopttips 'wenjian'	
			end
		  flash[:notice] = "opttip successfully."
			respond_to do |format|
  	 		format.html { redirect_to :quotationdatafiles }
			end
    when 'all'
      flash[:notice] = allportfolios 'A'
			respond_to do |format|
  	 		format.html { redirect_to :reserves }
			end
		when 'shouyi'
			ActiveRecord::Base.transaction do
				shouyi	
			end
		  flash[:notice] = "shouyi successfully."
			respond_to do |format|
  	 		format.html { redirect_to :quotationdatafiles }
			end
    when 'batopt'
			ActiveRecord::Base.transaction do
			  batopt	
			end
		  flash[:notice] = "shouyi successfully."
			respond_to do |format|
  	 		format.html { redirect_to :quotationdatafiles }
			end
		else
		  flash[:notice] = "nothing do ."
			respond_to do |format|
  	 		format.html { redirect_to :quotationdatafiles }
			end

		end  
  end

  # GET /quotationdatafiles/new
  def new
    @quotationdatafile = Quotationdatafile.new
		@quotationdatafile.marketdate = tradedate(params[:tag])

		case params[:battype]
		when 'q'
			@quotationdatafile.filetype = 'hq'
			session[:opttype] = 'quick'
			session[:tag] = params[:tag] 
		when 'b'
			@quotationdatafile.filetype = 'bxc'
			session[:opttype] = 'quick'
			session[:tag] = params[:tag] 
		when 'm'
			@quotationdatafile.filetype = 'md'
			session[:opttype] = 'quick'
			session[:tag] = params[:tag] 
		when 'r'
			@quotationdatafile.filetype = 'rq'
			session[:opttype] = 'quick'
			session[:tag] = params[:tag] 
		when 'o'
			@quotationdatafile.filetype = 'ods'
			session[:opttype] = 'quick'
			session[:tag] = params[:tag] 
		else
		
		end	
  end

  # GET /quotationdatafiles/1/edit
  def edit
  end

  # POST /quotationdatafiles
  # POST /quotationdatafiles.json
  def create
    @quotationdatafile = Quotationdatafile.new(quotationdatafile_params)
		#@quotationdatafile.marketdate = tradedate(params[:tag])

    respond_to do |format|
      if @quotationdatafile.save
        filename = @quotationdatafile.avatar_file_name
        fcols = filename.split("_") 
        tag = fcols[0].strip
        @quotationdatafile.update(tag: tag)

				if session[:opttype] == 'quick'
					format.html {	redirect_to doupdate_quotationdatafile_path(@quotationdatafile) }
				else
        	format.html { redirect_to :quotationdatafiles }
				end
        #format.html { redirect_to @quotationdatafile, notice: 'Quotationdatafile was successfully created.' }
        #format.json { render :show, status: :created, location: @quotationdatafile }
      else
        format.html { render :new }
        format.json { render json: @quotationdatafile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /quotationdatafiles/1
  # PATCH/PUT /quotationdatafiles/1.json
  def update
    respond_to do |format|
      if @quotationdatafile.update(quotationdatafile_params)
        format.html { redirect_to @quotationdatafile, notice: 'Quotationdatafile was successfully updated.' }
        format.json { render :show, status: :ok, location: @quotationdatafile }
      else
        format.html { render :edit }
        format.json { render json: @quotationdatafile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /quotationdatafiles/1
  # DELETE /quotationdatafiles/1.json
  def destroy
    @quotationdatafile.destroy
    respond_to do |format|
      format.html { redirect_to quotationdatafiles_url, notice: 'Quotationdatafile was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
	
	#Paperclip.interpolates :filetype do |attachment, style|
	#	attachment.instance.filetype 
	#end

	#Paperclip.interpolates :marketdate do |attachment, style|
	#	attachment.instance.marketdate
	#end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quotationdatafile
      @quotationdatafile = Quotationdatafile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def quotationdatafile_params
      params.require(:quotationdatafile).permit(:marketdate, :filetype, :filestatus, :avatar)
    end
end
