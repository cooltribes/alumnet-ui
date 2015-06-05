class ErrorsController < ApplicationController
  layout "public"
  skip_before_action :setup_gon
  skip_before_action :authenticate!

  def e500
  end

  def e404
  end

end
