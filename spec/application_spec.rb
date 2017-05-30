require 'rspec'
require 'rspec/mocks'

require_relative '../src/application'
require_relative '../src/project_diary_formatter'
require_relative '../src/weekly_status_notes_scraper'
require_relative '../src/google_drive_service'

describe Application do
  describe '#execute' do
    let(:weekly_status_notes_scraper) { instance_double(WeeklyStatusNotesScraper) }
    let(:project_diary_formatter) { instance_double(ProjectDiaryFormatter) }
    let(:google_drive_service) { instance_double(GoogleDriveService) }

    let(:subject) do
      Application.new(weekly_status_notes_scraper, project_diary_formatter, google_drive_service)
    end

    let(:projects) do
      [
        {
          project: 'data'
        }
      ]
    end

    before do
      allow(weekly_status_notes_scraper).to receive(:get_projects).and_return(projects)
      allow(project_diary_formatter).to receive(:generate_diary)
      # allow(google_drive_service).to receive(())
    end

    it 'calls weekly_status_notes_scraper to get projects' do
      expect(weekly_status_notes_scraper).to receive(:get_projects)
      subject.execute
    end

    it 'passes fetched projects to project_diary_formatter' do
      expect(project_diary_formatter).to receive(:generate_diary).with(projects)
      subject.execute
    end

    it 'exports the updated weekly_status_diary.csv to google drive' do
      expect(google_drive_service).to receive(:list_files).with(q: "name contains 'NYC Project History'")
      subject.execute
    end
  end
end
