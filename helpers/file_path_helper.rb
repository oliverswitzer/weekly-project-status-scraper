module FilePathHelper
  def weekly_status_notes_csv_path
    File.expand_path('../../tmp', __FILE__) + '/weekly_status_notes.csv'
  end

  def weekly_status_diary_path
    File.expand_path('../../tmp', __FILE__) + '/weekly_status_diary.csv'
  end
end
