require 'pry'

require_relative 'weekly_status_notes_scraper'
require_relative 'project_diary_formatter'
require_relative '../helpers/file_path_helper'

require 'google/apis/drive_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'


class Application
  include FilePathHelper

  attr_accessor :weekly_status_notes_scraper, :project_diary_formatter, :google_drive_service

  def initialize(weekly_status_notes_scraper=nil, project_diary_formatter=nil, google_drive_service=nil)
    @weekly_status_notes_scraper = weekly_status_notes_scraper ||  WeeklyStatusNotesScraper.new
    @project_diary_formatter = project_diary_formatter || ProjectDiaryFormatter.new
    @google_drive_service = google_drive_service || GoogleDriveService.new
  end

  def execute
    project_diary_formatter.generate_diary(get_projects)

    response = google_drive_service.list_files(q: "name contains 'NYC Project Status Diary'")

    file = response.files.first

    google_drive_service.update_file(file.id, upload_source: weekly_status_diary_path)
  end

  private

    def get_projects
      weekly_status_notes_scraper.get_projects
    end
end

app = Application.new
app.execute
