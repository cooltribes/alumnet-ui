// Generated by CoffeeScript 1.6.3
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

this.AlumNet.module('GroupsApp.Posts', function(Posts, AlumNet, Backbone, Marionette, $, _) {
  var _ref, _ref1, _ref2;
  this.AlumNet = AlumNet;
  Posts.CommentView = (function(_super) {
    __extends(CommentView, _super);

    function CommentView() {
      _ref = CommentView.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    CommentView.prototype.template = 'groups/posts/templates/comment';

    CommentView.prototype.className = 'groupPost__comment';

    CommentView.prototype.ui = {
      'likeLink': '.js-vote',
      'likeCounter': '.js-likes-counter'
    };

    CommentView.prototype.events = {
      'click .js-like': 'clickedLike',
      'click .js-unlike': 'clickedUnLike'
    };

    CommentView.prototype.clickedLike = function(e) {
      e.stopPropagation();
      e.preventDefault();
      return this.trigger('comment:like');
    };

    CommentView.prototype.clickedUnLike = function(e) {
      e.stopPropagation();
      e.preventDefault();
      return this.trigger('comment:unlike');
    };

    CommentView.prototype.sumLike = function() {
      var val;
      val = parseInt(this.ui.likeCounter.html()) + 1;
      this.ui.likeCounter.html(val);
      return this.ui.likeLink.removeClass('js-like').addClass('js-unlike').html('unlike');
    };

    CommentView.prototype.remLike = function() {
      var val;
      val = parseInt(this.ui.likeCounter.html()) - 1;
      this.ui.likeCounter.html(val);
      return this.ui.likeLink.removeClass('js-unlike').addClass('js-like').html('like');
    };

    return CommentView;

  })(Marionette.ItemView);
  Posts.PostView = (function(_super) {
    __extends(PostView, _super);

    function PostView() {
      _ref1 = PostView.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    PostView.prototype.template = 'groups/posts/templates/post';

    PostView.prototype.childView = Posts.CommentView;

    PostView.prototype.childViewContainer = '.comments-container';

    PostView.prototype.className = 'post item col-md-6';

    PostView.prototype.ui = {
      'item': '.item',
      'commentInput': '.comment',
      'likeLink': '.js-vote',
      'likeCounter': '.js-likes-counter'
    };

    PostView.prototype.events = {
      'keypress .comment': 'commentSend',
      'click .js-like': 'clickedLike',
      'click .js-unlike': 'clickedUnLike'
    };

    PostView.prototype.commentSend = function(e) {
      var data;
      e.stopPropagation();
      if (e.keyCode === 13) {
        e.preventDefault();
        data = Backbone.Syphon.serialize(this);
        if (data.body !== '') {
          this.trigger('comment:submit', data);
          return this.ui.commentInput.val('');
        }
      }
    };

    PostView.prototype.clickedLike = function(e) {
      e.stopPropagation();
      e.preventDefault();
      return this.trigger('post:like');
    };

    PostView.prototype.clickedUnLike = function(e) {
      e.stopPropagation();
      e.preventDefault();
      return this.trigger('post:unlike');
    };

    PostView.prototype.sumLike = function() {
      var val;
      val = parseInt(this.ui.likeCounter.html()) + 1;
      this.ui.likeCounter.html(val);
      return this.ui.likeLink.removeClass('js-like').addClass('js-unlike').html('unlike');
    };

    PostView.prototype.remLike = function() {
      var val;
      val = parseInt(this.ui.likeCounter.html()) - 1;
      this.ui.likeCounter.html(val);
      return this.ui.likeLink.removeClass('js-unlike').addClass('js-like').html('like');
    };

    PostView.prototype.onBeforeRender = function() {
      this.model.comments.fetch();
      this.collection = this.model.comments;
      this.on('childview:comment:like', function(commentView) {
        return this.trigger('comment:like', commentView);
      });
      return this.on('childview:comment:unlike', function(commentView) {
        return this.trigger('comment:unlike', commentView);
      });
    };

    return PostView;

  })(Marionette.CompositeView);
  return Posts.PostsView = (function(_super) {
    __extends(PostsView, _super);

    function PostsView() {
      _ref2 = PostsView.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    PostsView.prototype.template = 'groups/posts/templates/posts_container';

    PostsView.prototype.childView = Posts.PostView;

    PostsView.prototype.childViewContainer = '.posts-container';

    PostsView.prototype.ui = {
      'bodyInput': '#body',
      'timeline': '#timeline'
    };

    PostsView.prototype.events = {
      'click a#js-post-submit': 'submitClicked'
    };

    PostsView.prototype.submitClicked = function(e) {
      var data;
      e.stopPropagation();
      e.preventDefault();
      data = Backbone.Syphon.serialize(this);
      if (data.body !== '') {
        this.trigger('post:submit', data);
        return this.ui.bodyInput.val('');
      }
    };

    return PostsView;

  })(Marionette.CompositeView);
});
