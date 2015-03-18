class PagesController < ApplicationController
  layout "public"
  skip_before_action :setup_gon
  skip_before_action :authenticate!

  def about
  end

  def contact
  end

  def donate
  end

  def join
  end

  def privacy
  end

  def terms
  end

end
