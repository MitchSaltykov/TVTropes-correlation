class TropesController < ApplicationController
  def show
    @trope = Trope.find(params[:id])
  end
end