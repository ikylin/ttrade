class WelcomeController < ApplicationController
  def index
    respond_to do |format| 
      format.html { render :index, layout: 'home' } 
    end
  end
end
