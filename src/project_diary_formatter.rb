
class ProjectDiaryFormatter
  # TODO: Does this have to know about files? Can it just structure an array properly instead if given the current data?
  # TODO: How do I handle new projects changing? Or what if the project name changes? What if the project no longer exists

  def generate_diary(projects)
    CSV.open(File.expand_path('../../tmp', __FILE__) + '/weekly_status_diary.csv', 'a+') do |csv|
      csv << updated_headers(projects, csv.readlines)
      csv << updated_row(projects)
    end
  end

  private

    def updated_headers(projects, current_headers)
      new_headers = projects.map { |project| project[:project_name] }
      new_headers.unshift(nil)
    end

    def updated_row(projects)
      projects.map { |project| "Summary: #{project[:summary]}" }.unshift(DateTime.now.strftime('%m/%d/%Y'))
    end
end
