import Chartkick from "chartkick"
import Highcharts from "highcharts"

window.Highcharts = Highcharts

document.addEventListener("turbo:load", () => {
  const chartElement = document.getElementById("sleep-chart")
  if (!chartElement) return

  const seriesData = JSON.parse(chartElement.dataset.series)

  new Chartkick.LineChart(chartElement, seriesData, {
    xtitle: "時間",
    ytitle: "累積時間（h）",
    discrete: false,
    library: {
      chart: { backgroundColor: "transparent" },
      xAxis: {
        lineColor: "#ffffff",
        tickColor: "#ffffff",
        labels: { style: { color: "#ffffff" } },
        title: { style: { color: "#ffffff", fontWeight: "bold" } }
      },
      yAxis: {
        lineColor: "#ffffff",
        tickColor: "#ffffff",
        labels: { style: { color: "#ffffff" } },
        title: { style: { color: "#ffffff", fontWeight: "bold" } },
        gridLineColor: "#ffffff"
      },
      plotOptions: {
        series: {
          color: "#1E90FF",
          connectNulls: true,
          marker: { radius: 4, symbol: 'circle' }
        }
      }
    }
  });
});