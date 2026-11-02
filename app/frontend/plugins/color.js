// JavaScript version of color.coffee
// Part of the CoffeeScript to JavaScript migration

const Color = {
  componentToHex: function(c) {
    const hex = c.toString(16);
    return hex.length === 1 ? "0" + hex : hex;
  },
  
  rgbToHex: function(val) {
    const self = this;
    return '#' + _.map(val.split(','), function(v) {
      return self.componentToHex(v.match(/\d+/)[0] * 1);
    }).join('');
  },
  
  // Convert Hex to RGB
  hexToRgb: function(hex) {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    if (result) {
      return {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16)
      };
    } else {
      return null;
    }
  },
  
  // Function to determine ideal text color based on background
  idealTextColor: function(bgColor) {
    const nThreshold = 105;
    const components = this.hexToRgb(bgColor);
    
    if (!components) return "#ffffff";
    
    const bgDelta = (components.r * 0.299) + (components.g * 0.587) + (components.b * 0.114);
    return ((255 - bgDelta) < nThreshold) ? "#000000" : "#ffffff";
  }
};

// Assign to Plugins namespace
window.Plugins = window.Plugins || {};
window.Plugins.Color = Color;
