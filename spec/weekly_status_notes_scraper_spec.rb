require 'rspec'
require 'rspec/mocks'

require_relative '../src/weekly_status_notes_scraper'
require_relative '../src/google_drive_service'
require_relative '../src/project_status_parser'
require_relative '../helpers/file_path_helper'

class FileListFake < Struct.new(:files)
end

class FileFake < Struct.new(:id, :name)
end

describe WeeklyStatusNotesScraper do
  include FilePathHelper

  let(:google_drive_service) { instance_double(GoogleDriveService) }
  let(:project_status_parser) { instance_double(ProjectStatusParser)}

  let(:subject) do
    WeeklyStatusNotesScraper.new(google_drive_service, project_status_parser)
  end

  let(:file_fake) { FileFake.new(456, 'NYC Project Status') }
  let(:file_list_fake) {
    FileListFake.new([file_fake])
  }

  before do
    allow(google_drive_service).to receive(:list_files).and_return(file_list_fake)
    allow(google_drive_service).to receive(:export_file)
    allow(project_status_parser).to receive(:parse_from_file)

    allow(File).to receive(:exist?).and_return(false)
  end

  describe 'fetching files' do
    it 'gets a list of files from the drive service with correct query parameters' do
      expect(google_drive_service).to receive(:list_files).with(q:"name contains 'NYC Project Status'")
      subject.get_projects
    end
  end

  describe 'exporting the Project Status file' do
    context 'when file does not exist or has been deleted' do
      it 'exports the NYC Project Status file to a CSV file' do
        expect(google_drive_service).to receive(:export_file).with(
          456, 'text/csv', download_dest: weekly_status_notes_csv_path)

        subject.get_projects
      end
    end
  end

  describe 'parsing NYC Project Status file' do
    before do
      File.delete(weekly_status_notes_csv_path) if File.exist? weekly_status_notes_csv_path

      allow(project_status_parser).to receive(:parse_from_file).with(weekly_status_notes_csv_path).and_return({
        project_name: 'Foo Project',
        next_milestone: 'Some milestone',
        summary: 'Some summary'
      })
    end

    it 'returns an hash project information for all active projects' do
      expect(subject.get_projects).to include({
        project_name: 'Foo Project',
        next_milestone: 'Some milestone',
        summary: 'Some summary'
      })
    end
  end
end
