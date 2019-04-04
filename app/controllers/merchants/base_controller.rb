class Merchants::BaseController < ApplicationController
  before_action :require_merchant

  def require_merchant
    render status: 404 unless current_merchant?
  end
end
