// JavaScript version of payment.coffee
// Part of the CoffeeScript to JavaScript migration

// Helper method
const paymentOptions = function(val) {
  let amt = '';
  if (val == null) return;

  let txt;
  switch (val.type) {
    case 'Cash':
      txt = 'Efectivo';
      break;
    case 'Bank':
      txt = 'Banco';
      break;
    case 'StaffAccount':
      txt = 'Personal';
      break;
    case 'Expense':
      txt = 'Egreso';
      amt = ' <span class="muted"> Saldo:</span> <span class="balance">' + _b.ntc(val.amount) + '</span>';
      break;
    case 'Income':
      txt = 'Ingreso';
      amt = ' <span class="muted"> Saldo:</span> <span class="balance">' + _b.ntc(val.amount) + '</span>';
      break;
  }

  return ['<strong class="gray">', txt, "</strong> ", _.escape(val.to_s),
   amt, ' <span class="label bg-black">',
   val.currency, '</span>'].join('');
};

// Assign to Plugin namespace
window.Plugin = window.Plugin || {};
window.Plugin.paymentOptions = paymentOptions;
