// JavaScript version of graph_report.coffee
// Part of the CoffeeScript to JavaScript migration

class GraphReport {
  constructor(sel, incomes, expenses) {
    this.sel = sel;
    this.incomes = incomes;
    this.expenses = expenses;
    this.incColor = '#77b92d';
    this.expColor = '#db0000';
    this.data = {};
    this.prevX = false;
    this.prevY = false;
    this.options = {
      series: {
        lines: {show: true},
        points: {show: true}
      },
      grid: {
        hoverable: true,
        tickColor: '#F5F5F5'
      },
      legend: {
        show: false
      },
      xaxis: {
        mode: 'time',
        timeformat: '%m/%d'
      }
    };
    
    this.createGraph();
    this.createTooltip();
  }
  
  // Parses data and creates graph
  createGraph() {
    $.plot(this.sel,
      [
        {label: 'Ingresos', data: this.parseData(this.incomes), color: this.incColor},
        {label: 'Expenses', data: this.parseData(this.expenses), color: this.expColor}
      ],
      this.options
    );
  }
  
  createTooltip() {
    this.tipID = 'tooltip-' + new Date().getTime();
    this.$tooltip = $(`<span id='${this.tipID}'></span>`)
      .css({
        position: 'absolute', 
        border: '1px solid gray', 
        background: 'rgba(0,0,0, 0.8)', 
        fontSize: '13px',
        top: '100px', 
        left: '10px', 
        color: '#FFF', 
        padding: '4px 8px', 
        zIndex: 10000, 
        borderRadius: '3px'
      })
      .hide()
      .prependTo('body');

    this.setTooltipEvent();
  }
  
  setTooltipEvent() {
    const self = this;
    $('body').on('plothover', this.sel, function(event, pos, item) {
      if(item) {
        if (self.prevX !== item.pageX || self.prevY !== item.pageY) {
          const date = $.datepicker.formatDate(bonsai.dateFormat, new Date(item.datapoint[0]));

          self.$tooltip.css({
            left: (item.pageX - 30) + 'px', 
            top: (item.pageY - 40) + 'px'
          })
          .html('<i>' + date + '</i>: ' + _b.ntc(item.datapoint[1]) + ' ' + bonsai.currency);
          
          self.prevX = item.pageX;
          self.prevY = item.pageY;
        }

        self.$tooltip.show();
      } else {
        self.$tooltip.hide();
      }
    });
  }
  
  parseData(data) {
    return _.map(data, function(v) {
      const d = v.date.split('-');
      d[1] = d[1] * 1 - 1;
      const t = new Date(d[0], d[1], d[2]).getTime();
      return [t, v.tot * 1];
    });
  }
}

// Assign to App namespace
window.App = window.App || {};
window.App.GraphReport = GraphReport;
