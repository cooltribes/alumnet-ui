// Animation for regions and showing views
// ---
// This is a kind of simple "plugin" for animate the views while showing them in the entire application
// Use:
//  Use the method ".showAnimated(view)" instead of ".html()"" jQuery function,
//    by doing this, the html of param "view" will be added but with a little animation

// # Nelson Ramirez


(function( $ ) {
      
    $.fn.showAnimated = function(view) {
        this.css({opacity: 0});
        this.html(view);
        this.animate({opacity: 1}, 300);
 
        return this;
 
    };
 
}( jQuery ));
