// Generated by CoffeeScript 1.6.3
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

this.AlumNet.module('Entities', function(Entities, AlumNet, Backbone, Marionette, $, _) {
  var API, initializeMenu, _ref, _ref1;
  this.AlumNet = AlumNet;
  Entities.MenuItem = (function(_super) {
    __extends(MenuItem, _super);

    function MenuItem() {
      _ref = MenuItem.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    return MenuItem;

  })(Backbone.Model);
  Entities.MenuItemCollection = (function(_super) {
    __extends(MenuItemCollection, _super);

    function MenuItemCollection() {
      _ref1 = MenuItemCollection.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    MenuItemCollection.prototype.model = Entities.MenuItem;

    return MenuItemCollection;

  })(Backbone.Collection);
  initializeMenu = function() {
    return Entities.items = new Entities.MenuItemCollection([
      {
        caption: "Groups",
        "iconClass": "icon-entypo-share"
      }, {
        caption: "Events",
        "iconClass": "ico-calendar"
      }, {
        caption: "Programs",
        "iconClass": "ico-give-help"
      }
    ]);
  };
  API = {
    getMenuItems: function() {
      if (Entities.items === void 0) {
        initializeMenu();
      }
      return Entities.items;
    }
  };
  return AlumNet.reqres.setHandler('menu:items', function() {
    return API.getMenuItems();
  });
});
