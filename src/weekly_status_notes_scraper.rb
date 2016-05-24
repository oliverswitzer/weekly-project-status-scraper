require 'fileutils'
require 'csv'
require_relative 'google_drive_service'

class WeeklyStatusNotesScraper
  attr_accessor :google_drive_service

  def initialize(google_drive_service)
    @google_drive_service = google_drive_service || GoogleDriveService.new
    # @project_status_parser = project_status_parser || ProjectStatusParser.new
  end

  def get_projects
    projects = []

    response = google_drive_service.list_files(page_size: 1000, fields: 'nextPageToken, files')
    puts 'No files found' if response.files.empty?

    response.files.each do |file|
      next unless file.name == 'NYC Project Status'

      File.delete('../tmp/this_is_a_test.csv') if File.exist?('../tmp/this_is_a_test.csv')

      google_drive_service.export_file(file.id, 'text/csv', download_dest: '../tmp/this_is_a_test.csv')

      rows = CSV.read('../tmp/this_is_a_test.csv', :row_sep => "\r\n")

      rows.each_with_index do |row, i|
        next if i == 0 || row[0].nil?

        projects.push({
          project_name: row[0],
          next_milestone: row[4],
          summary: row[9]
        })
      end
    end

    return projects
  end
end
