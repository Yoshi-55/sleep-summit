import Chartkick from "chartkick"
import Highcharts from "highcharts"

window.Highcharts = Highcharts

document.addEventListener("turbo:load", () => {
  const chartElements = Array.from(document.querySelectorAll('[id^="sleep-chart"]'));
  chartElements.forEach(chartElement => {
    if (!chartElement.dataset.series) return;

    // 既存チャートをクリア（Turbo再読み込み時の重複防止）
    chartElement.innerHTML = '';

    const seriesData = JSON.parse(chartElement.dataset.series);

    new Chartkick.LineChart(chartElement, seriesData, {
      xtitle: "時間",
      ytitle: "累計活動時間（h）",
      discrete: false,
      library: {
        chart: {
          backgroundColor: "transparent",
          type: "area",
          zoomType: "x",
          scrollablePlotArea: { minWidth: 400, scrollPositionX: 1 },
        },
        accessibility: { enabled: false },
        colors: ["rgb(72, 125, 0)"],
        tooltip: {
          formatter: function() {
            const date = new Date(this.x);
            const m = (date.getMonth() + 1).toString().padStart(2, '0');
            const d = date.getDate().toString().padStart(2, '0');
            const weekdays = ['日', '月', '火', '水', '木', '金', '土'];
            const w = weekdays[date.getDay()];
            const hh = date.getHours().toString().padStart(2, '0');
            const mm = date.getMinutes().toString().padStart(2, '0');
            const value = typeof this.y === 'number' ? this.y.toFixed(2) : this.y;
            return `${m}-${d}（${w}） ${hh}:${mm}<br>累計: ${value}h`;
          }
        },
        plotOptions: {
          area: {
            marker: {
              enabled: true,
              radius: 4.5,
              symbol: "circle",
              states: {
                hover: { radiusPlus: 1.5 }
              }
            },
            lineWidth: 2.5,
            fillOpacity: 0.25,
            threshold: 0,
            negativeFillColor: "rgba(0,0,0,0)"
          }
        },
        xAxis: {
          lineColor: "#cdcdcd",
          tickColor: "#cdcdcd",
          labels: {
            style: { color: "#cdcdcd" },
            formatter: function() {
              const date = new Date(this.value);
              if (isNaN(date)) return '';
              const m = (date.getMonth() + 1).toString().padStart(2, '0');
              const d = date.getDate().toString().padStart(2, '0');
              const weekdays = ['日', '月', '火', '水', '木', '金', '土'];
              const w = weekdays[date.getDay()];
              const hh = date.getHours().toString().padStart(2, '0');
              const mm = date.getMinutes().toString().padStart(2, '0');
              const timeStr = `${hh}:${mm}`;

              // 6時間おきに目盛り
              if (!['00:00', '06:00', '12:00', '18:00'].includes(timeStr)) return '';

              // 00:00 のときだけ日付も表示
              if (timeStr === '00:00') {
                return `${m}/${d}(${w})`;
              } else {
                return timeStr;
              }
            }
          },
          title: { style: { color: "#cdcdcd", fontWeight: "bold" } }
        },
        yAxis: {
          lineColor: "#cdcdcd",
          tickColor: "#cdcdcd",
          labels: { style: { color: "#cdcdcd" } },
          title: { style: { color: "#cdcdcd", fontWeight: "bold" } },
          gridLineColor: "#cdcdcd"
        }
      }
    });
  });
});
