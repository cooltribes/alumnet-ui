(function ($) {
  function PhotoTagging (container, options) {
    var self = this;

    this.container = container;

    this.img = this.container.find('img');

    this.posX = null;
    this.posY = null;

    // temp
    this.model = options.model

    this.tags = options.tags;

    this.isActiveCreation = options.isActiveCreation;

    this.addCallback = options.addCallback;

    this.submitCallback = options.submitCallback;

    this.inputCallback = options.inputCallback;

    //Here is first appear of tagger, then here call the inputCallback to added a plugin to input.
    this.container.append(this.tagger);

    if(this.inputCallback){
      this.inputCallback('#tag-name');
    }

    this.loadTags();

    this.img.click(
      function(e){
        if(self.isActiveCreation){
          //Determine area within element that mouse was clicked
          mouseX = e.pageX - self.container.offset().left;
          mouseY = e.pageY - self.container.offset().top;

          //Get height and width of #tag-target
          targetWidth = $("#tag-target").outerWidth();
          targetHeight = $("#tag-target").outerHeight();

          //Determine position for #tag-target
          targetX = mouseX-targetWidth/2;
          targetY = mouseY-targetHeight/2;

          //Determine position for #tag-input
          inputX = mouseX+targetWidth/2;
          inputY = mouseY-targetHeight/2;

          //Animate if second click, else position and fade in for first click
          if($("#tag-target").css("display")=="block")
          {
            $("#tag-target").animate({left: targetX, top: targetY}, 500);
            $("#tag-input").animate({left: inputX, top: inputY}, 500);
          } else {
            $("#tag-target").css({left: targetX, top: targetY}).fadeIn();
            $("#tag-input").css({left: inputX, top: inputY}).fadeIn();
          }
          $("#tag-name").focus();
          self.posX = targetX;
          self.posY = targetY;
        }
      }
    );

    $('a#tag-submit').click(
      function(e){
        e.preventDefault();
        // here the function to send the data to server, here find the way to get
        // the name and id of user. Here use a select2 plugin.
        user_id = $('#tag-name').val();
        user_name = $('#tag-name').val();
        if(user_name == "" || user_id == ""){ return; }
        self.submitCallback(self, user_id, user_name, self.posX, self.posY)
      }
    );

    $('a#tag-cancel').click(
      function(e){
        e.preventDefault();
        self.hideTagger();
      }
    );

  }

  PhotoTagging.prototype = {
    tagger: function(){
      return '<div id="tag-target"></div><div id="tag-input"><input type="hidden" id="tag-name" style="width:100%;"><a href="#" id="tag-submit" class="btn btn-sm btn-default">Submit</a><a href="#" id="tag-cancel" class="btn btn-sm btn-default">Cancel</a></div>'
    },

    hideTagger: function(){
      $("#tag-target").fadeOut();
      $("#tag-input").fadeOut();
      // $("#tag-name").val("");
      $("#tag-name").select2('val',"");
      this.posY = null;
      this.posX = null;
    },

    addTag: function(id, user_id, user_name, posX, posY){
      this.container.append('<div id="hotspot-' + id + '" class="hotspot" style="left:' + posX + 'px; top:' + posY + 'px;"><span>' + user_name + '</span></div>');
      this.hideTagger();
      if(this.addCallback){
        this.addCallback(id, user_id, user_name, posX, posY)
      }
    },

    removeTag: function(id){
      this.container.find("div#hotspot-" + id).remove();
    },

    showTag: function(id){
      this.container.find("div#hotspot-" + id).addClass("hotspothover");
    },

    hideTag: function(id){
      this.container.find("div#hotspot-" + id).removeClass("hotspothover");
    },

    loadTags: function(){
      self = this;
      $.each(this.tags, function(index, tagData){
        self.addTag(tagData.id, tagData.user_id, tagData.user_name, tagData.posX, tagData.posY);
      });
    },

    activeTagger: function(){
      this.isActiveCreation = true;
      this.img.css({ cursor: "crosshair" });
      $('#tag-target').css({ cursor: "crosshair" });
    },

    inactiveTagger: function(){
      this.isActiveCreation = false;
      this.img.css({ cursor: "auto" });
      $('#tag-target').css({ cursor: "auto" });
      this.hideTagger();
    }

  }

  $.fn.photo_tagging = function (options) {
    // merge options with default options
    var settings = $.extend({}, $.fn.photo_tagging.defaultOptions, options);

    // create a instance of PhotoTaggin - this is the core of plugin
    var photoTagging = new PhotoTagging(this, settings);

    // add the instance to element
    this.data('photoTagging', photoTagging);

    return photoTagging;
  }

  $.fn.photo_tagging.defaultOptions = {
    // Initial Tags
    tags: [],

    //This is a backbone model. This is a temp solution for get the url in submitCallback
    model: false,

    // Active creation of tag
    isActiveCreation: false,

    // this is function(id, text, posX, posY) is trigger when a tag is added
    addCallback: false,

    // this is function(input_id) is for added a plugin to input in tagger
    inputCallback: false,

    // this function(plugin, user_id, user_name, posX, posY) where plugin is used to addTag with a generate id .
    submitCallback: function(plugin, user_id, user_name, posX, posY){
      id = new Date().getTime();
      plugin.addTag(id, user_id, user_name, posX, posY);
    }
  }
}(jQuery));
