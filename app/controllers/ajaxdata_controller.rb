class AjaxdataController < ApplicationController
  def account
    @data = Quotation.where(code: '002203').limit(100).select(:close,:marketdate)
    respond_to do |format|
      format.json { render :inline => @data.to_json }
    end
  end

  def quotation 
    @data = Quotation.where(code: '000655').limit(100).select(:open,:close,:high,:low,:volume,:amount,:marketdate)
    respond_to do |format|
      format.json { render :inline => @data.to_json }
    end
  end

end
