# @AlumNet.module 'Utilities', (Utilities, @AlumNet, Backbone, Marionette, $, _) ->


#Animation for regions

# class Utilities.AnimatedRegion extends Backbone.Marionette.Region
# class AnimatedRegion extends Backbone.Marionette.Region

    # attachHtml = (newView) ->
    #   @$el.css({opacity: 0})
    #   @$el.html(newView.el)
    #   @$el.animate({opacity: 1}, 300)
      # @$el.hide();
      # @$el.html(newView.el);
      # @$el.slideDown("fast");





Backbone.Marionette.Region::attachHtml = (newView) ->
  @$el.css({opacity: 0})
  @$el.html(newView.el)
  @$el.animate({opacity: 1}, 300)