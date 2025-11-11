module ApplicationHelper
  def default_meta_tags
    {
      site: "Sleep Summit",
      title: "Sleep Monitoring & Scheduling",
      reverse: true,
      charset: "utf-8",
      description: "\tSleep Summitは、睡眠記録およびスケジュール管理アプリです。Googleカレンダーと連携し、睡眠データの分析と視覚化を提供します。健康的な睡眠習慣をサポートし、より良い生活を実現します。",
      keywords: "睡眠, スリープ, サミット, 睡眠記録, 睡眠スケジュール, 健康管理, 睡眠改善, 睡眠分析, 睡眠トラッキング",
      canonical: request.original_url,
      separator: "|",
      og: {
        site_name: :site,
        title: :title,
        description: :description,
        type: "website",
        url: request.original_url,
        image: image_url("ogp.png"),
        local: "ja-JP"
      },
      twitter: {
        card: "summary_large_image",
        site: "@SleepSummitApp",
        image: image_url("ogp.png")
      }
    }
  end
end
