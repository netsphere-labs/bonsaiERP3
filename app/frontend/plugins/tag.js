// JavaScript version of tag.coffee
// Part of the CoffeeScript to JavaScript migration

const Tag = {
  getTagsById: function(tag_ids) {
    return _(tag_ids).map(function(id) {
      const tag = bonsai.tags_hash[id.toString()];
      if (tag && tag.bgcolor != null) {
        tag.color = Tag.textColor(tag.bgcolor);
      }
      return tag;
    }).compact().value();
  },
  
  textColor: function(color) {
    try {
      return Plugins.Color.idealTextColor(color);
    } catch (e) {
      return '#ffffff';
    }
  },
  
  getHtml: function(tag) {
    return `<span class="tag tag${tag.id}" style="background: ${tag.bgcolor}; color: ${this.textColor(tag.bgcolor)}">
        ${tag.name}
    </span>`;
  }
};

// Assign to Plugins namespace
window.Plugins = window.Plugins || {};
window.Plugins.Tag = Tag;
