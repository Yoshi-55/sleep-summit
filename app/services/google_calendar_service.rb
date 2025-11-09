class GoogleCalendarService
  def initialize(user)
    @user = user
    @auth_service = GoogleAuthService.new(user)
  end

  def fetch_today_events
    return [] unless @user.google_authenticated?

    begin
      calendar = @auth_service.calendar_client

      calendar_list = fetch_calendar_list

      time_min = Time.zone.now.beginning_of_day.iso8601
      time_max = Time.zone.now.end_of_day.iso8601

      all_events = []

      calendar_list.each do |cal|
        next unless cal.selected

        result = calendar.list_events(
          cal.id,
          max_results: 50,
          single_events: true,
          order_by: 'startTime',
          time_min: time_min,
          time_max: time_max
        )

        if result.items.present?
          result.items.each do |event|
            # カレンダー情報も追加
            event.define_singleton_method(:calendar_summary) { cal.summary }
            event.define_singleton_method(:calendar_color) { cal.background_color }
            event.define_singleton_method(:calendar_id) { cal.id }
            event.define_singleton_method(:is_primary?) { cal.primary == true }
            all_events << event
          end
        end
      end

      all_events.sort_by do |event|
        event.start&.date_time || event.start&.date || Time.zone.now
      end
    rescue Google::Apis::AuthorizationError => e
      Rails.logger.error "Google Calendar API authorization error: #{e.message}"
      @auth_service.refresh_token!
      retry
    rescue Google::Apis::Error => e
      Rails.logger.error "Google Calendar API error: #{e.message}"
      []
    end
  end

  def fetch_month_events(date)
    return [] unless @user.google_authenticated?

    begin
      calendar = @auth_service.calendar_client
      calendar_list = fetch_calendar_list

      time_min = date.beginning_of_month.beginning_of_day.iso8601
      time_max = date.end_of_month.end_of_day.iso8601

      all_events = []

      calendar_list.each do |cal|
        next unless cal.selected

        result = calendar.list_events(
          cal.id,
          max_results: 250,
          single_events: true,
          order_by: 'startTime',
          time_min: time_min,
          time_max: time_max
        )

        if result.items.present?
          result.items.each do |event|
            event.define_singleton_method(:calendar_summary) { cal.summary }
            event.define_singleton_method(:calendar_color) { cal.background_color }
            event.define_singleton_method(:calendar_id) { cal.id }
            event.define_singleton_method(:is_primary?) { cal.primary == true }
            all_events << event
          end
        end
      end

      all_events
    rescue Google::Apis::AuthorizationError => e
      Rails.logger.error "Google Calendar API authorization error: #{e.message}"
      @auth_service.refresh_token!
      retry
    rescue Google::Apis::Error => e
      Rails.logger.error "Google Calendar API error: #{e.message}"
      []
    end
  end

  def fetch_calendar_list
    return [] unless @user.google_authenticated?

    begin
      calendar = @auth_service.calendar_client
      result = calendar.list_calendar_lists(
        min_access_role: 'reader'
      )

      result.items || []
    rescue Google::Apis::AuthorizationError => e
      Rails.logger.error "Google Calendar API authorization error: #{e.message}"
      @auth_service.refresh_token!
      retry
    rescue Google::Apis::Error => e
      Rails.logger.error "Google Calendar API error: #{e.message}"
      []
    end
  end

  def primary_calendar_id
    return nil unless @user.google_authenticated?

    begin
      calendar_list = fetch_calendar_list
      primary = calendar_list.find { |cal| cal.primary }
      primary&.id || 'primary'
    rescue => e
      Rails.logger.error "Error getting primary calendar: #{e.message}"
      'primary'
    end
  end

  def create_event(summary:, start_time:, end_time:, description: nil, location: nil)
    return false unless @user.google_authenticated?

    begin
      calendar = @auth_service.calendar_client

      event = Google::Apis::CalendarV3::Event.new(
        summary: summary,
        description: description,
        location: location,
        start: Google::Apis::CalendarV3::EventDateTime.new(
          date_time: start_time.iso8601,
          time_zone: 'Asia/Tokyo'
        ),
        end: Google::Apis::CalendarV3::EventDateTime.new(
          date_time: end_time.iso8601,
          time_zone: 'Asia/Tokyo'
        )
      )

      calendar.insert_event(primary_calendar_id, event)
      true
    rescue Google::Apis::AuthorizationError => e
      Rails.logger.error "Google Calendar API authorization error: #{e.message}"
      @auth_service.refresh_token!
      retry
    rescue Google::Apis::Error => e
      Rails.logger.error "Google Calendar API error: #{e.message}"
      false
    end
  end

  def update_event(event_id:, summary:, start_time:, end_time:, description: nil, location: nil)
    return false unless @user.google_authenticated?

    begin
      calendar = @auth_service.calendar_client

      event = Google::Apis::CalendarV3::Event.new(
        summary: summary,
        description: description,
        location: location,
        start: Google::Apis::CalendarV3::EventDateTime.new(
          date_time: start_time.iso8601,
          time_zone: 'Asia/Tokyo'
        ),
        end: Google::Apis::CalendarV3::EventDateTime.new(
          date_time: end_time.iso8601,
          time_zone: 'Asia/Tokyo'
        )
      )

      calendar.update_event(primary_calendar_id, event_id, event)
      true
    rescue Google::Apis::AuthorizationError => e
      Rails.logger.error "Google Calendar API authorization error: #{e.message}"
      @auth_service.refresh_token!
      retry
    rescue Google::Apis::Error => e
      Rails.logger.error "Google Calendar API error: #{e.message}"
      false
    end
  end

  def delete_event(event_id)
    return false unless @user.google_authenticated?

    begin
      calendar = @auth_service.calendar_client
      calendar.delete_event(primary_calendar_id, event_id)
      true
    rescue Google::Apis::AuthorizationError => e
      Rails.logger.error "Google Calendar API authorization error: #{e.message}"
      @auth_service.refresh_token!
      retry
    rescue Google::Apis::Error => e
      Rails.logger.error "Google Calendar API error: #{e.message}"
      false
    end
  end

  def fetch_event(event_id)
    return nil unless @user.google_authenticated?

    begin
      calendar = @auth_service.calendar_client
      calendar.get_event(primary_calendar_id, event_id)
    rescue Google::Apis::AuthorizationError => e
      Rails.logger.error "Google Calendar API authorization error: #{e.message}"
      @auth_service.refresh_token!
      retry
    rescue Google::Apis::Error => e
      Rails.logger.error "Google Calendar API error: #{e.message}"
      nil
    end
  end
end
