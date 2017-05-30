require 'fileutils'
require 'csv'
require 'pry'
require_relative 'google_drive_service'
require_relative 'project_status_parser'
require_relative '../helpers/file_path_helper'

class WeeklyStatusNotesScraper
  include FilePathHelper

  attr_accessor :google_drive_service, :project_status_parser

  def initialize(google_drive_service=nil, project_status_parser=nil)
    @google_drive_service = google_drive_service || GoogleDriveService.new
    @project_status_parser = project_status_parser || ProjectStatusParser.new
  end

  def get_projects
    response = google_drive_service.list_files(q: "name contains 'Fixture Project Status'")

    puts 'Weekly status notes not found' if response.files.empty?

    google_drive_service.export_file(
      response.files.first.id, 'text/csv', download_dest: weekly_status_notes_csv_path
    )
    project_status_parser.parse_from_file(weekly_status_notes_csv_path)
  end

end
