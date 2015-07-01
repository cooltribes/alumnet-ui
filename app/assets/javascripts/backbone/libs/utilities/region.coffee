# Animation for regions and showing views
# ---
# Overriding "attachHtml" Method of Marionette Regions

# NRamirez


Backbone.Marionette.Region::attachHtml = (newView) ->
  @$el.css({opacity: 0})
  @$el.html(newView.el)
  @$el.animate({opacity: 1}, 300)



#Refactor this for future use
# @AlumNet.module 'Utilities', (Utilities, @AlumNet, Backbone, Marionette, $, _) ->
# class Utilities.AnimatedRegion extends Backbone.Marionette.Region
# class AnimatedRegion extends Backbone.Marionette.Region

    # attachHtml = (newView) ->
    #   @$el.css({opacity: 0})
    #   @$el.html(newView.el)
    #   @$el.animate({opacity: 1}, 300)
      # @$el.hide();
      # @$el.html(newView.el);
      # @$el.slideDown("fast");
