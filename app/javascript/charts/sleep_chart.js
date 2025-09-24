import Chartkick from "chartkick"
import Highcharts from "highcharts"

window.Highcharts = Highcharts

document.addEventListener("turbo:load", () => {
  const chartElement = document.getElementById("sleep-chart")
  if (!chartElement) return

  const seriesData = JSON.parse(chartElement.dataset.series)

  new Chartkick.LineChart(chartElement, seriesData, {
    xtitle: "時間",
    ytitle: "累計活動時間（h）",
    discrete: false,
    library: {
      chart: { backgroundColor: "transparent", type: "area" },
      plotOptions: {
        area: {
          marker: {
            enabled: true,
            radius: 4,
            symbol: "circle"
          },
          lineWidth: 2,
          fillOpacity: 0.3,
          threshold: -20,
          negativeFillColor: "rgba(0,0,0,0)"
        }
      },
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
      }
    }
  });
});