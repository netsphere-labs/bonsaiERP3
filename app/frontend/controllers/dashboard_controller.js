
import { Controller } from "@hotwired/stimulus"
//import ApexCharts from 'apexcharts';

/*
  actual values (AC)
  previous year's (PY)
  planned ones (PL)
  
  https://zebrabi.com/template/contribution-margin-analysis-excel-template/
  Contribution Margin Analysis Excel Template

  https://zebrabi.com/template/cost-variance-table-py-ac_and_ac-pl/
  Cost Variance Table in Excel (PY-AC and AC-PL)
 */

// Connects to data-controller="dashboard"
export default class extends Controller {
    // @override
    connect() {
	var options = {
	    series: [{
		    name: 'net profit',
		    data: [150, 150, 150,150,150,150,150,150,150,150,150,150]
		}, {
		    name: 'non-variable costs',
		    data: [128,128,128,128,128,128,128,128,128,128,128,128]
		}, {
		    name: 'previous year', // 2 years ago, ...
		    data: [25, 35, 45, 50, 65, 70,85, 100, 110, 120, 130, 135]
		}, {
		    name: 'current year',
		    data: [30,40,35,50,49,60,70,91,125, 130, 145, 150]
		} ],
	    chart: {
		height: 400,
		type: 'line' },
	    dataLabels: { enabled: true },
	    title: {
		// 限界利益 marginal profit と貢献利益 contribution margin は
		// どちらも使われ、英語では後者が優勢か
		// MQ <= PQ - VQ
		text: 'Cumulative Contribution Margin',
		align: 'left' },
	    xaxis: {
		categories:['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul',
			    'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
		title: { text: 'Month' } }
	}

	var chart = new ApexCharts(document.querySelector("#chart"), options);
	chart.render();
    }
    
}
