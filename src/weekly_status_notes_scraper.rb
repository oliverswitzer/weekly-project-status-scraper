require 'fileutils'
require 'csv'
require 'pry'
require_relative 'google_drive_service'
require_relative 'project_status_parser'

class WeeklyStatusNotesScraper
  attr_accessor :google_drive_service, :project_status_parser

  def initialize(google_drive_service=nil, project_status_parser=nil)
    @google_drive_service = google_drive_service || GoogleDriveService.new
    @project_status_parser = project_status_parser || ProjectStatusParser.new
  end

  def get_projects
    response = google_drive_service.list_files(q: "name contains 'NYC Project Status'")

    puts 'Weekly status notes not found' if response.files.empty?

    google_drive_service.export_file(
      response.files.first.id, 'text/csv', download_dest: get_weekly_status_notes_csv_path
    )
    project_status_parser.parse_from_file(get_weekly_status_notes_csv_path)
  end

  def get_weekly_status_notes_csv_path
    File.expand_path('../../', __FILE__) + '/tmp/weekly_status_notes.csv'
  end
end
