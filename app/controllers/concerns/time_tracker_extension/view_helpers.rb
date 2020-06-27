module TimeTrackerExtension::ViewHelpers
  extend ActiveSupport::Concern

  def render_json_partial(view_path, locals = {})
    render partial: "time_tracker_extension#{view_path}", locals: locals
  end

end
