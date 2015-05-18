# Animation for regions and showing views
# ---
# This is a kind of simple "plugin" for animate the views while showing them in the entire application
# Use:
#  Use the method ".showAnimated(view)" instead of .html() jQuery function

# Nelson Ramirez





# (function( $ ) {
 
#     $.fn.showAnimated = function(view) {
 
#         this.css({opacity: 0})
#         this.html(view.el)
#         this.animate({opacity: 1}, 300)
 
#         return this;
 
#     };
 
# }( jQuery ));
Backbone.Marionette.Region::attachHtml = (newView) ->
  @$el.css({opacity: 0})
  @$el.html(newView.el)
  @$el.animate({opacity: 1}, 300)

# (( $ )->
#   console.log "declaring"
#   $.fn.showAnimated = (view) ->

#     this.css({opacity: 0})
#     this.html(view.el)
#     this.animate({opacity: 1}, 300)

#     this;

  
 
# ( jQuery ))











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
