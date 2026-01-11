import Chartkick from "chartkick";
import Highcharts from "highcharts";

window.Highcharts = Highcharts;

const CHART_CONFIG = {
  colors: {
    primary: "rgb(72, 125, 0)",
    axis: "#cdcdcd",
  },
  marker: {
    radius: 4.5,
    hoverRadiusPlus: 1.5,
  },
  line: {
    width: 2.5,
    fillOpacity: 0.25,
  },
  tickIntervals: ["00:00", "06:00", "12:00", "18:00"],
};

const WEEKDAYS = ["日", "月", "火", "水", "木", "金", "土"];

const formatDate = (timestamp) => {
  const date = new Date(timestamp);
  if (isNaN(date)) return { m: "", d: "", w: "", hh: "", mm: "" };

  return {
    m: (date.getMonth() + 1).toString().padStart(2, "0"),
    d: date.getDate().toString().padStart(2, "0"),
    w: WEEKDAYS[date.getDay()],
    hh: date.getHours().toString().padStart(2, "0"),
    mm: date.getMinutes().toString().padStart(2, "0"),
  };
};

const createTooltipFormatter = () => {
  return function () {
    const { m, d, w, hh, mm } = formatDate(this.x);
    const value = typeof this.y === "number" ? this.y.toFixed(2) : this.y;
    return `${m}-${d}（${w}） ${hh}:${mm}<br>累計: ${value}h`;
  };
};

const createAxisLabelFormatter = () => {
  return function () {
    const { m, d, w, hh, mm } = formatDate(this.value);
    if (!m) return "";

    const timeStr = `${hh}:${mm}`;
    if (!CHART_CONFIG.tickIntervals.includes(timeStr)) return "";

    return timeStr === "00:00" ? `${m}/${d}(${w})` : timeStr;
  };
};

const getChartOptions = () => ({
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
    colors: [CHART_CONFIG.colors.primary],
    tooltip: { formatter: createTooltipFormatter() },
    plotOptions: {
      area: {
        marker: {
          enabled: true,
          radius: CHART_CONFIG.marker.radius,
          symbol: "circle",
          states: {
            hover: { radiusPlus: CHART_CONFIG.marker.hoverRadiusPlus },
          },
        },
        lineWidth: CHART_CONFIG.line.width,
        fillOpacity: CHART_CONFIG.line.fillOpacity,
        threshold: 0,
        negativeFillColor: "rgba(0,0,0,0)",
      },
    },
    xAxis: {
      lineColor: CHART_CONFIG.colors.axis,
      tickColor: CHART_CONFIG.colors.axis,
      labels: {
        style: { color: CHART_CONFIG.colors.axis },
        formatter: createAxisLabelFormatter(),
      },
      title: { style: { color: CHART_CONFIG.colors.axis, fontWeight: "bold" } },
    },
    yAxis: {
      lineColor: CHART_CONFIG.colors.axis,
      tickColor: CHART_CONFIG.colors.axis,
      labels: { style: { color: CHART_CONFIG.colors.axis } },
      title: { style: { color: CHART_CONFIG.colors.axis, fontWeight: "bold" } },
      gridLineColor: CHART_CONFIG.colors.axis,
    },
  },
});

document.addEventListener("turbo:load", () => {
  const chartElements = Array.from(
    document.querySelectorAll('[id^="sleep-chart"]')
  );

  chartElements.forEach((chartElement) => {
    if (!chartElement.dataset.series) return;

    chartElement.innerHTML = "";

    const seriesData = JSON.parse(chartElement.dataset.series);
    new Chartkick.LineChart(chartElement, seriesData, getChartOptions());
  });
});
