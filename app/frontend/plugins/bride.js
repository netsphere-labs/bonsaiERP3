// JavaScript version of bride.coffee
// Plugin to create tours similar to jquery.joyride

class Bride {
  constructor(listSel) {
    this.listSel = listSel;
    this.nubPos = 'top';
    this.defaults = {
      tipLocation: 'top',
      tipWidth: 300
    };
    
    $('.joyride-close-tip').trigger('click');
    this.$list = $(this.listSel);
    this.pos = 0;
    this.$items = this.$list.find('li');
    this.setTip();
    this.setEvents();
  }
  
  setTip() {
    this.$tip = $(template)
      .css({position: 'absolute', display: 'block', visibility: 'hidden'})
      .appendTo('body');
  }
  
  init(options) {
    this.showPos(0);
  }
  
  showPos(pos) {
    if (this.$items[pos]) {
      this.setStepCssClass(pos);
      this.$current = $(this.$items[pos]);
      this.pos = pos + 1;
      this.show();
    } else {
      this.hide();
    }
  }
  
  setStepCssClass(pos) {
    if (pos === 0) {
      this.$tip.addClass('first-step');
    } else if (this.$items.length === (pos - 1)) {
      this.$tip.addClass('last-step');
    } else {
      this.$tip.removeClass('first-step').removeClass('last-step');
    }
  }
  
  hide() {
    this.$tip.css({visibility: 'hidden'});
  }
  
  show() {
    const tipLocation = this.$current.data('tipLocation') || this.defaults.tipLocation;
    const name = this.$current.data('name') || `${this.listSel}-${this.pos}`;
    
    this.$tip.css({visibility: 'visible', top: '100px'})
      .data({pos: this.pos})
      .attr({'data-name': name})
      .find('#content')
      .html(this.$current.html());

    this.$tip.find('.joyride-nub')
      .attr('class', '')
      .addClass(`joyride-nub ${tipLocation}`);
      
    this.$tip.find('.next').text(this.$current.data('text'));

    this.setPosition();
  }
  
  setPosition() {
    const $el = $(this.$current.data('sel'));
    const options = _.merge({}, this.$current.data('options') || {});
    const position = $el.position();
    const w = $el.width();
    const h = $el.height();
    const x = options.x || this.getX(position.left, w);
    const y = options.y || this.getY(position.top, h);
    
    this.$tip.css({top: y, left: x});
  }
  
  getX(x, w) {
    if (this.$tip.find('.joyride-nub').hasClass('left')) {
      return x + w + 30;
    } else if (this.$tip.find('.joyride-nub').hasClass('right')) {
      return x - 300 - 30;
    } else {
      return x + 10;
    }
  }
  
  getY(y, h) {
    const th = this.$tip.height();
    const speed = 400;

    if (this.$tip.find('.joyride-nub').hasClass('top')) {
      $('body').scrollTo(y, speed);
      return y + h + 30;
    } else if (this.$tip.find('.joyride-nub').hasClass('bottom')) {
      $('body').scrollTo(y - h - th - 30, speed);
      return y - th - 20;
    } else {
      $('body').scrollTo(y - 20, speed);
      return y - 20;
    }
  }
  
  setEvents() {
    const self = this;
    
    this.$tip.on('click', '.next', function() {
      self.showPos(self.$tip.data('pos'));
    });

    this.$tip.on('click', '.prev', function() {
      self.showPos(self.$tip.data('pos') - 2);
    });

    this.$tip.on('click', '.joyride-close-tip', function() {
      self.hide();
    });
  }
  
  getElementPosition(el) {
    // This method was empty in the original
  }
}

// Assign to Plugins namespace
window.Plugins = window.Plugins || {};
window.Plugins.Bride = Bride;

// HTML template for the tour tip
const template = `
<div class="joyride-tip-guide" data-index="0" style="visibility: visible; display: block; top: 50px; left: 50px;">
  <span class="joyride-nub"></span>
  <div class="joyride-content-wrapper" role="dialog">
    <div id="content"></div>
    <a href="javascript:;" class="joyride-next-tip prev">Anterior</a>
    <a href="javascript:;" class="joyride-next-tip next"></a>
    <a href="javascript:;" class="joyride-close-tip">X</a>
  </div>
</div>
`;
