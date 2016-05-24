require 'rspec'
require 'rspec/mocks'

require_relative '../src/weekly_status_notes_scraper'
require_relative '../src/google_drive_service'

class FileListFake < Struct.new(:files)
end

class FileFake < Struct.new(:id, :name)
end

describe WeeklyStatusNotesScraper do
  let(:google_drive_service) { instance_double(GoogleDriveService) }
  let(:weekly_status_notes_scraper) { WeeklyStatusNotesScraper.new(google_drive_service) }
  let(:file_fake) { FileFake.new(456, 'NYC Project Status') }
  let(:file_list_fake) {
    FileListFake.new([file_fake])
  }

  before do
    allow(weekly_status_notes_scraper).to receive(:get_drive_service).and_return(google_drive_service)
    allow(google_drive_service).to receive(:list_files).and_return(file_list_fake)
    allow(google_drive_service).to receive(:export_file)
    allow(File).to receive(:exist?).and_return(false)
  end

  describe 'fetching files' do
    it 'gets a list of files from the drive service with correct query parameters' do
      expect(google_drive_service).to receive(:list_files).with(page_size: 1000, fields: 'nextPageToken, files')
      weekly_status_notes_scraper.get_projects
    end
  end

  describe 'exporting the Project Status file' do
    it 'only exports the NYC Project Status file' do
      some_other_file = FileFake.new(123, 'some other file')
      file_list_fake.files = [some_other_file]

      expect(google_drive_service).not_to receive(:export_file)
      weekly_status_notes_scraper.get_projects
    end

    it 'deletes the NYC Project Status file before exporting a new one' do
      allow(File).to receive(:exist?).with('../tmp/this_is_a_test.csv').and_return(true)
      expect(File).to receive(:delete).with('../tmp/this_is_a_test.csv')

      weekly_status_notes_scraper.get_projects
    end

    context 'when file does not exist or has been deleted' do
      it 'exports the NYC Project Status file to a CSV file' do
        expect(google_drive_service).to receive(:export_file).with(456, 'text/csv', download_dest: '../tmp/this_is_a_test.csv')

        weekly_status_notes_scraper.get_projects
      end
    end
  end

  describe 'parsing NYC Project Status file' do
    before do
      File.delete('../tmp/this_is_a_test.csv') if File.exist? '../tmp/test_is_a_test.csv'

      allow(CSV).to receive(:read).and_return([
        [],  # first row is column headers
        ['Foo Project', nil, nil, nil, 'Some milestone', nil, nil, nil, nil, 'Some summary']
      ])
    end

    it 'returns an hash project information for all active projects' do
      expect(weekly_status_notes_scraper.get_projects).to include({
        project_name: 'Foo Project',
        next_milestone: 'Some milestone',
        summary: 'Some summary'
      })
    end

    it 'does not return project information for rows without a name' do
      allow(CSV).to receive(:read).and_return([
        [],  # first row is column headers
        [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
      ])

      expect(weekly_status_notes_scraper.get_projects).not_to include({
        project_name: nil,
        next_milestone: nil,
        summary: nil
      })
    end
  end
end
