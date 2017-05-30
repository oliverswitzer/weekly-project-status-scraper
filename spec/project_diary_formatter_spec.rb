require 'rspec'
require 'rspec/mocks'
require 'csv'
require 'timecop'

require_relative '../src/project_diary_formatter'
require_relative '../helpers/file_path_helper'

describe ProjectDiaryFormatter do
  include FilePathHelper

  let(:projects) do
    [
      {
        project_name: 'Some Project 1',
        next_milestone: 'Some upcoming milestone 1',
        summary: 'Some summary 1'
      },
      {
        project_name: 'Some Project 2',
        next_milestone: 'Some upcoming milestone 2',
        summary: 'Some summary 2'
      },
      {
        project_name: 'Some Project 3',
        next_milestone: 'Some upcoming milestone 3 ',
        summary: 'Some summary 3'
      }
    ]
  end

  describe '#generate_diary' do
    let(:written_column_headers) do
      CSV.read(weekly_status_diary_path).first if File.exists?(weekly_status_diary_path)
    end

    describe 'merging new projects with old projects' do
      before do
        File.delete(weekly_status_diary_path) if File.exists?(weekly_status_diary_path)
        CSV.open(weekly_status_diary_path, 'w') do |csv|
          csv << ['Date', 'Some Project 1', 'Some Project 2', 'Some Project 3']
          csv << ['03/15/16', 'Some Project Summary 1', 'Some Project Summary 2', 'Some Project Summary 3']
        end
      end

      let(:new_projects) do
        projects << {
          project_name: 'Some NEW PROJECT',
          next_milestone: 'Some NEW PROJECTS milestone',
          summary: 'Some NEW PROJECT summary'
        }
      end

      it 'preserves old projects and adds the new one' do
        subject.generate_diary(new_projects)

        expect(headers).to include('Some Project 1', 'Some Project 2', 'Some Project 3', 'Some NEW PROJECT')
      end
    end

    describe 'adding new project entries' do
      before do
        File.delete(weekly_status_diary_path) if File.exists?(weekly_status_diary_path)
      end

      it 'opens file tmp/weekly_status_diary.csv' do
        expect(CSV).to receive(:open).with(any_args).and_call_original

        subject.generate_diary(projects)
      end

      it 'creates project names as column headers' do
        subject.generate_diary(projects)
        expect(written_column_headers).to include('Some Project 1', 'Some Project 2', 'Some Project 3')
      end

      it 'first column header is the summary date' do
        subject.generate_diary(projects)
        expect(written_column_headers.first).to eq('Date')
      end

      it 'appends the date for each row first' do
        Timecop.freeze(Time.local(2016, 03, 27))

        subject.generate_diary(projects)
        expect(appended_row.first).to eq('03/27/2016')
      end

      it 'appends the summary for each project' do
        subject.generate_diary(projects)
        expect(appended_row[1]).to eq('Summary: Some summary 1')
        expect(appended_row[2]).to eq('Summary: Some summary 2')
        expect(appended_row[3]).to eq('Summary: Some summary 3')
      end
    end

    def headers
      CSV.read(weekly_status_diary_path)[0] if File.exist?(weekly_status_diary_path)
    end

    def appended_row
      CSV.read(weekly_status_diary_path)[1] if File.exist?(weekly_status_diary_path)
    end
  end
end

