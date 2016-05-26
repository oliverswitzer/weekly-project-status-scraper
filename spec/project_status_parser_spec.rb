require_relative '../src/project_status_parser'
require 'csv'

describe ProjectStatusParser do
  describe '.parse' do
    before do
      allow(CSV).to receive(:read).and_return([
        [],  # first row is column headers
        ['Foo Project', nil, nil, nil, 'Some milestone', nil, nil, nil, nil, 'Some summary']
      ])
    end

    describe 'when given a file path' do
      it 'reads that file with row separation on \r and \n' do
        expect(CSV).to receive(:read).with(a_kind_of(String), row_sep: "\r\n")
        subject.parse_from_file('some file path')
      end

      describe 'when NYC Project Status file' do
        it 'returns an hash project information for all active projects' do
          expect(subject.parse_from_file('some file path')).to include({
            project_name: 'Foo Project',
            next_milestone: 'Some milestone',
            summary: 'Some summary'
          })
        end

        it 'skips the first row' do
          expect(subject.parse_from_file('some file path')).to_not include({
            project_name: nil,
            next_milestone: nil,
            summary: nil
          })
        end

        it 'does not return project information for rows without a name' do
          allow(CSV).to receive(:read).and_return([
            [],  # first row is column headers
            [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
          ])

          expect(subject.parse_from_file('some file path')).not_to include({
            project_name: nil,
            next_milestone: nil,
            summary: nil
          })
        end
      end
    end
  end
end
